import '../models/models.dart';

class OrderManager {
  // Singleton pattern
  OrderManager._privateConstructor();
  static final OrderManager _instance = OrderManager._privateConstructor();
  factory OrderManager() => _instance;

  final List<OrderModel> _orders = List.from(SampleData.orders);
  OrderModel? _lastRejected;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void accept(OrderModel order) {
    _updateStatus(order, OrderStatus.preparing);
  }

  void prepare(OrderModel order) {
    _updateStatus(order, OrderStatus.readyForPickup);
  }

  void pickup(OrderModel order) {
    _updateStatus(order, OrderStatus.pickedUp);
  }

  void outForDelivery(OrderModel order) {
    _updateStatus(order, OrderStatus.outForDelivery);
  }

  void deliver(OrderModel order) {
    _updateStatus(order, OrderStatus.delivered);
  }

  void complete(OrderModel order) {
    _updateStatus(order, OrderStatus.completed);
  }

  void reject(OrderModel order) {
    _lastRejected = order;
    _updateStatus(order, OrderStatus.cancelled);
  }

  void undoReject() {
    if (_lastRejected != null) {
      _updateStatus(_lastRejected!, OrderStatus.pending);
      _lastRejected = null;
    }
  }

  void _updateStatus(OrderModel order, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.orderId == order.orderId);
    if (index != -1) {
      final existing = _orders[index];
      _orders[index] = OrderModel(
        orderId: existing.orderId,
        customerName: existing.customerName,
        customerPhone: existing.customerPhone,
        items: existing.items,
        total: existing.total,
        status: newStatus,
        createdAt: existing.createdAt,
        address: existing.address,
      );
    }
  }

  // Sorted getters for each status
  List<OrderModel> get active => _sorted(_orders.where((o) =>
      o.status != OrderStatus.completed &&
      o.status != OrderStatus.cancelled &&
      o.status != OrderStatus.delivered));
  List<OrderModel> get pending =>
      _sorted(_orders.where((o) => o.status == OrderStatus.pending));
  List<OrderModel> get completed => _sorted(_orders.where((o) =>
      o.status == OrderStatus.completed || o.status == OrderStatus.delivered));
  List<OrderModel> get cancelled =>
      _sorted(_orders.where((o) => o.status == OrderStatus.cancelled));

  List<OrderModel> _sorted(Iterable<OrderModel> orders) {
    final list = orders.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
    return list;
  }
}
