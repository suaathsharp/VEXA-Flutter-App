// ──────────────────────────────────────────────────────────────────────────
//  ORDER REPOSITORY
//  All order reads and writes go through here.
//  Current source: local mock data (OrderModel.mockOrders).
//  Firebase swap: replace methods with Firestore queries. UI never changes.
// ──────────────────────────────────────────────────────────────────────────

import 'package:flutter_application_1/data/models/order_model.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';

class OrderRepository {
  // Local cache of orders (acts as in-memory store until Firebase is added)
  final List<OrderModel> _localOrders = List.from(OrderModel.mockOrders);

  // ── Fetch all orders for current user ────────────────────────────────────
  Future<List<OrderModel>> getOrders() async {
    final uid = firebaseService.auth.currentUser?.uid;
    if (uid == null || uid == 'guest') {
      return List.unmodifiable(_localOrders);
    }
    try {
      final snap = await firebaseService.ordersRef
          .where('userId', isEqualTo: uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return OrderModel.fromMap({...data, 'id': doc.id});
        }).toList();
      }
    } catch (e) {
      print('Firestore error fetching orders, falling back: $e');
    }
    return List.unmodifiable(_localOrders);
  }

  // ── Fetch by status ──────────────────────────────────────────────────────
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    final all = await getOrders();
    return all.where((o) => o.status == status).toList();
  }

  // ── Fetch single order ───────────────────────────────────────────────────
  Future<OrderModel?> getOrderById(String id) async {
    try {
      final doc = await firebaseService.ordersRef.doc(id).get().timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
    } catch (e) {
      print('Firestore error getting order $id: $e');
    }
    try {
      return _localOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Place a new order ────────────────────────────────────────────────────
  Future<OrderModel> placeOrder(OrderModel order) async {
    final uid = firebaseService.auth.currentUser?.uid;
    if (uid == null || uid == 'guest') {
      _localOrders.insert(0, order);
      return order;
    }
    try {
      final data = order.toMap();
      data['userId'] = uid;
      print("Placing Firestore order...");
      final docRef = await firebaseService.ordersRef.add(data).timeout(const Duration(seconds: 4));
      print("Order placed successfully in Firestore");
      return OrderModel.fromMap({...data, 'id': docRef.id});
    } catch (e) {
      print("Firestore error placing order: $e");
      _localOrders.insert(0, order);
      return order;
    }
  }

  // ── Cancel order ─────────────────────────────────────────────────────────
  Future<void> cancelOrder(String orderId) async {
    try {
      print("Cancelling Firestore order...");
      await firebaseService.ordersRef.doc(orderId).update({
        'status': OrderStatus.cancelled.label,
        'deliveryInfo': 'Order cancelled',
      }).timeout(const Duration(seconds: 4));
      print("Order cancelled successfully in Firestore");
      return;
    } catch (e) {
      print("Firestore error cancelling order: $e");
    }
    
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final old = _localOrders[idx];
      _localOrders[idx] = OrderModel(
        id: old.id,
        date: old.date,
        status: OrderStatus.cancelled,
        itemCount: old.itemCount,
        total: old.total,
        productImageUrls: old.productImageUrls,
        deliveryInfo: 'Order cancelled',
      );
    }
  }
}

/// Singleton
final orderRepository = OrderRepository();
