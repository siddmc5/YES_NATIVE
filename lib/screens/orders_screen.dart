import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/order_tile.dart';
import '../services/order_manager.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderManager _manager = OrderManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    await _manager.loadOrders();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending Orders
                    Text('Pending', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    if (_manager.pending.isEmpty)
                      _emptyState(colors, 'No pending orders')
                    else
                      ..._manager.pending
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                    const SizedBox(height: 24),

                    // Processing / Shipped
                    Text('In Progress', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    if (_manager.processing.isEmpty &&
                        _manager.shipped.isEmpty &&
                        _manager.delivered.isEmpty)
                      _emptyState(colors, 'No orders in progress')
                    else ...[
                      ..._manager.processing
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                      ..._manager.shipped
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                      ..._manager.delivered
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                    ],
                    const SizedBox(height: 24),

                    // Completed Orders
                    Text('Completed', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    if (_manager.completed.isEmpty)
                      _emptyState(colors, 'No completed orders')
                    else
                      ..._manager.completed
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                    const SizedBox(height: 24),

                    // Cancelled Orders
                    Text('Cancelled', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    if (_manager.cancelled.isEmpty)
                      _emptyState(colors, 'No cancelled orders')
                    else
                      ..._manager.cancelled
                          .map((order) => OrderTile(
                              order: order, compact: false)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _emptyState(ThemeColors colors, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(message,
          style: TextStyle(
              color: colors.textLight,
              fontSize: 13,
              fontFamily: 'Poppins')),
    );
  }
}
