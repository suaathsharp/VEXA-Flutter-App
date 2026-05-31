import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────
//  ORDER MODEL
//  Firebase-ready. When Firestore is connected:
//  use OrderModel.fromFirestore(snapshot).
// ──────────────────────────────────────────────────────────────────────────

enum OrderStatus { processing, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get badgeColor {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFFFEF3C7);
      case OrderStatus.shipped:
        return const Color(0xFFE0E7FF);
      case OrderStatus.delivered:
        return const Color(0xFFD1FAE5);
      case OrderStatus.cancelled:
        return const Color(0xFFFFE4E6);
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFF92400E);
      case OrderStatus.shipped:
        return const Color(0xFF3730A3);
      case OrderStatus.delivered:
        return const Color(0xFF065F46);
      case OrderStatus.cancelled:
        return const Color(0xFF9F1239);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.processing:
        return Icons.hourglass_top_rounded;
      case OrderStatus.shipped:
        return Icons.inventory_2_rounded;
      case OrderStatus.delivered:
        return Icons.check_box_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static OrderStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
class OrderModel {
  final String id;
  final String date;
  final OrderStatus status;
  final int itemCount;
  final String total;
  final List<String> productImageUrls;
  final String deliveryInfo;
  final String? trackingNumber;

  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.itemCount,
    required this.total,
    required this.productImageUrls,
    required this.deliveryInfo,
    this.trackingNumber,
  });

  // ── Firebase: fromMap ───────────────────────────────────────────────────
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: (map['id'] ?? map['orderId']) as String? ?? '',
      date: (map['date'] ?? map['createdAt']) as String? ?? '',
      status: OrderStatusExtension.fromString((map['status'] ?? map['orderStatus']) as String? ?? ''),
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 0,
      total: (map['total'] ?? map['totalAmount']) as String? ?? '0',
      productImageUrls: List<String>.from(map['productImageUrls'] ?? []),
      deliveryInfo: (map['deliveryInfo'] ?? map['deliveryAddress']) as String? ?? '',
      trackingNumber: map['trackingNumber'] as String?,
    );
  }

  // ── Firebase: toMap ─────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'orderId': id,
        'date': date,
        'createdAt': date,
        'status': status.label,
        'orderStatus': status.label,
        'itemCount': itemCount,
        'total': total,
        'totalAmount': total,
        'productImageUrls': productImageUrls,
        'deliveryInfo': deliveryInfo,
        'deliveryAddress': deliveryInfo,
        'trackingNumber': trackingNumber,
      };

  // ── Mock data for local development ────────────────────────────────────
  static List<OrderModel> get mockOrders => [
        const OrderModel(
          id: 'VX-99283',
          date: '18 Jan 2025',
          status: OrderStatus.processing,
          itemCount: 3,
          total: '8,700',
          productImageUrls: [
            'https://images.unsplash.com/photo-1596755094514-f87e32f08286?w=200',
            'https://images.unsplash.com/photo-1519238321852-5a21e0eb7e31?w=200',
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=200',
          ],
          deliveryInfo: 'Est. Delivery: 21–23 Jan 2025',
        ),
        const OrderModel(
          id: 'VX-88120',
          date: '12 Jan 2025',
          status: OrderStatus.delivered,
          itemCount: 1,
          total: '4,200',
          productImageUrls: [
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200',
          ],
          deliveryInfo: 'Delivered on 14 Jan 2025',
        ),
        const OrderModel(
          id: 'VX-99104',
          date: '16 Jan 2025',
          status: OrderStatus.shipped,
          itemCount: 2,
          total: '12,400',
          productImageUrls: [
            'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200',
            'https://images.unsplash.com/photo-1594938298596-eb5fd3f502ff?w=200',
          ],
          deliveryInfo: 'Arriving Tomorrow',
          trackingNumber: 'TRK-4892023',
        ),
      ];
}
