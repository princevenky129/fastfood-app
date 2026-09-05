import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

const String _dbBaseUrl =
    'https://fastfood-app-venky-7894e-default-rtdb.asia-southeast1.firebasedatabase.app';

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(
    settings: initSettings,
  );

  bool isAppInForeground = false;
  bool isViewingActiveQueue = false;
  final Set<String> processedOrderIds = {};

  // Load previously seen orders from SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('processed_order_ids') ?? [];
    processedOrderIds.addAll(saved);
  } catch (_) {}

  // Listen to UI state updates from the running app
  service.on('activeQueueStatus').listen((event) {
    if (event != null && event['isViewing'] is bool) {
      isViewingActiveQueue = event['isViewing'] as bool;
    }
  });

  service.on('appForegroundStatus').listen((event) {
    if (event != null && event['isForeground'] is bool) {
      isAppInForeground = event['isForeground'] as bool;
    }
  });

  // Seed initial cloud orders on service start
  Future<void> checkOrders() async {
    try {
      final response = await http
          .get(Uri.parse('$_dbBaseUrl/orders.json'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 &&
          response.body != 'null' &&
          response.body.isNotEmpty &&
          response.body != '{}') {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<FoodOrder> remoteOrders = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              remoteOrders.add(FoodOrder.fromJson(value));
            } catch (_) {}
          }
        });

        // Filter for active orders
        final activeOrders =
            remoteOrders.where((o) => o.stage == OrderStage.active).toList();

        for (final order in activeOrders) {
          if (!processedOrderIds.contains(order.id)) {
            processedOrderIds.add(order.id);

            // Persist to SharedPreferences
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList(
                  'processed_order_ids', processedOrderIds.toList());
            } catch (_) {}

            // Decision Rules:
            // 1. In Active Queue tab -> No notification
            // 2. In Menu/Completed tab -> Notify in top bar
            // 3. App closed/minimized/in other apps -> Notify in top bar
            final shouldNotify = !isAppInForeground || !isViewingActiveQueue;

            if (shouldNotify) {
              final itemsSummary = order.items
                  .map((i) => '${i.quantity}× ${i.name}')
                  .join(', ');
              final methodStr = order.method == PaymentMethod.cash
                  ? 'Cash'
                  : 'UPI (Counter QR)';

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

              const notifDetails =
                  NotificationDetails(android: androidDetails);

              final notifId = order.tokenNumber * 1000 +
                  (DateTime.now().millisecondsSinceEpoch % 1000);

              await notificationsPlugin.show(
                id: notifId,
                title:
                    '🔔 New Order P${order.tokenNumber} (₹${order.total.toStringAsFixed(0)})',
                body: '$itemsSummary • $methodStr',
                notificationDetails: notifDetails,
                payload: order.id,
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  // Initial check
  await checkOrders();

  // Periodic check every 3 seconds even if app is closed/killed
  Timer.periodic(const Duration(seconds: 3), (_) async {
    await checkOrders();
  });
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isAppInForeground = true;
  bool _isViewingActiveQueue = false;

  bool get isAppInForeground => _isAppInForeground;
  set isAppInForeground(bool val) {
    _isAppInForeground = val;
    _syncStateToBackgroundService();
  }

  bool get isViewingActiveQueue => _isViewingActiveQueue;
  set isViewingActiveQueue(bool val) {
    _isViewingActiveQueue = val;
    _syncStateToBackgroundService();
  }

  void _syncStateToBackgroundService() {
    if (kIsWeb) return;
    try {
      FlutterBackgroundService().invoke('activeQueueStatus', {
        'isViewing': _isViewingActiveQueue,
      });
      FlutterBackgroundService().invoke('appForegroundStatus', {
        'isForeground': _isAppInForeground,
      });
    } catch (_) {}
  }

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'fastfood_orders_channel',
          'FastFood Orders',
          description: 'Instant alerts for incoming kitchen orders',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'fastfood_service_channel',
          'FastFood Kitchen Service',
          description: 'Runs background order listener',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }

    try {
      // Configure persistent background service
      final service = FlutterBackgroundService();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onBackgroundServiceStart,
          autoStart: true,
          isForegroundMode: true,
          notificationChannelId: 'fastfood_service_channel',
          initialNotificationTitle: 'FastFood Kitchen Active',
          initialNotificationContent: 'Monitoring live customer orders...',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(),
      );
    } catch (e) {
      debugPrint('Background service init warning: $e');
    }

    _isInitialized = true;
    _syncStateToBackgroundService();
  }

  void seedExistingOrders(List<FoodOrder> initialOrders) async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList('processed_order_ids') ?? [];
      final set = current.toSet();
      for (final order in initialOrders) {
        set.add(order.id);
      }
      await prefs.setStringList('processed_order_ids', set.toList());
    } catch (_) {}
  }

  Future<void> handleIncomingOrders(List<FoodOrder> orders) async {
    // Handled by the persistent background service listener
  }
}
