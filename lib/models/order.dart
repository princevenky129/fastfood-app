enum PaymentMethod { upi, cash }

enum PaymentStatus { pendingUpi, paid }

enum OrderStage { active, completed }

class OrderLineItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  const OrderLineItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get lineTotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'menuItemId': menuItemId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
        menuItemId: json['menuItemId'] as String? ?? 'm1',
        name: json['name'] as String? ?? 'Item',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

class FoodOrder {
  final String id;
  final int tokenNumber;
  final List<OrderLineItem> items;
  final DateTime placedAt;
  final PaymentMethod method;
  PaymentStatus status;
  DateTime? completedAt;

  FoodOrder({
    required this.id,
    required this.tokenNumber,
    required this.items,
    required this.placedAt,
    required this.method,
    PaymentStatus? status,
    this.completedAt,
  }) : status = status ??
            (method == PaymentMethod.cash
                ? PaymentStatus.pendingUpi
                : PaymentStatus.paid);

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  OrderStage get stage =>
      completedAt == null ? OrderStage.active : OrderStage.completed;

  bool get isCashPaid =>
      method == PaymentMethod.cash && status == PaymentStatus.paid;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tokenNumber': tokenNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'placedAt': placedAt.toIso8601String(),
        'method': method.name,
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
        id: json['id'] as String? ?? '',
        tokenNumber: (json['tokenNumber'] as num?)?.toInt() ?? 1,
        items: (json['items'] as List<dynamic>?)
                ?.map((i) => OrderLineItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
        placedAt: DateTime.tryParse(json['placedAt'] as String? ?? '') ??
            DateTime.now(),
        method: (json['method'] as String?) == 'cash'
            ? PaymentMethod.cash
            : PaymentMethod.upi,
        status: (json['status'] as String?) == 'paid'
            ? PaymentStatus.paid
            : PaymentStatus.pendingUpi,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
      );
}
