import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/order_manager.dart';

class OrderTile extends StatelessWidget {
  final OrderModel order;
  final bool compact;

  const OrderTile({super.key, required this.order, required this.compact});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3);
      case OrderStatus.processing:
        return AppColors.secondary;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.completed:
        return AppColors.success;
    }
  }

  Color _statusBg(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warningLight;
      case OrderStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case OrderStatus.processing:
        return AppColors.secondary.withOpacity(0.1);
      case OrderStatus.shipped:
        return AppColors.primary.withOpacity(0.08);
      case OrderStatus.delivered:
        return AppColors.successLight;
      case OrderStatus.cancelled:
        return AppColors.errorLight;
      case OrderStatus.completed:
        return AppColors.successLight;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showOrderDetails(context),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(order.status),
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
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(order.customerName, style: AppTextStyles.body),
                  const Spacer(),
                  Text(_timeAgo(order.createdAt), style: AppTextStyles.bodySmall),
                ],
              ),
              // Optional expanded details
              if (!compact) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.address,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.productName}', style: AppTextStyles.bodySmall),
                          Text('₹${(item.quantity * item.price).toStringAsFixed(0)}',
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark)),
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
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '₹${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Poppins'),
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
                        onPressed: () {
                          OrderManager().reject(order);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Order rejected'),
                            action: SnackBarAction(label: 'Undo', onPressed: () => OrderManager().undoReject()),
                            duration: const Duration(seconds: 5),
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reject', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins', fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          OrderManager().accept(order);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order accepted, now processing')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
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
                        onPressed: () {
                          OrderManager().process(order);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order moved to shipped')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
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
                        onPressed: () {
                          OrderManager().ship(order);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order moved to delivered')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
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
                        onPressed: () {
                          OrderManager().deliver(order);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order completed')));
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!compact && (order.status == OrderStatus.completed || order.status == OrderStatus.cancelled)) ...[
                const SizedBox(height: 10),
                const Text('No further actions', style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderId, style: AppTextStyles.heading2),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.person_outline, label: 'Customer', value: order.customerName),
            _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: order.customerPhone),
            _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: order.address),
            const SizedBox(height: 16),
            const Text('Order Items', style: AppTextStyles.heading3),
            const SizedBox(height: 10),
                            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.productName}', style: AppTextStyles.bodySmall),
                      Text('₹${(item.quantity * item.price).toStringAsFixed(0)}',
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                  ),
                )).toList(),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total', style: AppTextStyles.heading3),
              Text('₹\${order.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Poppins')),
            ]),
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

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(value, style: AppTextStyles.heading3),
          ]),
        ],
      ),
    );
  }
}
