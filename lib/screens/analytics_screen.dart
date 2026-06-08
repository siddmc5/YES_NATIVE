import 'dart:convert';
import '../utils/download_helper.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_pkg hide Border;
import '../theme.dart';
import '../models/models.dart';

import '../services/order_manager.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    OrderManager().addListener(_onOrdersChanged);
  }

  @override
  void dispose() {
    OrderManager().removeListener(_onOrdersChanged);
    super.dispose();
  }

  void _onOrdersChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProducts() async {
    try {
      final data = await ApiService.instance.getProducts();
      if (mounted) {
        setState(() {
          _products = data.map((json) => ProductModel(
            id: json['_id'] as String? ?? json['id'] as String? ?? '',
            name: json['name'] as String? ?? '',
            category: json['category'] as String? ?? '',
            price: (json['price'] as num?)?.toDouble() ?? 0,
            stock: json['stock'] as int? ?? 0,
            rating: (json['rating'] as num?)?.toDouble() ?? 0,
            reviews: json['reviews'] as int? ?? 0,
            tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
            isActive: json['isActive'] as bool? ?? true,
            imageUrl: json['imageUrl'] as String? ?? '',
          )).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _downloadCSV(BuildContext context) {
    final orders = OrderManager().orders;
    final buffer = StringBuffer();
    buffer.writeln('Order ID,Customer,Phone,Items,Total (₹),Status,Date,Address');
    for (final o in orders) {
      final itemsStr = o.items.map((i) => '${i.quantity}x ${i.productName}').join('; ');
      final date = o.createdAt.toIso8601String().split('T')[0];
      buffer.writeln('"${o.orderId}","${o.customerName}","${o.customerPhone}","$itemsStr",${o.total.toStringAsFixed(0)},"${o.status.label}",$date,"${o.address}"');
    }

    final csv = buffer.toString();
    final bytes = utf8.encode(csv);
    downloadFile(bytes, 'transactions.csv', 'text/csv');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloaded')),
    );
  }

  void _downloadExcel(BuildContext context) {
    final orders = OrderManager().orders;
    final excel = excel_pkg.Excel.createExcel();
    final sheet = excel['Transactions'];

    sheet.appendRow([
      excel_pkg.TextCellValue('Order ID'),
      excel_pkg.TextCellValue('Customer'),
      excel_pkg.TextCellValue('Phone'),
      excel_pkg.TextCellValue('Items'),
      excel_pkg.TextCellValue('Total (₹)'),
      excel_pkg.TextCellValue('Status'),
      excel_pkg.TextCellValue('Date'),
      excel_pkg.TextCellValue('Address'),
    ]);

    for (final o in orders) {
      final itemsStr = o.items.map((i) => '${i.quantity}x ${i.productName}').join(', ');
      final date = o.createdAt.toIso8601String().split('T')[0];
      sheet.appendRow([
        excel_pkg.TextCellValue(o.orderId),
        excel_pkg.TextCellValue(o.customerName),
        excel_pkg.TextCellValue(o.customerPhone),
        excel_pkg.TextCellValue(itemsStr),
        excel_pkg.TextCellValue('₹${o.total.toStringAsFixed(0)}'),
        excel_pkg.TextCellValue(o.status.label),
        excel_pkg.TextCellValue(date),
        excel_pkg.TextCellValue(o.address),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) return;

    downloadFile(bytes, 'transactions.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final orders = OrderManager().orders;
    
    // Compute Real Data Analytics
    double totalRevenue = 0;
    for (var o in orders) {
      if (o.status == OrderStatus.completed || o.status == OrderStatus.delivered) {
        totalRevenue += o.total;
      }
    }

    // Top Selling Products (computed from orders)
    Map<String, int> productSales = {};
    for (var o in orders) {
      if (o.status == OrderStatus.completed || o.status == OrderStatus.delivered || o.status == OrderStatus.shipped) {
        for (var item in o.items) {
          productSales[item.productName] = (productSales[item.productName] ?? 0) + item.quantity;
        }
      }
    }
    
    var sortedProducts = productSales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topSelling = sortedProducts.take(4).map((entry) {
      // Find matching product model or create a dummy one for UI
      var p = _products.firstWhere((p) => p.name == entry.key, 
          orElse: () => ProductModel(id: '', name: entry.key, category: 'Uncategorized', price: 0, stock: 0, rating: 0, reviews: 0, tags: [], isActive: true, imageUrl: ''));
      return {'product': p, 'sales': entry.value};
    }).toList();

    // Sales by Category
    Map<String, double> categorySales = {};
    for (var o in orders) {
      if (o.status == OrderStatus.completed || o.status == OrderStatus.delivered || o.status == OrderStatus.shipped) {
        for (var item in o.items) {
          var p = _products.firstWhere((p) => p.name == item.productName, orElse: () => ProductModel(id: '', name: '', category: 'Other', price: 0, stock: 0, rating: 0, reviews: 0, tags: [], isActive: true, imageUrl: ''));
          categorySales[p.category] = (categorySales[p.category] ?? 0) + (item.quantity * item.price);
        }
      }
    }
    
    double totalCatRevenue = categorySales.values.fold(0, (a, b) => a + b);
    var sortedCategories = categorySales.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topCategories = sortedCategories.take(4).toList();

    int newCustomers = orders.map((o) => o.customerPhone).toSet().length;
    int totalCustomers = orders.length;
    double repeatBuyersRate = totalCustomers > 0 ? ((totalCustomers - newCustomers) / totalCustomers * 100) : 0;
    
    int returnCount = orders.where((o) => o.status == OrderStatus.cancelled).length;
    double returnRate = orders.isNotEmpty ? (returnCount / orders.length * 100) : 0;
    double avgOrderValue = orders.isNotEmpty ? (orders.map((o) => o.total).fold(0.0, (a, b) => a + b) / orders.length) : 0;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: 'This Month',
              underline: const SizedBox(),
              isDense: true,
              style: TextStyle(
                color: colors.primary,
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: ['This Week', 'This Month', 'This Year']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue chart placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Revenue Trend',
                          style: AppTextStyles.heading3.copyWith(color: colors.textDark)),
                      Text('₹${totalRevenue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                            fontFamily: 'Poppins',
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('May 2024',
                      style: TextStyle(color: colors.textLight, fontSize: 12, fontFamily: 'Poppins')),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Bar(height: 0.4, label: 'W1', color: colors),
                        _Bar(height: 0.65, label: 'W2', color: colors),
                        _Bar(height: 0.5, label: 'W3', color: colors),
                        _Bar(height: 0.9, label: 'W4', highlight: true, color: colors),
                        _Bar(height: 0.7, label: 'W5', color: colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Top products
            Text('Top Selling Products', style: AppTextStyles.heading2.copyWith(color: colors.textDark)),
            const SizedBox(height: 14),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (topSelling.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No sales data available yet.', style: TextStyle(color: colors.textMedium, fontFamily: 'Poppins')),
              )
            else
              ...topSelling.asMap().entries.map((e) {
                final product = e.value['product'] as ProductModel;
                final sales = e.value['sales'] as int;
                return _TopProductTile(
                  rank: e.key + 1,
                  product: product,
                  sales: sales,
                  colors: colors,
                );
              }),
            const SizedBox(height: 20),

            // Recent Transactions + Export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: AppTextStyles.heading2.copyWith(color: colors.textDark)),
                Row(
                  children: [
                    _ExportButton(
                      icon: Icons.table_chart_outlined,
                      label: 'CSV',
                      color: colors.primary,
                      onTap: () => _downloadCSV(context),
                    ),
                    const SizedBox(width: 8),
                    _ExportButton(
                      icon: Icons.grid_on_rounded,
                      label: 'Excel',
                      color: colors.secondary,
                      onTap: () => _downloadExcel(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No transactions yet.', style: TextStyle(color: colors.textMedium, fontFamily: 'Poppins')),
              )
            else
              ...orders.take(5).map((order) => _TransactionTile(order: order, colors: colors)),
            const SizedBox(height: 20),

            // Sales by category
            Text('Sales by Category',
                style: AppTextStyles.heading2.copyWith(color: colors.textDark)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (topCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('No category data available yet.', style: TextStyle(color: colors.textMedium, fontFamily: 'Poppins')),
                    )
                  else
                    ...topCategories.map((e) {
                      final percent = totalCatRevenue > 0 ? e.value / totalCatRevenue : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CategoryBar(
                          label: e.key.isEmpty ? 'Other' : e.key,
                          percent: percent,
                          color: colors.primary,
                          colors: colors,
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Key metrics
            Text('Key Metrics',
                style: AppTextStyles.heading2.copyWith(color: colors.textDark)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Avg Order Value',
                    value: '₹${avgOrderValue.toStringAsFixed(0)}',
                    change: '',
                    isPositive: true,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Return Rate',
                    value: '${returnRate.toStringAsFixed(1)}%',
                    change: '',
                    isPositive: false,
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Unique Customers',
                    value: '$newCustomers',
                    change: '',
                    isPositive: true,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Repeat Buyers',
                    value: '${repeatBuyersRate.toStringAsFixed(1)}%',
                    change: '',
                    isPositive: true,
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  final bool highlight;
  final ThemeColors color;

  const _Bar({
    required this.height,
    required this.label,
    this.highlight = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 40,
              height: 100 * height,
              decoration: BoxDecoration(
                color: highlight
                    ? color.primary
                    : color.primary.withValues(alpha: 0.25),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color.textLight,
                fontFamily: 'Poppins')),
      ],
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final int rank;
  final ProductModel product;
  final int sales;
  final ThemeColors colors;

  const _TopProductTile({
    required this.rank,
    required this.product,
    required this.sales,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.amber.shade50
                  : colors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: rank == 1
                      ? Colors.amber.shade700
                      : colors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: AppTextStyles.heading3.copyWith(color: colors.textDark)),
                Text(product.category,
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 12,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(product.price * sales).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
              Text('$sales sold',
                  style: TextStyle(
                      color: colors.textLight,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final OrderModel order;
  final ThemeColors colors;

  const _TransactionTile({required this.order, required this.colors});

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.kitchen_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.completed:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return colors.warning;
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3);
      case OrderStatus.processing:
        return colors.primary;
      case OrderStatus.shipped:
        return colors.secondary;
      case OrderStatus.delivered:
        return colors.success;
      case OrderStatus.completed:
        return colors.success;
      case OrderStatus.cancelled:
        return colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(order.status),
              size: 28, color: _statusColor(order.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.customerName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textDark,
                        fontFamily: 'Poppins',
                        fontSize: 13)),
                Text(order.orderId,
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 11,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${order.total.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                      fontFamily: 'Poppins',
                      fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(order.status),
                    fontFamily: 'Poppins',
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

class _CategoryBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final ThemeColors colors;

  const _CategoryBar({
    required this.label,
    required this.percent,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: colors.textMedium,
                    fontFamily: 'Poppins',
                    fontSize: 13)),
            Text('${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Poppins',
                    fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: colors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final ThemeColors colors;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: colors.textLight,
                  fontSize: 11,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textDark,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          if (change.isNotEmpty)
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? colors.success : colors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? colors.success : colors.error,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
