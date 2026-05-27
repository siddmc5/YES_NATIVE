import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../widgets/order_tile.dart';
import '../services/order_manager.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = OrderManager();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Orders
            const Text('Pending', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.pending.map((order) => OrderTile(order: order, compact: false)),
            const SizedBox(height: 24),
            // Completed Orders
            const Text('Completed', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.completed.map((order) => OrderTile(order: order, compact: false)),
            const SizedBox(height: 24),
            // Rejected Orders
            const Text('Rejected', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ...manager.cancelled.map((order) => OrderTile(order: order, compact: false)),
          ],
        ),
      ),
    );
  }
}
