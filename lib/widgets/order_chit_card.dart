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
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid
          ? AppColors.cash
          : AppColors.pending;
    }
    return AppColors.paid; // UPI shows paid once placed
  }

  Color get _statusBgColor {
    if (order.stage == OrderStage.completed) return AppColors.surfaceWarm;
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid
          ? AppColors.cashBg
          : AppColors.pendingBg;
    }
    return AppColors.paidBg;
  }

  String get _statusLabel {
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid ? 'Cash · Paid' : 'Cash · Pending';
    }
    return 'UPI · Paid';
  }

  IconData get _statusIcon {
    if (order.stage == OrderStage.completed) return Icons.check_circle_rounded;
    if (order.method == PaymentMethod.cash) {
      return order.status == PaymentStatus.paid
          ? Icons.payments_rounded
          : Icons.hourglass_top_rounded;
    }
    return Icons.qr_code_2_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(order.placedAt);
    return compact ? _buildCompact(timeStr) : _buildFull(timeStr);
  }

  // --------------------------------------------------------------------------
  // FULL CARD (active orders)
  // --------------------------------------------------------------------------

  Widget _buildFull(String timeStr) {
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
                        color: AppColors.brandRed.withValues(alpha: 0.35),
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
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.40),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 13, color: _statusColor),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
                      // Cash Toggle Button
                      if (order.method == PaymentMethod.cash) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onToggleCash,
                            icon: Icon(
                              order.status == PaymentStatus.paid
                                  ? Icons.check_circle_rounded
                                  : Icons.money_off_rounded,
                              size: 18,
                              color: order.status == PaymentStatus.paid
                                  ? AppColors.cash
                                  : AppColors.pending,
                            ),
                            label: Text(
                              order.status == PaymentStatus.paid
                                  ? 'Cash Paid'
                                  : 'Mark Cash Paid',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  order.status == PaymentStatus.paid
                                      ? AppColors.cash
                                      : AppColors.pending,
                              side: BorderSide(
                                color: order.status == PaymentStatus.paid
                                    ? AppColors.cash
                                    : AppColors.pending,
                                width: 1.5,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],

                      // Complete CTA Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.brandRed,
                                AppColors.brandOrange,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandRed
                                    .withValues(alpha: 0.35),
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
                              onTap: onComplete,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Mark Fulfilling Done',
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
                        ),
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
