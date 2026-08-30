import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../services/menu_repository.dart';
import '../../theme/app_colors.dart';
import 'checkout_modal.dart';
import 'order_success_dialog.dart';

import '../../widgets/shop_qr_dialog.dart';

class CustomerHome extends StatefulWidget {
  final VoidCallback? onSwitchToAdmin;
  final VoidCallback? onLogout;

  const CustomerHome({super.key, this.onSwitchToAdmin, this.onLogout});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  MenuCategory? _selectedCategory; // null = All
  String _searchQuery = '';

  // Cart state: menuItemId -> OrderLineItem
  final Map<String, OrderLineItem> _cart = {};

  void _showShopQr() {
    showDialog(
      context: context,
      builder: (_) => const ShopQrDialog(),
    );
  }

  List<MenuItem> _filterMenu(List<MenuItem> allMenu) {
    return allMenu.where((item) {
      if (!item.available) return false; // customers only see available dishes
      final matchesCat = _selectedCategory == null || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  int get _totalCartItems {
    return _cart.values.fold(0, (sum, i) => sum + i.quantity);
  }

  double get _totalCartPrice {
    return _cart.values.fold(0.0, (sum, i) => sum + i.lineTotal);
  }

  void _addItemToCart(MenuItem item) {
    setState(() {
      final current = _cart[item.id];
      final currentQty = current?.quantity ?? 0;
      _cart[item.id] = OrderLineItem(
        menuItemId: item.id,
        name: item.name,
        price: item.price,
        quantity: currentQty + 1,
      );
    });
  }

  void _removeItemFromCart(MenuItem item) {
    setState(() {
      final current = _cart[item.id];
      if (current == null) return;
      if (current.quantity <= 1) {
        _cart.remove(item.id);
      } else {
        _cart[item.id] = OrderLineItem(
          menuItemId: item.id,
          name: item.name,
          price: item.price,
          quantity: current.quantity - 1,
        );
      }
    });
  }

  Future<void> _openCheckoutModal() async {
    if (_cart.isEmpty) return;

    final FoodOrder? placedOrder = await showModalBottomSheet<FoodOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckoutModal(
        cartItems: _cart,
        onOrderPlaced: () {},
      ),
    );

    if (placedOrder != null && mounted) {
      // Clear cart
      setState(() => _cart.clear());

      // Show token receipt modal
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => OrderSuccessDialog(
          order: placedOrder,
          onNewOrder: () {},
        ),
      );
    }
  }

  IconData _iconForCategory(MenuCategory category) {
    switch (category) {
      case MenuCategory.rice:
        return Icons.rice_bowl_rounded;
      case MenuCategory.noodles:
        return Icons.ramen_dining_rounded;
      case MenuCategory.kabab:
        return Icons.kebab_dining_rounded;
      case MenuCategory.softDrinks:
        return Icons.local_drink_rounded;
      case MenuCategory.gobi:
        return Icons.dinner_dining_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: MenuRepository.instance.menuStream,
      initialData: MenuRepository.instance.currentMenu,
      builder: (context, snapshot) {
        final allMenu = snapshot.data ?? MenuRepository.instance.currentMenu;
        final filtered = _filterMenu(allMenu);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top Header Banner
                    _buildCustomerHeader(),

                    // Search Bar
                    _buildSearchBar(),

                    // Category Chips
                    _buildCategoryFilterBar(),

                    // Menu Items List
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final qty = _cart[item.id]?.quantity ?? 0;
                                return _CustomerItemCard(
                                  item: item,
                                  quantityInCart: qty,
                                  categoryIcon: _iconForCategory(item.category),
                                  onAdd: () => _addItemToCart(item),
                                  onRemove: () => _removeItemFromCart(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // Zomato/Swiggy Floating Cart Bar
                if (_totalCartItems > 0)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildFloatingCartBar(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TOP CUSTOMER HEADER
  // ------------------------------------------------------------

  Widget _buildCustomerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brandRed, AppColors.brandOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // QR Code Badge Icon
          GestureDetector(
            onTap: _showShopQr,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.brandRed,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FastFood Counter #1',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Scan & Instant Order',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          if (!kIsWeb) ...[
            const SizedBox(width: 6),

            // Shop QR Button
            GestureDetector(
              onTap: _showShopQr,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'QR',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Switch to Admin Button (Only shown in native mobile app for admin, hidden on customer web)
          if (!kIsWeb && widget.onSwitchToAdmin != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: widget.onSwitchToAdmin,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 14,
                      color: AppColors.brandRed,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (!kIsWeb && widget.onLogout != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.logout_rounded, color: AppColors.brandRed),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to log out of FastFood?',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onLogout?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search for rice, noodles, kababs, drinks...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textFaint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandOrange),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY FILTER BAR
  // ------------------------------------------------------------

  Widget _buildCategoryFilterBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CustomerCatChip(
            label: 'All Dishes',
            icon: Icons.restaurant_menu_rounded,
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          _CustomerCatChip(
            label: 'Rice',
            icon: Icons.rice_bowl_rounded,
            isSelected: _selectedCategory == MenuCategory.rice,
            onTap: () => setState(() => _selectedCategory = MenuCategory.rice),
          ),
          const SizedBox(width: 8),
          _CustomerCatChip(
            label: 'Noodles',
            icon: Icons.ramen_dining_rounded,
            isSelected: _selectedCategory == MenuCategory.noodles,
            onTap: () => setState(() => _selectedCategory = MenuCategory.noodles),
          ),
          const SizedBox(width: 8),
          _CustomerCatChip(
            label: 'Kabab',
            icon: Icons.kebab_dining_rounded,
            isSelected: _selectedCategory == MenuCategory.kabab,
            onTap: () => setState(() => _selectedCategory = MenuCategory.kabab),
          ),
          const SizedBox(width: 8),
          _CustomerCatChip(
            label: 'Soft Drinks',
            icon: Icons.local_drink_rounded,
            isSelected: _selectedCategory == MenuCategory.softDrinks,
            onTap: () => setState(() => _selectedCategory = MenuCategory.softDrinks),
          ),
          const SizedBox(width: 8),
          _CustomerCatChip(
            label: 'Gobi',
            icon: Icons.dinner_dining_rounded,
            isSelected: _selectedCategory == MenuCategory.gobi,
            onTap: () => setState(() => _selectedCategory = MenuCategory.gobi),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FLOATING CART BAR (Zomato Style)
  // ------------------------------------------------------------

  Widget _buildFloatingCartBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandRed, AppColors.brandOrange],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandRed.withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_totalCartItems ITEM${_totalCartItems == 1 ? '' : 'S'}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '₹${_totalCartPrice.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),

          // View Cart CTA Button
          ElevatedButton.icon(
            onPressed: _openCheckoutModal,
            icon: const Icon(Icons.shopping_cart_rounded, size: 18),
            label: Text(
              'View Cart',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.brandRed,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 52,
              color: AppColors.textFaint,
            ),
            const SizedBox(height: 14),
            Text(
              'No dishes found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching for another dish or select a category',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOMER DISH CARD WITH QUANTITY STEPPER
// ============================================================================

class _CustomerItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantityInCart;
  final IconData categoryIcon;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CustomerItemCard({
    required this.item,
    required this.quantityInCart,
    required this.categoryIcon,
    required this.onAdd,
    required this.onRemove,
  });

  Widget _buildImageWidget(String photo) {
    return Image.network(
      photo,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(categoryIcon, size: 36, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = item.photoUrl?.trim();
    final hasPhoto = photo != null && photo.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: quantityInCart > 0 ? AppColors.brandRed : AppColors.divider,
          width: quantityInCart > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: quantityInCart > 0
                ? AppColors.brandRed.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dish Photo Thumbnail
          Container(
            width: 95,
            height: 95,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandOrange],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? _buildImageWidget(photo)
                : Center(
                    child: Icon(categoryIcon, size: 36, color: Colors.white),
                  ),
          ),

          // Details area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.displayName.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),

                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandOrange,
                        ),
                      ),
                      const Spacer(),

                      // ADD / QUANTITY STEPPER BUTTON
                      if (quantityInCart == 0)
                        ElevatedButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: Text(
                            'ADD',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brandRed, AppColors.brandOrange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: onRemove,
                                icon: const Icon(
                                  Icons.remove_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              Text(
                                '$quantityInCart',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: onAdd,
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomerCatChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.brandRed, AppColors.brandOrange],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandRed.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.brandRed,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
