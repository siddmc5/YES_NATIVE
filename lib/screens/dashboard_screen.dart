import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_tile.dart';
import 'offer_screen.dart';
import 'products_screen.dart';
import '../services/offer_manager.dart';
import 'dart:ui';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = SampleData.stats;
    final recentOrders = SampleData.orders.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Flat header — no floating/collapse effect
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.bannerGreen,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good morning,',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Text(
                          'Yes Native Store 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF52A447),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Store Online',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Overview", style: AppTextStyles.heading2),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: "Revenue",
                          value: "₹${stats.todayRevenue.toStringAsFixed(0)}",
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.primary,
                          bgColor: AppColors.primary.withOpacity(0.08),
                          subtitle: "+12% vs yesterday",
                          isPositive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: "Orders",
                          value: stats.todayOrders.toString(),
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.secondary,
                          bgColor: AppColors.secondary.withOpacity(0.08),
                          subtitle: "${stats.pendingOrders} pending",
                          isPositive: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: "Month Revenue",
                          value:
                              "₹${(stats.monthRevenue / 1000).toStringAsFixed(1)}K",
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF2196F3),
                          bgColor: const Color(0xFF2196F3).withOpacity(0.08),
                          subtitle: "${stats.monthOrders} orders",
                          isPositive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: "Products",
                          value: stats.totalProducts.toString(),
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF9C27B0),
                          bgColor: const Color(0xFF9C27B0).withOpacity(0.08),
                          subtitle: "1 out of stock",
                          isPositive: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text("Quick Actions", style: AppTextStyles.heading2),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickAction(
                          icon: Icons.add_box_outlined,
                          label: 'Add\nProduct',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProductsScreen()),
                            );
                          }),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.discount_outlined,
                          label: 'Create\nOffer',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const OfferScreen()),
                            );
                          }),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.download_outlined,
                          label: 'Export\nReport',
                          onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Export Report'),
                                  content: const Text('Select format to download'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Report downloaded as CSV (demo)')),
                                        );
                                      },
                                      child: const Text('CSV'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Report downloaded as Excel (demo)')),
                                        );
                                      },
                                      child: const Text('Excel'),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.local_offer_outlined,
                          label: 'Current\nOffers',
                          onTap: () {
            showDialog(
            context: context,
            builder: (ctx) => Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Current Offers', style: AppTextStyles.heading2.copyWith(color: AppColors.bannerGreen)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: OfferManager().offers.length,
                            itemBuilder: (ctx, i) {
                              final o = OfferManager().offers[i];
                              return ListTile(
                                title: Text(o['title'] ?? ''),
                                subtitle: Text('Discount: ${o['discount']}, Code: ${o['code']}'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
                          }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Orders",
                          style: AppTextStyles.heading2),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recentOrders
                      .map((order) => OrderTile(order: order, compact: true)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                  fontFamily: 'Poppins',
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
