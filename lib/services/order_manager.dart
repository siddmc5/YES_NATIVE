import '../models/models.dart';
import 'api_service.dart';

class OrderManager {
  OrderManager._privateConstructor();
  static final OrderManager _instance = OrderManager._privateConstructor();
  factory OrderManager() => _instance;

  List<OrderModel> _orders = [];
  OrderModel? _lastRejected;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// Fetch all orders from the backend.
  Future<void> loadOrders() async {
    final data = await ApiService.instance.getOrders();
    _orders = data.map((json) => _orderFromJson(json)).toList();
  }

  /// Accept an order (move to processing).
  Future<void> accept(OrderModel order) async {
    await _updateStatus(order, 'processing');
  }

  /// Mark order as shipped.
  Future<void> process(OrderModel order) async {
    await _updateStatus(order, 'shipped');
  }

  /// Mark order as delivered.
  Future<void> ship(OrderModel order) async {
    await _updateStatus(order, 'delivered');
  }

  /// Mark order as completed.
  Future<void> deliver(OrderModel order) async {
    await _updateStatus(order, 'completed');
  }

  /// Reject / cancel an order.
  Future<void> reject(OrderModel order) async {
    _lastRejected = order;
    await _updateStatus(order, 'cancelled');
  }

  /// Undo a rejection (restore to pending).
  Future<void> undoReject() async {
    if (_lastRejected != null) {
      await _updateStatus(_lastRejected!, 'pending');
      _lastRejected = null;
    }
  }

  Future<void> _updateStatus(OrderModel order, String newStatus) async {
    // Update via API first
    final success = await ApiService.instance.updateOrderStatus(
      order.orderId,
      newStatus,
    );
    if (success) {
      // Reload orders from backend to get fresh data
      await loadOrders();
    }
  }

  // Sorted getters for each status
  List<OrderModel> get pending => _sorted(_orders.where((o) => o.status == OrderStatus.pending));
  List<OrderModel> get processing => _sorted(_orders.where((o) => o.status == OrderStatus.processing));
  List<OrderModel> get shipped => _sorted(_orders.where((o) => o.status == OrderStatus.shipped));
  List<OrderModel> get delivered => _sorted(_orders.where((o) => o.status == OrderStatus.delivered));
  List<OrderModel> get completed => _sorted(_orders.where((o) => o.status == OrderStatus.completed));
  List<OrderModel> get cancelled => _sorted(_orders.where((o) => o.status == OrderStatus.cancelled));

  List<OrderModel> _sorted(Iterable<OrderModel> orders) {
    final list = orders.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Parse an OrderModel from backend JSON.
  OrderModel _orderFromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['_id'] as String? ?? json['orderId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem(
                    productName: item['productName'] as String? ?? '',
                    quantity: item['quantity'] as int? ?? 0,
                    price: (item['price'] as num?)?.toDouble() ?? 0,
                  ))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      address: json['address'] as String? ?? '',
    );
  }

  OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }
}
