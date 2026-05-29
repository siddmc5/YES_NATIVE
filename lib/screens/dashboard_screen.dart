import 'package:flutter/material.dart';
import 'dart:html' as html;
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

  void _exportSalesReport(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Product Name,Category,Price (₹),Units Sold,Revenue (₹),Stock Status');
    for (final p in SampleData.products) {
      final unitsSold = p.reviews;
      final revenue = (p.price * unitsSold * 0.3).toStringAsFixed(0);
      final stockStatus = p.stock == 0 ? 'Out of Stock' : (p.stock <= 20 ? 'Low' : 'In Stock');
      buffer.writeln('"${p.name}","${p.category}",${p.price.toStringAsFixed(0)},$unitsSold,$revenue,$stockStatus');
    }

    final csv = buffer.toString();
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'sales_report.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sales report downloaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stats = SampleData.stats;
    final recentOrders = SampleData.orders.take(3).toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Flat header
          SliverToBoxAdapter(
            child: Container(
              color: colors.bannerGreen,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning,',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
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
                      color: Colors.white.withValues(alpha: 0.15),
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
                  Text("Today's Overview",
                      style: AppTextStyles.heading2.copyWith(
                          color: colors.primary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: "Revenue",
                          value: "₹${stats.todayRevenue.toStringAsFixed(0)}",
                          icon: Icons.currency_rupee_rounded,
                          color: colors.primary,
                          bgColor: colors.primary.withValues(alpha: 0.08),
                          subtitle: "+12% vs yesterday",
                          isPositive: true,
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: "Orders",
                          value: stats.todayOrders.toString(),
                          icon: Icons.receipt_long_rounded,
                          color: colors.secondary,
                          bgColor: colors.secondary.withValues(alpha: 0.08),
                          subtitle: "${stats.pendingOrders} pending",
                          isPositive: null,
                          colors: colors,
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
                          bgColor: const Color(0xFF2196F3).withValues(alpha: 0.08),
                          subtitle: "${stats.monthOrders} orders",
                          isPositive: true,
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: "Products",
                          value: stats.totalProducts.toString(),
                          icon: Icons.inventory_2_rounded,
                          color: const Color(0xFF9C27B0),
                          bgColor: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                          subtitle: "1 out of stock",
                          isPositive: false,
                          colors: colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text("Quick Actions",
                      style: AppTextStyles.heading2.copyWith(
                          color: colors.primary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickAction(
                          icon: Icons.add_box_outlined,
                          label: 'Add\nProduct',
                          colors: colors,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProductsScreen()),
                            );
                          }),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.discount_outlined,
                          label: 'Create\nOffer',
                          colors: colors,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OfferScreen()),
                            );
                          }),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.download_outlined,
                          label: 'Export\nReport',
                          colors: colors,
                          onTap: () => _exportSalesReport(context)),
                      const SizedBox(width: 10),
                      _QuickAction(
                          icon: Icons.local_offer_outlined,
                          label: 'Current\nOffers',
                          colors: colors,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => Dialog(
                                insetPadding: const EdgeInsets.all(20),
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colors.cardBackground
                                            .withValues(alpha: 0.9),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: StatefulBuilder(
                                        builder: (innerCtx, setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Current Offers',
                                                  style: AppTextStyles.heading2
                                                      .copyWith(
                                                          color:
                                                              colors.primary)),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.maxFinite,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: OfferManager()
                                                      .offers
                                                      .length,
                                                  itemBuilder: (ctx, i) {
                                                    final o = OfferManager()
                                                        .offers[i];
                                                    return ListTile(
                                                      title:
                                                          Text(o['title'] ?? ''),
                                                      subtitle: Text(
                                                          'Discount: ${o['discount']}, Code: ${o['code']}'),
                                                      trailing: IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          OfferManager()
                                                              .removeOfferAt(i);
                                                          setState(() {});
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(const SnackBar(
                                                                  content: Text(
                                                                      'Offer removed (demo)')));
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(dCtx).pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
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
                      Text("Recent Orders",
                          style: AppTextStyles.heading2.copyWith(
                              color: colors.primary)),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: TextStyle(
                            color: colors.primary,
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
  final ThemeColors colors;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.colors,
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
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: colors.textMedium,
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
