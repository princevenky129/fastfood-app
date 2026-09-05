import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/order_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/order_chit_card.dart';

class OrderQueueScreen extends StatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends State<OrderQueueScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _repo = OrderRepository.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmClearOrders(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
            const SizedBox(width: 10),
            Text(
              'Reset Orders Database?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'This will purge all previous orders and reset the token counter back to P1 for a clean start. This cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _repo.clearAllOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order history cleared! Next order starts at P1.',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.paid,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodOrder>>(
      initialData: _repo.allOrders,
      stream: _repo.ordersStream,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? _repo.allOrders;
        final active = orders
            .where((o) => o.stage == OrderStage.active)
            .toList()
          ..sort((a, b) => a.placedAt.compareTo(b.placedAt));
        final completed = orders
            .where((o) => o.stage == OrderStage.completed)
            .toList()
          ..sort((a, b) => (b.completedAt ?? b.placedAt)
              .compareTo(a.completedAt ?? a.placedAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(active.length, onClear: () => _confirmClearOrders(context)),
            _buildPillTabBar(active.length, completed.length),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ActiveList(orders: active, repo: _repo),
                  _CompletedList(orders: completed),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------------

  Widget _buildHeader(int activeCount, {required VoidCallback onClear}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Live Kitchen Orders',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: activeCount > 0
                              ? AppColors.dangerBg
                              : AppColors.paidBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$activeCount ACTIVE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: activeCount > 0
                                ? AppColors.danger
                                : AppColors.paid,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activeCount > 0
                        ? '🔥 Orders waiting for preparation'
                        : '🎉 All orders completed & clear',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Options popup (e.g. clear order history)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (val) {
                if (val == 'clear') onClear();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Text(
                        'Reset Order Database',
                        style: GoogleFonts.inter(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
    );
  }

  // ------------------------------------------------------------------
  // PILL TAB BAR
  // ------------------------------------------------------------------

  Widget _buildPillTabBar(int activeCount, int completedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandRed, AppColors.brandOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandRed.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Active ($activeCount)'),
            Tab(text: 'Completed ($completedCount)'),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ACTIVE LIST
// ============================================================================

class _ActiveList extends StatelessWidget {
  final List<FoodOrder> orders;
  final OrderRepository repo;

  const _ActiveList({required this.orders, required this.repo});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyState(
        icon: Icons.ramen_dining_outlined,
        title: 'No active orders',
        subtitle: 'New customer orders will pop up here instantly!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: OrderChitCard(
            key: ValueKey(order.id),
            order: order,
            onComplete: () => repo.markCompleted(order.id),
            onToggleCash: () => repo.toggleCashPaid(order.id),
          ),
        );
      },
    );
  }
}

// ============================================================================
// COMPLETED LIST (Hierarchical: Month → Week → Active Days Only)
// ============================================================================

class _CompletedList extends StatelessWidget {
  final List<FoodOrder> orders;

  const _CompletedList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyState(
        icon: Icons.checklist_rounded,
        title: 'No completed orders yet',
        subtitle: 'Orders fulfilled in the kitchen will appear here organized by week and date.',
      );
    }

    final totalRevenue = orders.fold<double>(0, (sum, o) => sum + o.total);

    // Structure:
    // monthKey -> weekKey -> dayKey -> List<FoodOrder>
    final Map<String, Map<String, Map<String, List<FoodOrder>>>> grouped = {};

    for (final o in orders) {
      final dt = o.completedAt ?? o.placedAt;
      final monthKey = DateFormat('MMMM yyyy').format(dt);

      // Calculate week in month (1..5)
      final weekNum = ((dt.day - 1) ~/ 7) + 1;
      final startDay = (weekNum - 1) * 7 + 1;
      final lastDayOfMonth = DateTime(dt.year, dt.month + 1, 0).day;
      final endDay = min(weekNum * 7, lastDayOfMonth);
      final monthShort = DateFormat('MMM').format(dt);
      final weekKey = 'Week $weekNum ($monthShort $startDay - $endDay)';

      final dayKey = DateFormat('yyyy-MM-dd').format(dt);

      grouped
          .putIfAbsent(monthKey, () => {})
          .putIfAbsent(weekKey, () => {})
          .putIfAbsent(dayKey, () => [])
          .add(o);
    }

    final monthKeys = grouped.keys.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // Overall Revenue Summary Banner
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL COMPLETED REVENUE',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${totalRevenue.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${orders.length} Orders',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Months List
        ...monthKeys.map((monthKey) {
          final weeksMap = grouped[monthKey]!;
          final monthOrders = weeksMap.values
              .expand((dayMap) => dayMap.values.expand((list) => list))
              .toList();
          final monthRevenue =
              monthOrders.fold<double>(0, (sum, o) => sum + o.total);

          return _MonthGroup(
            monthTitle: monthKey,
            orderCount: monthOrders.length,
            revenue: monthRevenue,
            weeksMap: weeksMap,
          );
        }),
      ],
    );
  }
}

// ============================================================================
// MONTH GROUP WIDGET
// ============================================================================

class _MonthGroup extends StatelessWidget {
  final String monthTitle;
  final int orderCount;
  final double revenue;
  final Map<String, Map<String, List<FoodOrder>>> weeksMap;

  const _MonthGroup({
    required this.monthTitle,
    required this.orderCount,
    required this.revenue,
    required this.weeksMap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedWeekKeys = weeksMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            monthTitle,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '$orderCount orders • ₹${revenue.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: sortedWeekKeys.map((weekKey) {
            final daysMap = weeksMap[weekKey]!;
            final weekOrders =
                daysMap.values.expand((list) => list).toList();
            final weekRevenue =
                weekOrders.fold<double>(0, (sum, o) => sum + o.total);

            return _WeekGroup(
              weekTitle: weekKey,
              orderCount: weekOrders.length,
              revenue: weekRevenue,
              daysMap: daysMap,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================================
// WEEK GROUP WIDGET
// ============================================================================

class _WeekGroup extends StatelessWidget {
  final String weekTitle;
  final int orderCount;
  final double revenue;
  final Map<String, List<FoodOrder>> daysMap;

  const _WeekGroup({
    required this.weekTitle,
    required this.orderCount,
    required this.revenue,
    required this.daysMap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort days newest date first
    final sortedDayKeys = daysMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(
              Icons.date_range_rounded,
              color: AppColors.brandOrange,
              size: 16,
            ),
          ),
          title: Text(
            weekTitle,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                '$orderCount orders',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paidBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '₹${revenue.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.paid,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          children: sortedDayKeys.map((dayKey) {
            final dayOrders = daysMap[dayKey]!;
            final dayDate = DateTime.parse(dayKey);
            final dayRevenue =
                dayOrders.fold<double>(0, (sum, o) => sum + o.total);

            return _DayGroup(
              date: dayDate,
              count: dayOrders.length,
              revenue: dayRevenue,
              orders: dayOrders,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================================
// DAY GROUP WIDGET (Displays ONLY if orders came on this day!)
// ============================================================================

class _DayGroup extends StatelessWidget {
  final DateTime date;
  final int count;
  final double revenue;
  final List<FoodOrder> orders;

  const _DayGroup({
    required this.date,
    required this.count,
    required this.revenue,
    required this.orders,
  });

  String _formatDayLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today • ${DateFormat('EEEE, MMM d').format(dt)}';
    if (diff == 1) return 'Yesterday • ${DateFormat('EEEE, MMM d').format(dt)}';
    return DateFormat('EEEE, MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          title: Text(
            _formatDayLabel(date),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                '$count orders',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paidBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '₹${revenue.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.paid,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          children: orders
              .map((o) => OrderChitCard(
                    key: ValueKey(o.id),
                    order: o,
                    compact: true,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandRed, AppColors.brandOrange],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandRed.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
