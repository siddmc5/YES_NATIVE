import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/order_tile.dart';
import '../services/order_manager.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final manager = OrderManager();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Completed'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active / pending tab (shows all active stages before completion)
          RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: manager.active
                  .map((order) => OrderTile(
                        order: order,
                        compact: false,
                        onStatusChanged: _refresh,
                      ))
                  .toList(),
            ),
          ),

          // Completed tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: manager.completed
                .map((order) => OrderTile(order: order, compact: false))
                .toList(),
          ),

          // Rejected tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: manager.cancelled
                .map((order) => OrderTile(
                      order: order,
                      compact: false,
                      onStatusChanged: _refresh,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
