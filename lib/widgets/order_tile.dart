import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/order_manager.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final bool compact;

  const OrderTile({super.key, required this.order, required this.compact});

  Color _statusColor(OrderStatus status, ThemeColors colors) {
    switch (status) {
      case OrderStatus.pending:
        return colors.warning;
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3);
      case OrderStatus.processing:
        return colors.secondary;
      case OrderStatus.shipped:
        return colors.primary;
      case OrderStatus.delivered:
        return colors.success;
      case OrderStatus.cancelled:
        return colors.error;
      case OrderStatus.completed:
        return colors.success;
    }
  }

  Color _statusBg(OrderStatus status, ThemeColors colors) {
    switch (status) {
      case OrderStatus.pending:
        return colors.warningLight;
      case OrderStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case OrderStatus.processing:
        return colors.secondary.withOpacity(0.1);
      case OrderStatus.shipped:
        return colors.primary.withOpacity(0.08);
      case OrderStatus.delivered:
        return colors.successLight;
      case OrderStatus.cancelled:
        return colors.errorLight;
      case OrderStatus.completed:
        return colors.successLight;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showOrderDetails(context, colors),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order ID and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderId,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(order.status, colors),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(order.status, colors),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Customer row
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: colors.textLight),
                  const SizedBox(width: 4),
                  Text(order.customerName,
                      style: TextStyle(
                          color: colors.textMedium,
                          fontSize: 13,
                          fontFamily: 'Poppins')),
                  const Spacer(),
                  Text(_timeAgo(order.createdAt),
                      style: TextStyle(
                          color: colors.textLight,
                          fontSize: 11,
                          fontFamily: 'Poppins')),
                ],
              ),
              // Optional expanded details
              if (!compact) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: colors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.address,
                        style: TextStyle(
                            color: colors.textLight,
                            fontSize: 11,
                            fontFamily: 'Poppins'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.productName}',
                              style: TextStyle(
                                  color: colors.textLight,
                                  fontSize: 11,
                                  fontFamily: 'Poppins')),
                          Text('₹${(item.quantity * item.price).toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colors.textDark,
                                  fontSize: 11,
                                  fontFamily: 'Poppins')),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Item count and total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 11,
                        fontFamily: 'Poppins'),
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark,
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
              // Action buttons based on order status
              if (!compact && order.status == OrderStatus.pending) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await OrderManager().reject(order);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Order rejected'),
                              action: SnackBarAction(label: 'Undo', onPressed: () async {
                                await OrderManager().undoReject();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                }
                              }),
                              duration: const Duration(seconds: 5),
                            ));
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.error),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Reject',
                            style: TextStyle(
                                color: colors.error,
                                fontFamily: 'Poppins',
                                fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await OrderManager().accept(order);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Order accepted, now processing')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact && order.status == OrderStatus.processing) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await OrderManager().process(order);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Order moved to shipped')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Ship'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact && order.status == OrderStatus.shipped) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await OrderManager().ship(order);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Order moved to delivered')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Deliver'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact && order.status == OrderStatus.delivered) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await OrderManager().deliver(order);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order completed')));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact &&
                  (order.status == OrderStatus.completed ||
                      order.status == OrderStatus.cancelled)) ...[
                const SizedBox(height: 10),
                Text('No further actions',
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 11,
                        fontFamily: 'Poppins')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                        fontFamily: 'Poppins')),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(order.status, colors),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status, colors),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Customer details
            _DetailRow(
                icon: Icons.person_outline,
                label: 'Customer',
                value: order.customerName,
                colors: colors),
            _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: order.customerPhone,
                colors: colors),
            _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: order.address,
                colors: colors),
            const SizedBox(height: 20),
            // Order items header
            Text('Order Items',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textDark,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...order.items.map((item) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: colors.border.withOpacity(0.3)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.quantity}x ${item.productName}',
                                style: TextStyle(
                                    color: colors.textMedium,
                                    fontSize: 13,
                                    fontFamily: 'Poppins')),
                            Text(
                                '₹${(item.quantity * item.price).toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textDark,
                                    fontSize: 13,
                                    fontFamily: 'Poppins')),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textDark,
                              fontFamily: 'Poppins')),
                      Text(
                          '₹${order.total.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeColors colors;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: colors.textLight,
                      fontSize: 11,
                      fontFamily: 'Poppins')),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colors.textDark,
                      fontFamily: 'Poppins',
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
