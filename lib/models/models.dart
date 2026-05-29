import 'dart:typed_data';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final double rating;
  final int reviews;
  final List<String> tags;
  bool isActive;
  final String imageUrl;
  Uint8List? imageBytes;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.isActive,
    this.imageUrl = '',
    this.imageBytes,
  });
}

class OrderModel {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String address;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.address,
  });
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  completed,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Rejected';
    }
  }
}

class DashboardStats {
  final double todayRevenue;
  final int todayOrders;
  final int pendingOrders;
  final int totalProducts;
  final double monthRevenue;
  final int monthOrders;

  DashboardStats({
    required this.todayRevenue,
    required this.todayOrders,
    required this.pendingOrders,
    required this.totalProducts,
    required this.monthRevenue,
    required this.monthOrders,
  });
}

// Sample data
class SampleData {
  static List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: 'SlimSure Lite',
      category: 'Weight Management',
      price: 449,
      stock: 85,
      rating: 4.8,
      reviews: 124,
      tags: ['Low Glycemic Index', 'High Dietary Fiber'],
      isActive: true,
      imageUrl: 'assets/images/product_1.jpeg',
    ),
    ProductModel(
      id: '2',
      name: 'Black Rice Choco Malt',
      category: 'Family Health',
      price: 399,
      stock: 42,
      rating: 4.9,
      reviews: 198,
      tags: ['Rich in Antioxidants', 'Kid-Friendly'],
      isActive: true,
      imageUrl: 'assets/images/product_2.jpeg',
    ),
    ProductModel(
      id: '3',
      name: 'MilMil Junior',
      category: 'Kids Nutrition',
      price: 349,
      stock: 0,
      rating: 4.7,
      reviews: 89,
      tags: ['Calcium Rich', 'No Artificial Colors'],
      isActive: false,
    ),
    ProductModel(
      id: '4',
      name: 'Energy Millet Mix',
      category: 'Daily Energy',
      price: 299,
      stock: 120,
      rating: 4.6,
      reviews: 67,
      tags: ['Instant Energy', 'High Protein'],
      isActive: true,
    ),
    ProductModel(
      id: '5',
      name: "Women's Vitality Blend",
      category: "Women's Wellness",
      price: 499,
      stock: 28,
      rating: 4.9,
      reviews: 143,
      tags: ['Iron Rich', 'Hormonal Balance'],
      isActive: true,
    ),
    ProductModel(
      id: '6',
      name: 'NaturalNourish Porridge',
      category: 'Natural Nourishment',
      price: 329,
      stock: 67,
      rating: 4.5,
      reviews: 55,
      tags: ['Whole Grain', 'No Preservatives'],
      isActive: true,
    ),
  ];

  static List<OrderModel> orders = [
    OrderModel(
      orderId: 'YN-2024-0891',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98765 43210',
      items: [
        OrderItem(productName: 'SlimSure Lite', quantity: 2, price: 449),
        OrderItem(productName: 'Energy Millet Mix', quantity: 1, price: 299),
      ],
      total: 1197,
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      address: '12, MG Road, Bengaluru - 560001',
    ),
    OrderModel(
      orderId: 'YN-2024-0890',
      customerName: 'Ankit Mehta',
      customerPhone: '+91 87654 32109',
      items: [
        OrderItem(productName: 'Black Rice Choco Malt', quantity: 3, price: 399),
      ],
      total: 1197,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      address: '45, HSR Layout, Bengaluru - 560102',
    ),
    OrderModel(
      orderId: 'YN-2024-0889',
      customerName: 'Meena Iyer',
      customerPhone: '+91 76543 21098',
      items: [
        OrderItem(productName: "Women's Vitality Blend", quantity: 1, price: 499),
        OrderItem(productName: 'NaturalNourish Porridge', quantity: 2, price: 329),
      ],
      total: 1157,
      status: OrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      address: '8, Koramangala, Bengaluru - 560034',
    ),
    OrderModel(
      orderId: 'YN-2024-0888',
      customerName: 'Rajesh Kumar',
      customerPhone: '+91 65432 10987',
      items: [
        OrderItem(productName: 'MilMil Junior', quantity: 2, price: 349),
      ],
      total: 698,
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      address: '23, Whitefield, Bengaluru - 560066',
    ),
    OrderModel(
      orderId: 'YN-2024-0887',
      customerName: 'Sunita Reddy',
      customerPhone: '+91 54321 09876',
      items: [
        OrderItem(productName: 'SlimSure Lite', quantity: 1, price: 449),
      ],
      total: 449,
      status: OrderStatus.processing,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      address: '67, Jayanagar, Bengaluru - 560011',
    ),
    OrderModel(
      orderId: 'YN-2024-0886',
      customerName: 'Amit Desai',
      customerPhone: '+91 91234 56780',
      items: [
        OrderItem(productName: 'Black Rice Choco Malt', quantity: 2, price: 399),
      ],
      total: 798,
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      address: '19, Indiranagar, Bengaluru - 560038',
    ),
    OrderModel(
      orderId: 'YN-2024-0885',
      customerName: 'Neha Patel',
      customerPhone: '+91 99887 66554',
      items: [
        OrderItem(productName: 'Energy Millet Mix', quantity: 1, price: 299),
        OrderItem(productName: 'NaturalNourish Porridge', quantity: 1, price: 329),
      ],
      total: 628,
      status: OrderStatus.shipped,
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      address: '34, Whitefield, Bengaluru - 560066',
    ),
    OrderModel(
      orderId: 'YN-2024-0884',
      customerName: 'Rina Kapoor',
      customerPhone: '+91 98765 12345',
      items: [
        OrderItem(productName: 'MilMil Junior', quantity: 1, price: 349),
        OrderItem(productName: "Women's Vitality Blend", quantity: 1, price: 499),
      ],
      total: 848,
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      address: '90, Malleshwaram, Bengaluru - 560055',
    ),
    OrderModel(
      orderId: 'YN-2024-0883',
      customerName: 'Karthik Reddy',
      customerPhone: '+91 93456 77889',
      items: [
        OrderItem(productName: 'SlimSure Lite', quantity: 1, price: 449),
        OrderItem(productName: 'NaturalNourish Porridge', quantity: 1, price: 329),
      ],
      total: 778,
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
      address: '77, Koramangala, Bengaluru - 560034',
    ),
    OrderModel(
      orderId: 'YN-2024-0882',
      customerName: 'Rohit Sharma',
      customerPhone: '+91 90321 45678',
      items: [
        OrderItem(productName: 'Black Rice Choco Malt', quantity: 1, price: 399),
        OrderItem(productName: 'Energy Millet Mix', quantity: 2, price: 299),
      ],
      total: 997,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      address: '12, MG Road, Bengaluru - 560001',
    ),
  ];

  static DashboardStats stats = DashboardStats(
    todayRevenue: 14850,
    todayOrders: 18,
    pendingOrders: 5,
    totalProducts: 8,
    monthRevenue: 284500,
    monthOrders: 312,
  );

  static List<Map<String, dynamic>> offers = [
    {
      'title': 'Monsoon Superfoods Deal',
      'discount': '20%',
      'code': 'MONSOON20',
      'productName': 'SlimSure Lite',
    },
    {
      'title': 'Kids Special discount',
      'discount': '10%',
      'code': 'KIDS10',
      'productName': 'MilMil Junior',
    }
  ];
}
