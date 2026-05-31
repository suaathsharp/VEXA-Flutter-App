// ──────────────────────────────────────────────────────────────────────────
//  APP DATA STORE  —  Single Source of Truth
//  This is the ONLY ChangeNotifier the UI listens to.
//  All state mutations go through this class.
//
//  Flow: UI → AppDataStore → Repository → Service → (Local | Firebase)
// ──────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/models/order_model.dart';
import 'package:flutter_application_1/data/repositories/product_repository.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/repositories/order_repository.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';
import 'package:flutter_application_1/data/services/activity_log_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDataStore extends ChangeNotifier {
  // ── Repositories ─────────────────────────────────────────────────────────
  final ProductRepository _productRepo;
  final UserRepository _userRepo;
  final OrderRepository _orderRepo;

  AppDataStore({
    ProductRepository? productRepository,
    UserRepository? userRepository,
    OrderRepository? orderRepository,
  })  : _productRepo = productRepository ?? productRepository_,
        _userRepo = userRepository ?? userRepository_,
        _orderRepo = orderRepository ?? orderRepository_;

  // ──────────────────────────────────────────────────────────────────────────
  //  STATE
  // ──────────────────────────────────────────────────────────────────────────

  // User
  UserModel _user = UserModel.guest;
  UserModel get user => _user;

  // Products (catalog)
  List<ProductModel> _products = [];
  List<ProductModel> get products => List.unmodifiable(_products);

  // Wishlist (IDs only for O(1) lookup)
  final Set<String> _wishlistIds = {};
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  List<ProductModel> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  // Cart (reuses existing CartModel — kept for compatibility with existing UI)
  final CartModel cart = cartModel; // bridges existing global to store

  // Orders
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  // Loading & error state
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Stream Subscriptions ──────────────────────────────────────────────────
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  StreamSubscription<DocumentSnapshot>? _wishlistSubscription;
  StreamSubscription<DocumentSnapshot>? _cartSubscription;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  // ──────────────────────────────────────────────────────────────────────────
  //  STREAM LIFECYCLE MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  void _cancelUserSubscriptions() {
    print('[REALTIME_STREAMS] Cancelling all active user stream subscriptions...');
    _userSubscription?.cancel();
    _userSubscription = null;
    _wishlistSubscription?.cancel();
    _wishlistSubscription = null;
    _cartSubscription?.cancel();
    _cartSubscription = null;
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
  }

  void _setupUserSubscriptions(String uid) {
    _cancelUserSubscriptions();
    if (uid == 'guest') return;

    print('[REALTIME_STREAMS] Setting up user-specific streams for UID: $uid');

    // 1. User Profile Real-Time Stream
    _userSubscription = firebaseService.usersRef.doc(uid).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        print('[REALTIME_STREAMS] User Profile updated dynamically via Firestore.');
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    }, onError: (e) => print('[REALTIME_STREAMS_ERROR] User stream error: $e'));

    // 2. Wishlist Real-Time Stream
    _wishlistSubscription = firebaseService.wishlistRef.doc(uid).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        print('[REALTIME_STREAMS] Wishlist updated dynamically via Firestore.');
        final data = doc.data() as Map<String, dynamic>;
        final ids = List<String>.from(data['productIds'] ?? []);
        _wishlistIds.clear();
        _wishlistIds.addAll(ids);
        notifyListeners();
      }
    }, onError: (e) => print('[REALTIME_STREAMS_ERROR] Wishlist stream error: $e'));

    // 3. Cart Real-Time Stream
    _cartSubscription = firebaseService.firestore.collection('cart').doc(uid).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        print('[REALTIME_STREAMS] Cart updated dynamically via Firestore.');
        final data = doc.data() as Map<String, dynamic>;
        final itemsList = data['items'] as List? ?? [];
        cart.loadFromMapList(itemsList, _products);
      }
    }, onError: (e) => print('[REALTIME_STREAMS_ERROR] Cart stream error: $e'));

    // 4. Orders Real-Time Stream
    _ordersSubscription = firebaseService.ordersRef
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      print('[REALTIME_STREAMS] Orders updated dynamically via Firestore. DocCount: ${snap.docs.length}');
      final fetched = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromMap({...data, 'id': doc.id});
      }).toList();
      _orders = fetched;
      notifyListeners();
    }, onError: (e) => print('[REALTIME_STREAMS_ERROR] Orders stream error: $e'));
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  INITIALIZATION
  // ──────────────────────────────────────────────────────────────────────────

  // ── Sync Wishlist to Firestore ───────────────────────────────────────────
  Future<void> _syncWishlistToFirestore() async {
    if (_user.id == 'guest') return;
    try {
      print("Syncing Firestore wishlist...");
      await firebaseService.wishlistRef.doc(_user.id).set({
        'productIds': _wishlistIds.toList(),
      }).timeout(const Duration(seconds: 4));
      print("Wishlist synced successfully in Firestore");
    } catch (e) {
      print("Firestore wishlist sync error: $e");
    }
  }

  // ── Sync Cart to Firestore ───────────────────────────────────────────────
  Future<void> _syncCartToFirestore() async {
    if (_user.id == 'guest') return;
    try {
      print("Syncing Firestore cart...");
      await firebaseService.firestore.collection('cart').doc(_user.id).set({
        'items': cart.toMapList(),
      }).timeout(const Duration(seconds: 4));
      print("Cart synced successfully in Firestore");
    } catch (e) {
      print("Firestore cart sync error: $e");
    }
  }

  // ── Load Wishlist and Cart (Fallback / Preload helper) ────────────────────
  Future<void> _loadCartAndWishlistFromFirestore() async {
    if (_user.id == 'guest') return;
    try {
      final wishlistDoc = await firebaseService.wishlistRef.doc(_user.id).get().timeout(const Duration(seconds: 4));
      if (wishlistDoc.exists && wishlistDoc.data() != null) {
        final data = wishlistDoc.data() as Map<String, dynamic>;
        final ids = List<String>.from(data['productIds'] ?? []);
        _wishlistIds.clear();
        _wishlistIds.addAll(ids);
      } else {
        _wishlistIds.clear();
      }
    } catch (e) {
      print('Warning: Failed to load wishlist from Firestore: $e');
    }

    try {
      final cartDoc = await firebaseService.firestore.collection('cart').doc(_user.id).get().timeout(const Duration(seconds: 4));
      if (cartDoc.exists && cartDoc.data() != null) {
        final data = cartDoc.data() as Map<String, dynamic>;
        final itemsList = data['items'] as List? ?? [];
        cart.loadFromMapList(itemsList, _products);
      } else {
        cart.clear();
      }
    } catch (e) {
      print('Warning: Failed to load cart from Firestore: $e');
    }
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      // First seed products in repository if needed
      await _productRepo.seedProductsIfEmpty();

      // Setup Products catalog stream (Global)
      _productsSubscription?.cancel();
      _productsSubscription = firebaseService.productsRef.snapshots().listen((snap) {
        print('[REALTIME_STREAMS] Products catalog updated dynamically via Firestore. Count: ${snap.docs.length}');
        if (snap.docs.isNotEmpty) {
          _products = snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
          notifyListeners();
        }
      }, onError: (e) => print('[REALTIME_STREAMS_ERROR] Products stream error: $e'));

      final results = await Future.wait([
        _productRepo.getAllProducts(),
        _orderRepo.getOrders(),
      ]);
      _products = results[0] as List<ProductModel>;
      _orders = results[1] as List<OrderModel>;
      final currentUser = await _userRepo.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        await _loadCartAndWishlistFromFirestore();
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ── User Actions ─────────────────────────────────────────────────────────

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _userRepo.signIn(email, password);
      if (user != null) {
        _user = user;
        _setupUserSubscriptions(_user.id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _userRepo.signInWithGoogle();
      if (user != null) {
        _user = user;
        _setupUserSubscriptions(_user.id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String name, String email, String password, {String phone = ''}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _userRepo.register(name, email, password, phone: phone);
      if (user != null) {
        // REQUIRED FLOW: Registration does NOT automatically log in the user.
        // We keep _user as guest so they must manually log in.
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyPhoneNumber(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) =>
      _userRepo.verifyPhoneNumber(phone, onCodeSent: onCodeSent, onError: onError);

  Future<bool> signInWithPhoneNumber(String verificationId, String smsCode) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _userRepo.signInWithPhoneNumber(verificationId, smsCode);
      if (user != null) {
        _user = user;
        _setupUserSubscriptions(_user.id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _userRepo.signOut();
    _cancelUserSubscriptions();
    _user = UserModel.guest;
    _wishlistIds.clear();
    cart.items; // does not clear — intentional, preserves session cart
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? language,
    String? currency,
  }) async {
    final updated = await _userRepo.updateProfile(
      current: _user,
      name: name,
      email: email,
      phone: phone,
      language: language,
      currency: currency,
    );
    if (updated != null) {
      _user = updated;
      notifyListeners();
    }
  }

  // ── PRODUCT VIEW TRACKING ─────────────────────────────────────────────────
  Future<void> recordProductView(ProductModel product) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final viewData = {
        'userId': _user.id == 'guest' ? 'guest' : _user.id,
        'productId': product.id,
        'productName': product.name,
        'productPrice': product.price,
        'imageUrl': product.imageUrl,
        'viewedAt': nowStr,
      };

      print('[PRODUCT_VIEW] Recording view in Firestore product_views collection: "${product.name}"');
      await firebaseService.productViewsRef.add(viewData).timeout(const Duration(seconds: 4));
      
      // Log Product Views in Activity Logs
      await activityLogService.logActivity(
        userId: _user.id,
        activityType: 'Product Views',
        details: {
          'productId': product.id,
          'productName': product.name,
          'price': product.price,
        },
      );
    } catch (e) {
      print('[PRODUCT_VIEW_ERROR] Failed to record view: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  WISHLIST ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  void toggleWishlist(String productId) {
    final isAdded = !_wishlistIds.contains(productId);
    if (isAdded) {
      _wishlistIds.add(productId);
    } else {
      _wishlistIds.remove(productId);
    }
    notifyListeners();
    _syncWishlistToFirestore();

    // Log Wishlist Activity
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => allProducts.firstWhere((p) => p.id == productId));
    activityLogService.logActivity(
      userId: _user.id,
      activityType: isAdded ? 'Wishlist Add' : 'Wishlist Remove',
      details: {
        'productId': productId,
        'productName': product.name,
        'price': product.price,
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CART ACTIONS (delegates to existing CartModel for compatibility)
  // ──────────────────────────────────────────────────────────────────────────

  void addToCart(ProductModel product, {String size = 'M', Color? color}) {
    cart.add(product, size: size, color: color);
    _syncCartToFirestore();

    // Log Add To Cart Activity
    activityLogService.logActivity(
      userId: _user.id,
      activityType: 'Add To Cart',
      details: {
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'size': size,
      },
    );
  }

  void removeFromCart(String productId) {
    final item = cart.items.where((i) => i.product.id == productId).firstOrNull;
    if (item != null) {
      final product = item.product;
      cart.remove(productId);
      _syncCartToFirestore();

      // Log Remove From Cart Activity
      activityLogService.logActivity(
        userId: _user.id,
        activityType: 'Remove From Cart',
        details: {
          'productId': productId,
          'productName': product.name,
          'qty': item.qty,
        },
      );
    } else {
      cart.remove(productId);
      _syncCartToFirestore();
    }
  }

  void updateCartQty(String productId, int qty) {
    cart.updateQty(productId, qty);
    _syncCartToFirestore();
  }

  void clearCart() {
    cart.clear();
    _syncCartToFirestore();
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  ORDER ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    final fetched = await _orderRepo.getOrders();
    _orders = fetched;
    notifyListeners();
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    final placed = await _orderRepo.placeOrder(order);
    _orders = [placed, ..._orders];
    cart.items; // Cart is NOT cleared automatically — checkout page handles that
    notifyListeners();

    // Log Checkout Activity
    await activityLogService.logActivity(
      userId: _user.id,
      activityType: 'Checkout',
      details: {
        'orderId': placed.id,
        'itemCount': placed.itemCount,
        'total': placed.total,
      },
    );

    return placed;
  }

  // ── RECORD PAYMENT DETAIL ─────────────────────────────────────────────────
  Future<void> recordPayment({
    required String orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
      
      final paymentData = {
        'id': '',
        'orderId': orderId,
        'userId': _user.id == 'guest' ? 'guest' : _user.id,
        'paymentStatus': 'Success',
        'paymentMethod': paymentMethod,
        'amount': amount,
        'transactionId': transactionId,
        'timestamp': nowStr,
      };

      print('[PAYMENT] Creating payment record for Order $orderId...');
      final docRef = await firebaseService.paymentsRef.add(paymentData).timeout(const Duration(seconds: 4));
      await docRef.update({'id': docRef.id});
      print('[PAYMENT] Payment record saved successfully in Firestore: ${docRef.id}');

      // Log Payment Success Activity
      await activityLogService.logActivity(
        userId: _user.id,
        activityType: 'Payment Success',
        details: {
          'orderId': orderId,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'transactionId': transactionId,
        },
      );
    } catch (e) {
      print('[PAYMENT_ERROR] Failed to record payment details: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _orderRepo.cancelOrder(orderId);
    await loadOrders();
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  // ──────────────────────────────────────────────────────────────────────────
  //  PRODUCT QUERIES (delegates to repo, no extra state)
  // ──────────────────────────────────────────────────────────────────────────

  List<ProductModel> getByCategory(String category) =>
      _products.where((p) => p.category == category).toList();

  List<ProductModel> search(String query) {
    final q = query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelUserSubscriptions();
    _productsSubscription?.cancel();
    super.dispose();
  }
}

// ── Singleton accessors (used during dependency injection in main.dart) ────
final productRepository_ = productRepository;
final userRepository_ = userRepository;
final orderRepository_ = orderRepository;
