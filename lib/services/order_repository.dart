import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';
import '../models/order.dart';

class OrderRepository {
  static const String _dbBaseUrl =
      'https://fastfood-app-venky-7894e-default-rtdb.asia-southeast1.firebasedatabase.app';

  OrderRepository._internal() {
    _orders.addAll(_seedOrders());
    _controller.add(List.unmodifiable(_orders));
    _startCloudSync();
  }

  static final OrderRepository instance = OrderRepository._internal();

  final List<FoodOrder> _orders = [];
  final _controller = StreamController<List<FoodOrder>>.broadcast();
  int _tokenCounter = 6;
  bool _isSyncing = false;

  List<FoodOrder> get allOrders => List.unmodifiable(_orders);
  Stream<List<FoodOrder>> get ordersStream => _controller.stream;

  void _emit() => _controller.add(List.unmodifiable(_orders));

  void _startCloudSync() {
    // Initial fetch from cloud
    _fetchFromCloud();

    // Poll every 2 seconds for instant cross-device updates
    Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchFromCloud();
    });
  }

  Future<void> _fetchFromCloud() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final response = await http
          .get(Uri.parse('$_dbBaseUrl/orders.json'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<FoodOrder> remoteOrders = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              remoteOrders.add(FoodOrder.fromJson(value));
            } catch (_) {}
          }
        });

        if (remoteOrders.isNotEmpty) {
          // Sort by token number or placedAt
          remoteOrders.sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));

          // Merge local orders with remote orders
          for (final ro in remoteOrders) {
            final idx = _orders.indexWhere((o) => o.id == ro.id);
            if (idx >= 0) {
              _orders[idx] = ro;
            } else {
              _orders.add(ro);
            }
          }

          // Update token counter if remote token counter is higher
          final maxToken = _orders.fold<int>(
              0, (maxVal, o) => o.tokenNumber > maxVal ? o.tokenNumber : maxVal);
          if (maxToken > _tokenCounter) {
            _tokenCounter = maxToken;
          }

          _emit();
        }
      }
    } catch (_) {
      // Graceful fallback to local cache if offline
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushToCloud(FoodOrder order) async {
    try {
      final url = '$_dbBaseUrl/orders/${order.id}.json';
      await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );
    } catch (_) {}
  }

  void markCompleted(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.completedAt = DateTime.now();
    _emit();
    _pushToCloud(order);
  }

  void toggleCashPaid(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    if (order.method != PaymentMethod.cash) return;
    order.status = order.status == PaymentStatus.paid
        ? PaymentStatus.pendingUpi
        : PaymentStatus.paid;
    _emit();
    _pushToCloud(order);
  }

  /// Used by customer flow to push a freshly placed order in.
  FoodOrder submitOrder(List<OrderLineItem> items, PaymentMethod method) {
    _tokenCounter += 1;
    final newOrder = FoodOrder(
      id: 'o${_tokenCounter}_${DateTime.now().millisecondsSinceEpoch}',
      tokenNumber: _tokenCounter,
      items: items,
      placedAt: DateTime.now(),
      method: method,
    );
    _orders.add(newOrder);
    _emit();

    // Immediately push new order to cloud so admin app receives it in real time
    _pushToCloud(newOrder);

    return newOrder;
  }

  void simulateIncomingOrder() {
    final rand = Random();
    final picks = (List.of(seedMenu)..shuffle(rand)).take(1 + rand.nextInt(2));
    final items = picks
        .map((m) => OrderLineItem(
              menuItemId: m.id,
              name: m.name,
              price: m.price,
              quantity: 1 + rand.nextInt(2),
            ))
        .toList();
    final method = rand.nextBool() ? PaymentMethod.upi : PaymentMethod.cash;
    submitOrder(items, method);
  }

  List<FoodOrder> _seedOrders() {
    final now = DateTime.now();
    return [
      FoodOrder(
        id: 'o1',
        tokenNumber: 1,
        items: const [
          OrderLineItem(
              menuItemId: 'm6', name: 'Chicken Fried Rice', price: 100, quantity: 2),
        ],
        placedAt: now.subtract(const Duration(minutes: 6)),
        method: PaymentMethod.upi,
      ),
      FoodOrder(
        id: 'o2',
        tokenNumber: 2,
        items: const [
          OrderLineItem(
              menuItemId: 'm5', name: 'Gobi Manchurian', price: 60, quantity: 1),
          OrderLineItem(
              menuItemId: 'm3', name: 'Veg Fried Rice', price: 50, quantity: 1),
        ],
        placedAt: now.subtract(const Duration(minutes: 4)),
        method: PaymentMethod.cash,
      ),
      FoodOrder(
        id: 'o3',
        tokenNumber: 3,
        items: const [
          OrderLineItem(
              menuItemId: 'm2', name: 'Egg Noodles', price: 60, quantity: 3),
        ],
        placedAt: now.subtract(const Duration(minutes: 2)),
        method: PaymentMethod.upi,
      ),
    ];
  }
}
