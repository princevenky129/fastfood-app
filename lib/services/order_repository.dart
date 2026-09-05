import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderRepository {
  static const String _dbBaseUrl =
      'https://fastfood-app-venky-7894e-default-rtdb.asia-southeast1.firebasedatabase.app';

  OrderRepository._internal() {
    _startCloudSync();
  }

  static final OrderRepository instance = OrderRepository._internal();

  final List<FoodOrder> _orders = [];
  final _controller = StreamController<List<FoodOrder>>.broadcast();
  bool _isSyncing = false;

  List<FoodOrder> get allOrders => List.unmodifiable(_orders);
  Stream<List<FoodOrder>> get ordersStream => _controller.stream;

  void _emit() => _controller.add(List.unmodifiable(_orders));

  void _startCloudSync() {
    // Initial fetch from cloud
    _fetchFromCloud();

    // Poll every 2 seconds for instant cross-device updates (App & Web)
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
      if (response.statusCode == 200) {
        if (response.body == 'null' ||
            response.body.isEmpty ||
            response.body == '{}') {
          if (_orders.isNotEmpty) {
            _orders.clear();
            _emit();
          }
        } else {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<FoodOrder> remoteOrders = [];

          data.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                remoteOrders.add(FoodOrder.fromJson(value));
              } catch (_) {}
            }
          });

          // Sort by placedAt
          remoteOrders.sort((a, b) => a.placedAt.compareTo(b.placedAt));

          _orders.clear();
          _orders.addAll(remoteOrders);

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

  /// Calculates the next sequential token strictly for TODAY (P1, P2, P3...).
  /// Automatically resets to P1 on each new calendar date.
  int getNextTokenForToday() {
    final now = DateTime.now();
    final todayOrders = _orders.where((o) =>
        o.placedAt.year == now.year &&
        o.placedAt.month == now.month &&
        o.placedAt.day == now.day).toList();

    if (todayOrders.isEmpty) return 1;

    final maxToken = todayOrders.fold<int>(
        0, (maxVal, o) => o.tokenNumber > maxVal ? o.tokenNumber : maxVal);
    return maxToken + 1;
  }

  /// Used by customer flow on web/mobile to push a freshly placed order in.
  /// Tokens are strictly daily sequential: P1, P2, P3... Pn for each day.
  Future<FoodOrder> submitOrder(
      List<OrderLineItem> items, PaymentMethod method) async {
    await _fetchFromCloud();

    final nextToken = getNextTokenForToday();
    final now = DateTime.now();

    final newOrder = FoodOrder(
      id: 'o_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_p${nextToken}_${now.millisecondsSinceEpoch}',
      tokenNumber: nextToken,
      items: items,
      placedAt: now,
      method: method,
    );

    _orders.add(newOrder);
    _emit();

    // Immediately push new order to cloud so admin app receives it in real time
    await _pushToCloud(newOrder);

    return newOrder;
  }

  /// Utility to clear all orders from Firebase and reset queue
  Future<void> clearAllOrders() async {
    _orders.clear();
    _emit();
    try {
      await http.delete(Uri.parse('$_dbBaseUrl/orders.json'));
    } catch (_) {}
  }
}
