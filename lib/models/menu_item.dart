enum MenuCategory {
  rice,
  noodles,
  gobi,
  kabab,
  softDrinks;

  String get displayName {
    switch (this) {
      case MenuCategory.rice:
        return 'Rice';
      case MenuCategory.noodles:
        return 'Noodles';
      case MenuCategory.gobi:
        return 'Gobi';
      case MenuCategory.kabab:
        return 'Kabab';
      case MenuCategory.softDrinks:
        return 'Soft Drinks';
    }
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price; // in rupees
  final String? photoUrl; // null -> UI shows category icon placeholder
  final bool available; // admin can disable an item without deleting it
  final MenuCategory category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.photoUrl,
    this.available = true,
    this.category = MenuCategory.rice,
  });

  MenuItem copyWith({
    String? name,
    double? price,
    String? photoUrl,
    bool? available,
    MenuCategory? category,
  }) {
    return MenuItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      available: available ?? this.available,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'photoUrl': photoUrl,
      'available': available,
      'category': category.name,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      available: json['available'] as bool? ?? true,
      category: MenuCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => MenuCategory.rice,
      ),
    );
  }
}

/// Comprehensive seed menu with 55 fast food dishes across:
/// 1. Rice (11 items)
/// 2. Noodles (11 items)
/// 3. Gobi (10 items)
/// 4. Kabab (11 items)
/// 5. Soft Drinks (12 items)
/// Every single item has a high-resolution, delicious real food image.
final List<MenuItem> seedMenu = [
  // =========================================================================
  // 1. RICE (11 Items)
  // =========================================================================
  const MenuItem(
    id: 'r1',
    name: 'Veg Fried Rice',
    price: 60,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r2',
    name: 'Egg Fried Rice',
    price: 70,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r3',
    name: 'Chicken Fried Rice',
    price: 100,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r4',
    name: 'Schezwan Veg Fried Rice',
    price: 75,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r5',
    name: 'Schezwan Chicken Rice',
    price: 110,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r6',
    name: 'Paneer Fried Rice',
    price: 90,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r7',
    name: 'Mushroom Fried Rice',
    price: 90,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r8',
    name: 'Jeera Rice with Dal Tadka',
    price: 80,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r9',
    name: 'Veg Dum Biryani',
    price: 90,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r10',
    name: 'Hyderabadi Chicken Biryani',
    price: 130,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'r11',
    name: 'Triple Schezwan Rice',
    price: 130,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
  ),

  // =========================================================================
  // 2. NOODLES (11 Items)
  // =========================================================================
  const MenuItem(
    id: 'n1',
    name: 'Veg Hakka Noodles',
    price: 60,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n2',
    name: 'Egg Noodles',
    price: 70,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n3',
    name: 'Chicken Hakka Noodles',
    price: 100,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n4',
    name: 'Schezwan Veg Noodles',
    price: 75,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n5',
    name: 'Schezwan Chicken Noodles',
    price: 110,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n6',
    name: 'Singapore Noodles',
    price: 85,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n7',
    name: 'Chilli Garlic Noodles',
    price: 80,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n8',
    name: 'Paneer Noodles',
    price: 90,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n9',
    name: 'Butter Garlic Noodles',
    price: 85,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n10',
    name: 'Chicken Chowmein',
    price: 105,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'n11',
    name: 'Mixed Meat Noodles',
    price: 130,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
  ),

  // =========================================================================
  // 3. GOBI (10 Items)
  // =========================================================================
  const MenuItem(
    id: 'g1',
    name: 'Gobi Manchurian (Dry)',
    price: 70,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g2',
    name: 'Gobi Manchurian (Gravy)',
    price: 80,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g3',
    name: 'Crispy Gobi 65',
    price: 80,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g4',
    name: 'Chilli Gobi',
    price: 85,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g5',
    name: 'Honey Chilli Gobi',
    price: 90,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g6',
    name: 'Pepper Gobi Fry',
    price: 85,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g7',
    name: 'Garlic Gobi',
    price: 85,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g8',
    name: 'Schezwan Gobi',
    price: 90,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g9',
    name: 'Crunchy Sesame Gobi',
    price: 95,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'g10',
    name: 'Dragon Gobi',
    price: 95,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),

  // =========================================================================
  // 4. KABAB (11 Items)
  // =========================================================================
  const MenuItem(
    id: 'k1',
    name: 'Chicken Kabab',
    price: 110,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k2',
    name: 'Chicken Seekh Kabab',
    price: 130,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k3',
    name: 'Paneer Tikka Kabab',
    price: 100,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k4',
    name: 'Chicken Tikka',
    price: 130,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k5',
    name: 'Tandoori Chicken (Half)',
    price: 160,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k6',
    name: 'Chicken Reshmi Kabab',
    price: 140,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k7',
    name: 'Hara Bhara Kabab',
    price: 90,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k8',
    name: 'Mutton Seekh Kabab',
    price: 160,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k9',
    name: 'Chicken Tangdi Kabab',
    price: 140,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k10',
    name: 'Malai Chicken Tikka',
    price: 145,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'k11',
    name: 'Kalmi Kabab',
    price: 135,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),

  // =========================================================================
  // 5. SOFT DRINKS & BEVERAGES (12 Items)
  // =========================================================================
  const MenuItem(
    id: 'd1',
    name: 'Coca Cola (500ml)',
    price: 40,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd2',
    name: 'Thums Up (500ml)',
    price: 40,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd3',
    name: 'Sprite (500ml)',
    price: 40,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd4',
    name: 'Fresh Lime Soda (Sweet/Salt)',
    price: 45,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd5',
    name: 'Mango Lassi',
    price: 60,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1571006682898-7517926105ec?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd6',
    name: 'Punjabi Sweet Lassi',
    price: 50,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1571006682898-7517926105ec?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd7',
    name: 'Iced Cold Coffee',
    price: 65,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd8',
    name: 'Virgin Mint Mojito',
    price: 60,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd9',
    name: 'Blue Lagoon Cooler',
    price: 65,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd10',
    name: 'Royal Badam Milk',
    price: 55,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1571006682898-7517926105ec?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd11',
    name: 'Lemon Iced Tea',
    price: 50,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'd12',
    name: 'Packaged Mineral Water (1L)',
    price: 20,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?auto=format&fit=crop&w=600&q=80',
  ),
];
