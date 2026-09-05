import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/order.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Whether the app is currently in the foreground
  bool isAppInForeground = true;

  /// Whether the admin is currently on the Active Queue screen looking at incoming orders
  bool isViewingActiveQueue = false;

  /// Set of order IDs that have already triggered a notification or were already present
  final Set<String> _notifiedOrderIds = {};

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Notification tapped — user opened fastfood app
      },
    );

    // Request Android 13+ runtime permissions
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Mark existing orders during app launch so we only notify for genuinely NEW orders
  void seedExistingOrders(List<FoodOrder> initialOrders) {
    for (final order in initialOrders) {
      _notifiedOrderIds.add(order.id);
    }
  }

  /// Checks incoming orders from cloud sync and triggers top status-bar notification if eligible
  Future<void> handleIncomingOrders(List<FoodOrder> orders) async {
    if (kIsWeb) return;

    final activeOrders =
        orders.where((o) => o.stage == OrderStage.active).toList();

    for (final order in activeOrders) {
      if (_notifiedOrderIds.contains(order.id)) {
        continue; // Already processed/notified
      }

      _notifiedOrderIds.add(order.id);

      // Decision rules:
      // 1. If admin is on the Active Queue page -> DO NOT notify (already looking at the chits)
      // 2. If admin is on Menu / other tabs -> NOTIFY in top bar
      // 3. If admin is outside the app (background/minimized/in other apps) -> NOTIFY in top bar
      final shouldNotify = !isAppInForeground || !isViewingActiveQueue;

      if (shouldNotify) {
        await _showOrderNotification(order);
      }
    }
  }

  Future<void> _showOrderNotification(FoodOrder order) async {
    if (!_isInitialized) {
      await initialize();
    }

    final itemsSummary =
        order.items.map((i) => '${i.quantity}× ${i.name}').join(', ');
    final methodStr =
        order.method == PaymentMethod.cash ? 'Cash' : 'UPI (Counter QR)';

    const androidDetails = AndroidNotificationDetails(
      'fastfood_orders_channel',
      'FastFood Orders',
      channelDescription: 'Instant alerts for incoming kitchen orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Unique integer ID for notification
    final notifId = order.tokenNumber * 1000 +
        (DateTime.now().millisecondsSinceEpoch % 1000);

    await _notificationsPlugin.show(
      id: notifId,
      title: '🔔 New Order P${order.tokenNumber} (₹${order.total.toStringAsFixed(0)})',
      body: '$itemsSummary • $methodStr',
      notificationDetails: notificationDetails,
      payload: order.id,
    );
  }
}
