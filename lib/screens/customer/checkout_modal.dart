import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/order.dart';
import '../../services/order_repository.dart';
import '../../theme/app_colors.dart';

class CheckoutModal extends StatefulWidget {
  final Map<String, OrderLineItem> cartItems;
  final VoidCallback onOrderPlaced;

  const CheckoutModal({
    super.key,
    required this.cartItems,
    required this.onOrderPlaced,
  });

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  PaymentMethod _selectedMethod = PaymentMethod.upi;
  bool _isSubmitting = false;

  static const String shopUpiId = '8904629757@ptyes';

  double get _totalAmount {
    return widget.cartItems.values
        .fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  Future<void> _triggerUpiDeepLink(double amount) async {
    const payeeName = 'FastFood Counter';
    final amountStr = amount.toStringAsFixed(2);

    final upiUrl =
        'upi://pay?pa=$shopUpiId&pn=${Uri.encodeComponent(payeeName)}&am=$amountStr&cu=INR&tn=${Uri.encodeComponent("FastFood Order Payment")}';
    final uri = Uri.parse(upiUrl);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback for non-UPI devices or emulators
      }
    } catch (_) {
      // Ignored
    }
  }

  Future<void> _placeOrder() async {
    if (widget.cartItems.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final items = widget.cartItems.values.toList();
    final repo = OrderRepository.instance;

    // If UPI selected, trigger UPI deep link to GPay / PhonePe / Paytm
    if (_selectedMethod == PaymentMethod.upi) {
      await _triggerUpiDeepLink(_totalAmount);
    }

    // Submit order to shared kitchen queue & return created order
    final newOrder = await repo.submitOrder(items, _selectedMethod);

    if (!mounted) return;
    Navigator.pop(context, newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final itemsList = widget.cartItems.values.toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Modal Title & Close
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandRed, AppColors.brandOrange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Order Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${itemsList.length} item${itemsList.length == 1 ? '' : 's'} selected',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceWarm,
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Items List Container
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: itemsList.length,
              separatorBuilder: (_, __) => const Divider(height: 12, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = itemsList[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${item.lineTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Total Price Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Text(
                  'To Pay',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${_totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandOrange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Payment Method Selector
          Text(
            'Select Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // 1. UPI Payment Option (Linked to 8904629757@ptyes)
              Expanded(
                child: _PaymentOptionTile(
                  title: 'UPI Payment',
                  subtitle: 'PhonePe / GPay / Paytm',
                  icon: Icons.qr_code_2_rounded,
                  isSelected: _selectedMethod == PaymentMethod.upi,
                  onTap: () => setState(() => _selectedMethod = PaymentMethod.upi),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Cash at Counter Option
              Expanded(
                child: _PaymentOptionTile(
                  title: 'Pay Cash',
                  subtitle: 'Pay at Counter',
                  icon: Icons.money_rounded,
                  isSelected: _selectedMethod == PaymentMethod.cash,
                  onTap: () => setState(() => _selectedMethod = PaymentMethod.cash),
                ),
              ),
            ],
          ),

          // UPI ID Note
          if (_selectedMethod == PaymentMethod.upi) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.paidBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.paid.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.paid),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Redirecting to UPI ($shopUpiId) on checkout',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.paid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Place Order Button
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
                    color: AppColors.brandRed.withValues(alpha: 0.38),
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
                  onTap: _placeOrder,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedMethod == PaymentMethod.upi
                                      ? 'Pay via UPI • ₹${_totalAmount.toStringAsFixed(0)}'
                                      : 'Place Order • ₹${_totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandRed : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.brandRed : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.brandRed : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
