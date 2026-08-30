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
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(active.length),
            _buildPillTabBar(),
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

  Widget _buildHeader(int activeCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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

            // Demo simulate button
            GestureDetector(
              onTap: _repo.simulateIncomingOrder,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandRed, AppColors.brandOrange],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandRed.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Simulate',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // PILL TAB BAR
  // ------------------------------------------------------------------

  Widget _buildPillTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandRed, AppColors.brandOrange],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandRed.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: 'Active Queue'),
            Tab(text: 'Completed History'),
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
        subtitle:
            'New customer orders will pop up here instantly!',
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
// COMPLETED LIST
// ============================================================================

class _CompletedList extends StatelessWidget {
  final List<FoodOrder> orders;

  const _CompletedList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyState(
        icon: Icons.checklist_rounded,
        title: 'Nothing completed yet',
        subtitle: 'Orders you fulfill will appear here grouped by day.',
      );
    }

    final Map<String, List<FoodOrder>> grouped = {};
    for (final o in orders) {
      final key = DateFormat('yyyy-MM-dd').format(o.completedAt!);
      grouped.putIfAbsent(key, () => []).add(o);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, i) {
        final key = sortedKeys[i];
        final dayOrders = grouped[key]!;
        final date = DateTime.parse(key);
        final revenue =
            dayOrders.fold<double>(0, (sum, o) => sum + o.total);

        return _DateGroup(
          label: _dateLabel(date),
          count: dayOrders.length,
          revenue: revenue,
          initiallyExpanded: i == 0,
          children: dayOrders
              .map((o) => OrderChitCard(
                    key: ValueKey(o.id),
                    order: o,
                    compact: true,
                  ))
              .toList(),
        );
      },
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }
}

// ============================================================================
// DATE GROUP
// ============================================================================

class _DateGroup extends StatelessWidget {
  final String label;
  final int count;
  final double revenue;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _DateGroup({
    required this.label,
    required this.count,
    required this.revenue,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  '$count orders',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.paidBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${revenue.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.paid,
                    ),
                  ),
                ),
              ],
            ),
            iconColor: AppColors.textSecondary,
            collapsedIconColor: AppColors.textFaint,
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: children,
          ),
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
