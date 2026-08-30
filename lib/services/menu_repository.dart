import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';

class MenuRepository {
  static const String _dbBaseUrl =
      'https://fastfood-app-venky-7894e-default-rtdb.asia-southeast1.firebasedatabase.app';

  MenuRepository._internal() {
    _menu.addAll(seedMenu);
    _controller.add(List.unmodifiable(_menu));
    _startCloudSync();
  }

  static final MenuRepository instance = MenuRepository._internal();

  final List<MenuItem> _menu = [];
  final _controller = StreamController<List<MenuItem>>.broadcast();
  bool _isSyncing = false;

  List<MenuItem> get currentMenu => List.unmodifiable(_menu);
  Stream<List<MenuItem>> get menuStream => _controller.stream;

  void _emit() => _controller.add(List.unmodifiable(_menu));

  void _startCloudSync() {
    // Initial fetch from cloud
    _fetchFromCloud();

    // Poll every 2 seconds for real-time cross-device updates (App & Web)
    Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchFromCloud();
    });
  }

  Future<void> _fetchFromCloud() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final response = await http
          .get(Uri.parse('$_dbBaseUrl/menu.json'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 &&
          response.body != 'null' &&
          response.body.isNotEmpty) {
        final dynamic decoded = jsonDecode(response.body);
        final List<MenuItem> remoteMenu = [];

        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              try {
                remoteMenu.add(MenuItem.fromJson(value));
              } catch (_) {}
            }
          });
        } else if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                remoteMenu.add(MenuItem.fromJson(item));
              } catch (_) {}
            }
          }
        }

        if (remoteMenu.isNotEmpty) {
          _menu.clear();
          _menu.addAll(remoteMenu);
          _emit();
        } else {
          // If remote is empty, push seedMenu to initialize cloud
          _pushFullMenuToCloud();
        }
      } else if (response.statusCode == 200 && response.body == 'null') {
        // First initialization of cloud database
        _pushFullMenuToCloud();
      }
    } catch (_) {
      // Graceful fallback to in-memory menu if offline
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushFullMenuToCloud() async {
    try {
      final Map<String, dynamic> mapToPush = {};
      for (final item in _menu) {
        mapToPush[item.id] = item.toJson();
      }
      await http.put(
        Uri.parse('$_dbBaseUrl/menu.json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mapToPush),
      );
    } catch (_) {}
  }

  Future<void> _pushItemToCloud(MenuItem item) async {
    try {
      final url = '$_dbBaseUrl/menu/${item.id}.json';
      await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
    } catch (_) {}
  }

  Future<void> _deleteItemFromCloud(String itemId) async {
    try {
      final url = '$_dbBaseUrl/menu/$itemId.json';
      await http.delete(Uri.parse(url));
    } catch (_) {}
  }

  void toggleAvailability(String itemId) {
    final index = _menu.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final updated = _menu[index].copyWith(available: !_menu[index].available);
      _menu[index] = updated;
      _emit();
      _pushItemToCloud(updated);
    }
  }

  void addItem(MenuItem item) {
    _menu.add(item);
    _emit();
    _pushItemToCloud(item);
  }

  void updateItem(MenuItem item) {
    final index = _menu.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _menu[index] = item;
      _emit();
      _pushItemToCloud(item);
    }
  }

  void deleteItem(String itemId) {
    _menu.removeWhere((item) => item.id == itemId);
    _emit();
    _deleteItemFromCloud(itemId);
  }
}
