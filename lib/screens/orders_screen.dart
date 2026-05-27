import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/order_tile.dart';
import '../services/order_manager.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final manager = OrderManager();
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Orders
            Text('Pending', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.pending.map((order) => OrderTile(order: order, compact: false)),
            const SizedBox(height: 24),
            // Completed Orders
            Text('Completed', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.completed.map((order) => OrderTile(order: order, compact: false)),
            const SizedBox(height: 24),
            // Rejected Orders
            Text('Rejected', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.cancelled.map((order) => OrderTile(order: order, compact: false)),
          ],
        ),
      ),
    );
  }
}
