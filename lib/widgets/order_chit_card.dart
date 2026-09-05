import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';

/// Rich Swiggy/Zomato-style order card with vibrant color accents.
class OrderChitCard extends StatelessWidget {
  final FoodOrder order;
  final VoidCallback? onComplete;
  final VoidCallback? onToggleCash;
  final bool compact;

  const OrderChitCard({
    super.key,
    required this.order,
    this.onComplete,
    this.onToggleCash,
    this.compact = false,
  });

  Color get _statusColor {
    if (order.stage == OrderStage.completed) return AppColors.textFaint;
    return order.status == PaymentStatus.paid
        ? AppColors.paid
        : AppColors.pending;
  }

  Color get _statusBgColor {
    if (order.stage == OrderStage.completed) return AppColors.surfaceWarm;
    return order.status == PaymentStatus.paid
        ? AppColors.paidBg
        : AppColors.pendingBg;
  }

  String get _statusLabel {
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid ? 'Cash · Paid' : 'Cash · Pending';
    }
    return order.status == PaymentStatus.paid ? 'UPI · Verified' : 'UPI · Verify Pending';
  }

  IconData get _statusIcon {
    if (order.stage == OrderStage.completed) return Icons.check_circle_rounded;
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid
          ? Icons.payments_rounded
          : Icons.hourglass_top_rounded;
    }
    return order.status == PaymentStatus.paid
        ? Icons.verified_rounded
        : Icons.qr_code_scanner_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(order.placedAt);
    return compact ? _buildCompact(timeStr) : _buildFull(context, timeStr);
  }

  // --------------------------------------------------------------------------
  // FULL CARD (active orders)
  // --------------------------------------------------------------------------

  Widget _buildFull(BuildContext context, String timeStr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ---- Card Header with Gradient Accent Background ----
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor.withValues(alpha: 0.12),
                  _statusColor.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Token Square Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandRed, AppColors.brandOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandRed.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'P${order.tokenNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.tokenNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.brandOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textFaint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${order.items.length} items',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge Chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon,
                        size: 14,
                        color: _statusColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: AppColors.divider,
          ),

          // Items Breakdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              children: order.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWarm.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Quantity Tag
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.brandRed, AppColors.brandOrange],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          color: AppColors.brandOrange,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Total Bar & Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        '₹${order.total.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),

                if (order.stage == OrderStage.active) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Payment Verification Toggle Button (Cash or UPI)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onToggleCash,
                          icon: Icon(
                            order.status == PaymentStatus.paid
                                ? Icons.check_circle_rounded
                                : (order.method == PaymentMethod.cash
                                    ? Icons.payments_outlined
                                    : Icons.qr_code_rounded),
                            size: 18,
                            color: order.status == PaymentStatus.paid
                                ? AppColors.paid
                                : AppColors.pending,
                          ),
                          label: Text(
                            order.status == PaymentStatus.paid
                                ? (order.method == PaymentMethod.cash
                                    ? 'Cash Paid'
                                    : 'UPI Verified')
                                : (order.method == PaymentMethod.cash
                                    ? 'Mark Cash Paid'
                                    : 'Verify UPI Paid'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: order.status == PaymentStatus.paid
                                ? AppColors.paid
                                : AppColors.pending,
                            side: BorderSide(
                              color: order.status == PaymentStatus.paid
                                  ? AppColors.paid
                                  : AppColors.pending,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Complete CTA Button (Locked if Cash is unpaid)
                      Expanded(
                        child: _buildCompleteButton(context),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    final bool isUnpaid = order.status != PaymentStatus.paid;

    return Container(
      decoration: BoxDecoration(
        gradient: isUnpaid
            ? const LinearGradient(
                colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
              )
            : const LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandOrange],
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isUnpaid
            ? []
            : [
                BoxShadow(
                  color: AppColors.brandRed.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isUnpaid) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              final payLabel = order.method == PaymentMethod.cash
                  ? 'Collect ₹${order.total.toStringAsFixed(0)} cash and tap "Mark Cash Paid"'
                  : 'Verify UPI payment of ₹${order.total.toStringAsFixed(0)} and tap "Verify UPI Paid"';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$payLabel before fulfilling!',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.brandRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }
            onComplete?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUnpaid
                      ? Icons.lock_outline_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isUnpaid ? 'Payment Pending' : 'Mark Done',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // COMPACT CARD (completed history)
  // --------------------------------------------------------------------------

  Widget _buildCompact(String timeStr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Token
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'P${order.tokenNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Items + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.items
                      .map((i) => '${i.quantity}× ${i.name}')
                      .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Total + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandOrange,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
