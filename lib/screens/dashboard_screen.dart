import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/download_helper.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_tile.dart';
import 'offer_screen.dart';
import 'products_screen.dart';
import '../services/offer_manager.dart';
import '../services/api_service.dart';
import '../services/order_manager.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<OrderModel> _recentOrders = [];
  int _productCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load orders and products from API
    await Future.wait([
      OrderManager().loadOrders(),
      _loadProductStats(),
    ]);

    if (mounted) {
      setState(() {
        _recentOrders = OrderManager().orders.take(3).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductStats() async {
    try {
      final products = await ApiService.instance.getProducts();
      _productCount = products.length;
    } catch (_) {
      _productCount = 0;
    }
  }

  void _exportSalesReport(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Product Name,Category,Price (₹),Stock Status');
    // Use available data - we could also fetch products here
    buffer.writeln('Sample data,General,0,In Stock');

    final csv = buffer.toString();
    final bytes = utf8.encode(csv);
    downloadFile(bytes, 'sales_report.csv', 'text/csv');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sales report downloaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pendingOrders = OrderManager().pending.length;

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
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
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
                                label: "Orders",
                                value: OrderManager().orders.length.toString(),
                                icon: Icons.receipt_long_rounded,
                                color: colors.secondary,
                                bgColor: colors.secondary.withOpacity(0.08),
                                subtitle: "$pendingOrders pending",
                                isPositive: null,
                                colors: colors,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                label: "Products",
                                value: _productCount.toString(),
                                icon: Icons.inventory_2_rounded,
                                color: const Color(0xFF9C27B0),
                                bgColor: const Color(0xFF9C27B0).withOpacity(0.08),
                                subtitle: "in your store",
                                isPositive: null,
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
                                onTap: () async {
                                  await OfferManager().loadOffers();
                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
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
                                                  .withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Current Offers',
                                                    style: AppTextStyles.heading2
                                                        .copyWith(
                                                            color: colors.primary)),
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
                                                        title: Text(
                                                            o['title'] ?? ''),
                                                        subtitle: Text(
                                                            'Discount: ${o['discount']}, Code: ${o['code']}'),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx).pop(),
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
                        if (_recentOrders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text('No orders yet',
                                style: TextStyle(
                                    color: colors.textLight,
                                    fontSize: 13,
                                    fontFamily: 'Poppins')),
                          )
                        else
                          ..._recentOrders
                              .map((order) => OrderTile(order: order, compact: true, onChanged: () => setState(() {}))),
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
