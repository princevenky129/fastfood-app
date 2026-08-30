import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/menu_item.dart';
import '../../services/menu_repository.dart';
import '../../theme/app_colors.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  MenuCategory? _selectedCategory; // null = All Categories

  // ------------------------------------------------------------
  // CATEGORY HELPERS
  // ------------------------------------------------------------

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

  List<Color> _gradientForCategory(MenuCategory category) {
    switch (category) {
      case MenuCategory.rice:
        return [const Color(0xFFFF7043), const Color(0xFFD84315)];
      case MenuCategory.noodles:
        return [const Color(0xFFFB8C00), const Color(0xFFE65100)];
      case MenuCategory.kabab:
        return [const Color(0xFFFF5252), const Color(0xFFC62828)];
      case MenuCategory.softDrinks:
        return [const Color(0xFF0288D1), const Color(0xFF01579B)];
      case MenuCategory.gobi:
        return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    }
  }

  List<MenuItem> _filterItems(List<MenuItem> items) {
    if (_selectedCategory == null) return items;
    return items.where((item) => item.category == _selectedCategory).toList();
  }

  int _countForCategory(List<MenuItem> items, MenuCategory? category) {
    if (category == null) return items.length;
    return items.where((i) => i.category == category).length;
  }

  // ------------------------------------------------------------
  // ADD ITEM
  // ------------------------------------------------------------

  Future<void> _showAddItemDialog() async {
    final defaultCat = _selectedCategory ?? MenuCategory.rice;
    final result = await showDialog<_MenuFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => _MenuItemDialog(
        title: 'Add New Food Item',
        buttonText: 'Add to Menu',
        initialCategory: defaultCat,
      ),
    );
    if (result == null) return;
    MenuRepository.instance.addItem(MenuItem(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: result.name,
      price: result.price,
      category: result.category,
      photoUrl: result.photoUrl,
      available: result.available,
    ));
  }

  // ------------------------------------------------------------
  // EDIT ITEM
  // ------------------------------------------------------------

  Future<void> _showEditItemDialog(MenuItem item) async {
    final result = await showDialog<_MenuFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => _MenuItemDialog(
        title: 'Edit Food Details',
        buttonText: 'Save Changes',
        initialName: item.name,
        initialPrice: item.price,
        initialCategory: item.category,
        initialPhotoUrl: item.photoUrl,
        initialAvailable: item.available,
      ),
    );
    if (result == null) return;
    MenuRepository.instance.updateItem(item.copyWith(
      name: result.name,
      price: result.price,
      category: result.category,
      photoUrl: result.photoUrl,
      available: result.available,
    ));
  }

  // ------------------------------------------------------------
  // DELETE ITEM
  // ------------------------------------------------------------

  Future<void> _deleteItem(MenuItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Remove Item?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${item.name}" from your menu?',
          style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.6),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Remove', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    MenuRepository.instance.deleteItem(item.id);
  }

  // ------------------------------------------------------------
  // TOGGLE AVAILABILITY
  // ------------------------------------------------------------

  void _toggleAvailability(MenuItem item) {
    MenuRepository.instance.toggleAvailability(item.id);
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: MenuRepository.instance.menuStream,
      initialData: MenuRepository.instance.currentMenu,
      builder: (context, snapshot) {
        final items = snapshot.data ?? MenuRepository.instance.currentMenu;
        final filtered = _filterItems(items);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Header Hero Banner
              _buildHeroBanner(items),

              // Category Bar Tabs
              _buildCategoryFilterBar(items),

              // Item List or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _MenuItemCard(
                            item: item,
                            categoryIcon: _iconForCategory(item.category),
                            gradient: _gradientForCategory(item.category),
                            onEdit: () => _showEditItemDialog(item),
                            onDelete: () => _deleteItem(item),
                            onToggleAvailability: () => _toggleAvailability(item),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  // ------------------------------------------------------------
  // HERO BANNER
  // ------------------------------------------------------------

  Widget _buildHeroBanner(List<MenuItem> items) {
    final total = items.length;
    final available = items.where((i) => i.available).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brandRed, AppColors.brandOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandRed.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Management',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Organize dishes across 5 categories',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatBadge(
                        count: total,
                        label: 'Total Items',
                        color: Colors.white,
                        textColor: AppColors.brandRed,
                      ),
                      const SizedBox(width: 8),
                      _StatBadge(
                        count: available,
                        label: 'Available',
                        color: Colors.white.withValues(alpha: 0.22),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY FILTER BAR
  // ------------------------------------------------------------

  Widget _buildCategoryFilterBar(List<MenuItem> items) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All Option
          _CategoryChip(
            label: 'All Items',
            icon: Icons.grid_view_rounded,
            count: _countForCategory(items, null),
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),

          // 1. Rice
          _CategoryChip(
            label: MenuCategory.rice.displayName,
            icon: Icons.rice_bowl_rounded,
            count: _countForCategory(items, MenuCategory.rice),
            isSelected: _selectedCategory == MenuCategory.rice,
            onTap: () => setState(() => _selectedCategory = MenuCategory.rice),
          ),
          const SizedBox(width: 8),

          // 2. Noodles
          _CategoryChip(
            label: MenuCategory.noodles.displayName,
            icon: Icons.ramen_dining_rounded,
            count: _countForCategory(items, MenuCategory.noodles),
            isSelected: _selectedCategory == MenuCategory.noodles,
            onTap: () => setState(() => _selectedCategory = MenuCategory.noodles),
          ),
          const SizedBox(width: 8),

          // 3. Kabab
          _CategoryChip(
            label: MenuCategory.kabab.displayName,
            icon: Icons.kebab_dining_rounded,
            count: _countForCategory(items, MenuCategory.kabab),
            isSelected: _selectedCategory == MenuCategory.kabab,
            onTap: () => setState(() => _selectedCategory = MenuCategory.kabab),
          ),
          const SizedBox(width: 8),

          // 4. Soft Drinks
          _CategoryChip(
            label: MenuCategory.softDrinks.displayName,
            icon: Icons.local_drink_rounded,
            count: _countForCategory(items, MenuCategory.softDrinks),
            isSelected: _selectedCategory == MenuCategory.softDrinks,
            onTap: () => setState(() => _selectedCategory = MenuCategory.softDrinks),
          ),
          const SizedBox(width: 8),

          // 5. Gobi
          _CategoryChip(
            label: MenuCategory.gobi.displayName,
            icon: Icons.dinner_dining_rounded,
            count: _countForCategory(items, MenuCategory.gobi),
            isSelected: _selectedCategory == MenuCategory.gobi,
            onTap: () => setState(() => _selectedCategory = MenuCategory.gobi),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    final categoryName = _selectedCategory?.displayName ?? 'menu';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandRed, AppColors.brandOrange],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandRed.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _selectedCategory != null
                    ? _iconForCategory(_selectedCategory!)
                    : Icons.restaurant_menu_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No items in $categoryName',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap below to add your first item to $categoryName',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _GradientButton(
              label: 'Add to $categoryName',
              icon: Icons.add_rounded,
              onTap: _showAddItemDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    final catLabel = _selectedCategory != null
        ? 'Add ${_selectedCategory!.displayName}'
        : 'Add Item';
    return _GradientButton(
      label: catLabel,
      icon: Icons.add_rounded,
      onTap: _showAddItemDialog,
    );
  }
}

// ============================================================================
// STAT BADGE
// ============================================================================

class _StatBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color textColor;

  const _StatBadge({
    required this.count,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ============================================================================
// CATEGORY CHIP
// ============================================================================

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count,
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
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.brandRed,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.brandOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GRADIENT BUTTON
// ============================================================================

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandRed, AppColors.brandOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandRed.withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MENU ITEM CARD — Real Image Renderer (Local Gallery File or Network URL)
// ============================================================================

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final IconData categoryIcon;
  final List<Color> gradient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const _MenuItemCard({
    required this.item,
    required this.categoryIcon,
    required this.gradient,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  Widget _buildImageWidget(String photo) {
    final isLocalFile = !photo.startsWith('http://') && !photo.startsWith('https://');
    if (isLocalFile) {
      final file = File(photo);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.network(
      photo,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(categoryIcon, size: 40, color: Colors.white),
        );
      },
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: item.available ? AppColors.divider : const Color(0xFFFFCDD2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.available
                ? const Color(0x12E23744)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Container
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? _buildImageWidget(photo)
                : Center(
                    child: Icon(categoryIcon, size: 40, color: Colors.white),
                  ),
          ),

          // Details area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.displayName.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandOrange,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Availability Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.available
                              ? AppColors.paidBg
                              : AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.available ? 'AVAILABLE' : 'OFF MENU',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: item.available
                                ? AppColors.paid
                                : AppColors.danger,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Item Name
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: item.available
                          ? AppColors.textPrimary
                          : AppColors.textFaint,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price Tag & Controls
                  Row(
                    children: [
                      // Price Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.brandOrange, Color(0xFFFF9100)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Edit button
                      _ActionBtn(
                        icon: Icons.edit_rounded,
                        color: AppColors.brandRed,
                        bgColor: AppColors.dangerBg,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),

                      // Delete button
                      _ActionBtn(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        bgColor: AppColors.dangerBg,
                        onTap: onDelete,
                      ),
                      const SizedBox(width: 8),

                      // Availability Switch
                      GestureDetector(
                        onTap: onToggleAvailability,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 42,
                          height: 24,
                          decoration: BoxDecoration(
                            color: item.available
                                ? AppColors.paid
                                : const Color(0xFFCFD8DC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 220),
                            alignment: item.available
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x30000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

// ============================================================================
// ACTION BUTTON
// ============================================================================

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ============================================================================
// FORM RESULT
// ============================================================================

class _MenuFormResult {
  final String name;
  final double price;
  final MenuCategory category;
  final String? photoUrl;
  final bool available;

  const _MenuFormResult({
    required this.name,
    required this.price,
    required this.category,
    this.photoUrl,
    required this.available,
  });
}

// ============================================================================
// ADD / EDIT DIALOG — Gallery Image Upload Support + Camera + URL
// ============================================================================

class _MenuItemDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final String initialName;
  final double initialPrice;
  final MenuCategory initialCategory;
  final String? initialPhotoUrl;
  final bool initialAvailable;

  const _MenuItemDialog({
    required this.title,
    required this.buttonText,
    this.initialName = '',
    this.initialPrice = 0,
    this.initialCategory = MenuCategory.rice,
    this.initialPhotoUrl,
    this.initialAvailable = true,
  });

  @override
  State<_MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<_MenuItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _photoUrlController;
  late MenuCategory _selectedCategory;
  late bool _available;

  final ImagePicker _picker = ImagePicker();

  // Sample photo presets per category for quick fallback
  final Map<MenuCategory, List<String>> _samplePhotos = {
    MenuCategory.rice: [
      'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=600&q=80',
    ],
    MenuCategory.noodles: [
      'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=600&q=80',
    ],
    MenuCategory.kabab: [
      'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1610057099443-f63a14436e2f?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=600&q=80',
    ],
    MenuCategory.softDrinks: [
      'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1571006682898-7517926105ec?auto=format&fit=crop&w=600&q=80',
    ],
    MenuCategory.gobi: [
      'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=600&q=80',
    ],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _priceController = TextEditingController(
      text: widget.initialPrice == 0 ? '' : widget.initialPrice.toStringAsFixed(0),
    );
    _photoUrlController = TextEditingController(text: widget.initialPhotoUrl ?? '');
    _selectedCategory = widget.initialCategory;
    _available = widget.initialAvailable;

    _photoUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  // Pick Image from Gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _photoUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      _showError('Unable to open photo gallery: $e');
    }
  }

  // Take Image from Camera
  Future<void> _takeImageWithCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (pickedFile != null) {
        setState(() {
          _photoUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      _showError('Unable to open camera: $e');
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final photoUrl = _photoUrlController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter the food item name.');
      return;
    }
    if (price == null || price <= 0) {
      _showError('Please enter a valid price.');
      return;
    }

    Navigator.pop(
      context,
      _MenuFormResult(
        name: name,
        price: price,
        category: _selectedCategory,
        photoUrl: photoUrl.isEmpty ? null : photoUrl,
        available: _available,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPreview(String path) {
    final isLocalFile = !path.startsWith('http://') && !path.startsWith('https://');
    if (isLocalFile) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          'Image Preview Unavailable',
          style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _photoUrlController.text.trim();
    final isLocalFile = photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http://') &&
        !photoUrl.startsWith('https://');

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandRed, AppColors.brandOrange],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceWarm,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 1. Category Selection
            Text(
              'Select Category',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MenuCategory.values.map((cat) {
                final isSel = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat.displayName),
                  selected: isSel,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  selectedColor: AppColors.brandRed,
                  backgroundColor: AppColors.surfaceWarm,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                    color: isSel ? Colors.white : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSel ? AppColors.brandRed : AppColors.divider,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  showCheckmark: false,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 2. Food Name
            Text(
              'Dish / Drink Name',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Chicken Kabab / Egg Noodles',
                hintStyle: GoogleFonts.inter(color: AppColors.textFaint),
                fillColor: AppColors.surfaceWarm,
              ),
            ),

            const SizedBox(height: 14),

            // 3. Price
            Text(
              'Price (₹)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '120',
                hintStyle: GoogleFonts.inter(color: AppColors.textFaint),
                fillColor: AppColors.surfaceWarm,
                prefixText: '₹  ',
                prefixStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandOrange,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Food Image Option (Gallery Upload + Camera + URL)
            Row(
              children: [
                Text(
                  'Food Photo / Image',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (photoUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _photoUrlController.clear(),
                    child: Text(
                      'Remove Photo',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // GALLERY & CAMERA UPLOAD BUTTONS
            Row(
              children: [
                // Upload from Gallery Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: Text(
                      'Upload Gallery Photo',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Camera Button
                IconButton(
                  onPressed: _takeImageWithCamera,
                  icon: const Icon(Icons.camera_alt_rounded, color: AppColors.brandOrange),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceWarm,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Live Image Preview Box
            if (photoUrl.isNotEmpty) ...[
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandRed, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildPreview(photoUrl)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLocalFile ? '📷 Gallery Photo' : '🌐 Web Photo',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Optional Image URL Input Field
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Or enter Image URL manually',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              children: [
                TextField(
                  controller: _photoUrlController,
                  keyboardType: TextInputType.url,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Paste web image URL (https://...)',
                    hintStyle: GoogleFonts.inter(color: AppColors.textFaint, fontSize: 12),
                    fillColor: AppColors.surfaceWarm,
                    prefixIcon: const Icon(Icons.link_rounded, color: AppColors.brandOrange, size: 18),
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Preset Sample Photos Option
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: (_samplePhotos[_selectedCategory] ?? []).map((url) {
                      return GestureDetector(
                        onTap: () => _photoUrlController.text = url,
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: photoUrl == url ? AppColors.brandRed : AppColors.divider,
                              width: photoUrl == url ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 5. Available Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    _available
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _available ? AppColors.paid : AppColors.danger,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available on Menu',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _available
                              ? 'Customers can order this dish'
                              : 'Hidden from menu',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _available,
                    onChanged: (v) => setState(() => _available = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.paid,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCFD8DC),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandRed, AppColors.brandOrange],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandRed.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          widget.buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}