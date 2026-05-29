import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/order_manager.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final bool compact;
  final VoidCallback? onStatusChanged;

  const OrderTile(
      {super.key,
      required this.order,
      required this.compact,
      this.onStatusChanged});

  Color _statusColor(OrderStatus status, ThemeColors colors) {
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

  Color _statusBg(OrderStatus status, ThemeColors colors) {
    switch (status) {
      case OrderStatus.pending:
        return colors.warningLight;
      case OrderStatus.preparing:
        return colors.primary.withValues(alpha: 0.08);
      case OrderStatus.readyForPickup:
        return colors.secondary.withValues(alpha: 0.1);
      case OrderStatus.pickedUp:
        return const Color(0xFFE3F2FD);
      case OrderStatus.outForDelivery:
        return colors.primary.withValues(alpha: 0.08);
      case OrderStatus.delivered:
        return colors.successLight;
      case OrderStatus.completed:
        return colors.successLight;
      case OrderStatus.cancelled:
        return colors.errorLight;
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping_rounded,
                          size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tracking: ${order.status.label}',
                          style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: order.items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.productName}',
                                      style: TextStyle(
                                          color: colors.textLight,
                                          fontSize: 11,
                                          fontFamily: 'Poppins')),
                                  Text(
                                      '₹${(item.quantity * item.price).toStringAsFixed(0)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textDark,
                                          fontSize: 11,
                                          fontFamily: 'Poppins')),
                                ],
                              ),
                            ))
                        .toList(),
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
              if (!compact) ...[
                const SizedBox(height: 10),
                if (order.status == OrderStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            OrderManager().reject(order);
                            onStatusChanged?.call();
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.hideCurrentSnackBar();
                            final controller = messenger.showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              content: const Text('Order rejected'),
                              action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    OrderManager().undoReject();
                                    onStatusChanged?.call();
                                  }),
                              duration: const Duration(seconds: 3),
                            ));
                            Future.delayed(const Duration(seconds: 3), () {
                              controller.close();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.error),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                          onPressed: () {
                            OrderManager().accept(order);
                            onStatusChanged?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status == OrderStatus.preparing) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        OrderManager().prepare(order);
                        onStatusChanged?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mark Ready'),
                    ),
                  ),
                ] else if (order.status == OrderStatus.readyForPickup) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        OrderManager().pickup(order);
                        onStatusChanged?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Picked Up'),
                    ),
                  ),
                ] else if (order.status == OrderStatus.pickedUp) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        OrderManager().outForDelivery(order);
                        onStatusChanged?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Out for Delivery'),
                    ),
                  ),
                ] else if (order.status == OrderStatus.outForDelivery) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        OrderManager().deliver(order);
                        onStatusChanged?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Delivered'),
                    ),
                  ),
                ],
              ],
              if (!compact &&
                  (order.status == OrderStatus.completed ||
                      order.status == OrderStatus.cancelled ||
                      order.status == OrderStatus.delivered)) ...[
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                                color: colors.border.withValues(alpha: 0.3)),
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
                      Text('₹${order.total.toStringAsFixed(0)}',
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
