enum MenuCategory {
  rice,
  noodles,
  kabab,
  softDrinks,
  gobi;

  String get displayName {
    switch (this) {
      case MenuCategory.rice:
        return 'Rice';
      case MenuCategory.noodles:
        return 'Noodles';
      case MenuCategory.kabab:
        return 'Kabab';
      case MenuCategory.softDrinks:
        return 'Soft Drinks';
      case MenuCategory.gobi:
        return 'Gobi';
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

/// Seed data with items across all 5 categories (Rice, Noodles, Kabab, Soft Drinks, Gobi)
/// using real food photos instead of emojis.
final List<MenuItem> seedMenu = [
  // 1. RICE
  const MenuItem(
    id: 'm1',
    name: 'Egg Rice',
    price: 60,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm2',
    name: 'Chicken Fried Rice',
    price: 100,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm3',
    name: 'Veg Fried Rice',
    price: 50,
    category: MenuCategory.rice,
    photoUrl: 'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
  ),

  // 2. NOODLES
  const MenuItem(
    id: 'm4',
    name: 'Egg Noodles',
    price: 60,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm5',
    name: 'Chicken Fried Noodles',
    price: 100,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm6',
    name: 'Veg Fried Noodles',
    price: 50,
    category: MenuCategory.noodles,
    photoUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80',
  ),

  // 3. KABAB
  const MenuItem(
    id: 'm7',
    name: 'Chicken Kabab',
    price: 120,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm8',
    name: 'Seekh Kabab',
    price: 140,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm9',
    name: 'Paneer Tikka Kabab',
    price: 110,
    category: MenuCategory.kabab,
    photoUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
  ),

  // 4. SOFT DRINKS
  const MenuItem(
    id: 'm10',
    name: 'Coca Cola (500ml)',
    price: 40,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm11',
    name: 'Fresh Lime Soda',
    price: 50,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
  ),
  const MenuItem(
    id: 'm12',
    name: 'Mango Lassi',
    price: 60,
    category: MenuCategory.softDrinks,
    photoUrl: 'https://images.unsplash.com/photo-1571006682898-7517926105ec?auto=format&fit=crop&w=600&q=80',
  ),

  // 5. GOBI
  const MenuItem(
    id: 'm13',
    name: 'Gobi Manchurian',
    price: 80,
    category: MenuCategory.gobi,
    photoUrl: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
  ),
];

