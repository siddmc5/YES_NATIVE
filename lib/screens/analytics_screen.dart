import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_pkg hide Border;
import '../theme.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  void _downloadCSV(BuildContext context) {
    final orders = SampleData.orders;
    final buffer = StringBuffer();
    buffer.writeln('Order ID,Customer,Phone,Items,Total (₹),Status,Date,Address');
    for (final o in orders) {
      final itemsStr = o.items.map((i) => '${i.quantity}x ${i.productName}').join('; ');
      final date = o.createdAt.toIso8601String().split('T')[0];
      buffer.writeln('"${o.orderId}","${o.customerName}","${o.customerPhone}","$itemsStr",${o.total.toStringAsFixed(0)},"${o.status.label}",$date,"${o.address}"');
    }

    final csv = buffer.toString();
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'transactions.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloaded')),
    );
  }

  void _downloadExcel(BuildContext context) {
    final orders = SampleData.orders;
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

    final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'transactions.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloaded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                      Text('₹2,84,500',
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
            ...SampleData.products
                .where((p) => p.isActive)
                .take(4)
                .toList()
                .asMap()
                .entries
                .map((e) => _TopProductTile(
                      rank: e.key + 1,
                      product: e.value,
                      colors: colors,
                    )),
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
            ...SampleData.orders
                .map((order) => _TransactionTile(order: order, colors: colors)),
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
                  _CategoryBar(
                      label: 'Weight Management',
                      percent: 0.35,
                      color: colors.primary,
                      colors: colors),
                  const SizedBox(height: 12),
                  _CategoryBar(
                      label: 'Family Health',
                      percent: 0.28,
                      color: colors.secondary,
                      colors: colors),
                  const SizedBox(height: 12),
                  _CategoryBar(
                      label: "Women's Wellness",
                      percent: 0.20,
                      color: const Color(0xFF9C27B0),
                      colors: colors),
                  const SizedBox(height: 12),
                  _CategoryBar(
                      label: 'Daily Energy',
                      percent: 0.17,
                      color: const Color(0xFF2196F3),
                      colors: colors),
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
                    value: '₹912',
                    change: '+8.2%',
                    isPositive: true,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Return Rate',
                    value: '2.1%',
                    change: '-0.3%',
                    isPositive: true,
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
                    label: 'New Customers',
                    value: '147',
                    change: '+22%',
                    isPositive: true,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Repeat Buyers',
                    value: '63%',
                    change: '+5%',
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
  final ThemeColors colors;

  const _TopProductTile({
    required this.rank,
    required this.product,
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
                '₹${(product.price * product.reviews * 0.3).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
              Text('${product.reviews} sold',
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
      case OrderStatus.preparing:
        return Icons.kitchen_rounded;
      case OrderStatus.readyForPickup:
        return Icons.shopping_bag_rounded;
      case OrderStatus.pickedUp:
        return Icons.handshake_rounded;
      case OrderStatus.outForDelivery:
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
      case OrderStatus.preparing:
        return colors.primary;
      case OrderStatus.readyForPickup:
        return colors.secondary;
      case OrderStatus.pickedUp:
        return const Color(0xFF1976D2);
      case OrderStatus.outForDelivery:
        return colors.primary;
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
