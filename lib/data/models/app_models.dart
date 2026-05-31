import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/firebase_service.dart';
import 'package:flutter_application_1/data/services/activity_log_service.dart';

// ──────────────────────────────────────────────────────────────────────────
//  WISHLIST STATE
// ──────────────────────────────────────────────────────────────────────────
class WishlistModel extends ChangeNotifier {
  final Set<String> _wishlistIds = {};
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  bool isWishlisted(String id) => _wishlistIds.contains(id);

  void toggle(String id) {
    final isAdded = !_wishlistIds.contains(id);
    if (isAdded) {
      _wishlistIds.add(id);
    } else {
      _wishlistIds.remove(id);
    }
    notifyListeners();

    // Sync to Firestore and record activity in the background
    final uid = firebaseService.auth.currentUser?.uid;
    if (uid != null && uid != 'guest') {
      firebaseService.wishlistRef.doc(uid).set({
        'productIds': _wishlistIds.toList(),
      }).catchError((e) => print('Error syncing wishlist: $e'));

      activityLogService.logActivity(
        userId: uid,
        activityType: isAdded ? 'Wishlist Add' : 'Wishlist Remove',
        details: {'productId': id},
      );
    }
  }

  void loadFromList(List<String> ids) {
    _wishlistIds.clear();
    _wishlistIds.addAll(ids);
    notifyListeners();
  }
}

final WishlistModel wishlistModel = WishlistModel();

// ──────────────────────────────────────────────────────────────────────────
//  CART STATE
// ──────────────────────────────────────────────────────────────────────────
class CartItem {
  final ProductModel product;
  int qty;
  String selectedSize;
  Color selectedColor;
  CartItem({
    required this.product,
    this.qty = 1,
    required this.selectedSize,
    required this.selectedColor,
  });
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _promoCode;
  int _promoDiscount = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (s, e) => s + e.qty);
  String? get appliedPromo => _promoCode;
  int get promoDiscount => _promoDiscount;

  // Async sync to Firestore helper
  void _syncToFirestore() {
    final uid = firebaseService.auth.currentUser?.uid;
    if (uid != null && uid != 'guest') {
      firebaseService.firestore.collection('cart').doc(uid).set({
        'items': toMapList(),
      }).catchError((e) => print('Error syncing cart: $e'));
    }
  }

  void clear() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0;
    notifyListeners();
    _syncToFirestore();
  }

  void loadFromMapList(List<dynamic> list, List<ProductModel> products) {
    _items.clear();
    for (final raw in list) {
      final itemMap = Map<String, dynamic>.from(raw);
      final pId = itemMap['productId'] as String;
      final product = products.where((p) => p.id == pId).firstOrNull;
      if (product != null) {
        _items.add(CartItem(
          product: product,
          qty: (itemMap['qty'] as num).toInt(),
          selectedSize: itemMap['selectedSize'] as String? ?? 'M',
          selectedColor: Color((itemMap['selectedColorHex'] as num).toInt()),
        ));
      }
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> toMapList() {
    return _items.map((item) => {
      'productId': item.product.id,
      'qty': item.qty,
      'selectedSize': item.selectedSize,
      'selectedColorHex': item.selectedColor.value,
    }).toList();
  }

  void add(ProductModel p, {String size = 'M', Color? color}) {
    final existing = _items.where((i) => i.product.id == p.id).firstOrNull;
    if (existing != null) {
      existing.qty++;
    } else {
      _items.add(CartItem(
        product: p,
        selectedSize: size,
        selectedColor: color ?? p.availableColors.first,
      ));
    }
    notifyListeners();
    _syncToFirestore();

    // Log Cart Addition
    final uid = firebaseService.auth.currentUser?.uid;
    activityLogService.logActivity(
      userId: uid ?? 'guest',
      activityType: 'Add To Cart',
      details: {
        'productId': p.id,
        'productName': p.name,
        'price': p.price,
        'qty': 1,
        'size': size,
      },
    );
  }

  void remove(String id) {
    final item = _items.where((i) => i.product.id == id).firstOrNull;
    if (item != null) {
      final product = item.product;
      final qty = item.qty;
      _items.remove(item);
      notifyListeners();
      _syncToFirestore();

      // Log Cart Removal
      final uid = firebaseService.auth.currentUser?.uid;
      activityLogService.logActivity(
        userId: uid ?? 'guest',
        activityType: 'Remove From Cart',
        details: {
          'productId': id,
          'productName': product.name,
          'qty': qty,
        },
      );
    }
  }

  void updateCartQty(String id, int qty) {
    updateQty(id, qty);
  }

  void updateQty(String id, int qty) {
    final item = _items.where((i) => i.product.id == id).firstOrNull;
    if (item != null) {
      if (qty <= 0) {
        remove(id);
      } else {
        item.qty = qty;
        notifyListeners();
        _syncToFirestore();
      }
    }
  }

  bool applyPromo(String code) {
    if (code.trim().toUpperCase() == 'SAVE500') {
      _promoCode = 'SAVE500';
      _promoDiscount = 500;
      notifyListeners();
      _syncToFirestore();
      return true;
    }
    return false;
  }

  void removePromo() {
    _promoCode = null;
    _promoDiscount = 0;
    notifyListeners();
    _syncToFirestore();
  }

  /// Raw subtotal in LKR (integer)
  int get subtotal => _items.fold(0, (s, i) {
    final price = (double.tryParse(i.product.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0).toInt();
    return s + price * i.qty;
  });

  double get total => _items.fold(
      0, (s, i) => s + (double.tryParse(i.product.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0) * i.qty);
}

final CartModel cartModel = CartModel();

// ──────────────────────────────────────────────────────────────────────────
//  PRODUCT MODEL
// ──────────────────────────────────────────────────────────────────────────
class ReviewModel {
  final String name;
  final String text;
  final String timeAgo;
  final double rating;

  const ReviewModel({
    required this.name,
    required this.text,
    required this.timeAgo,
    required this.rating,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      name: map['name'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timeAgo: map['timeAgo'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'text': text,
        'timeAgo': timeAgo,
        'rating': rating,
      };
}

class ProductModel {
  final String id;
  final String brand;
  final String name;
  final String price;
  final String? originalPrice;
  final String? discountPercent;
  final double rating;
  final int reviewCount;
  final String? badge; // 'NEW' | 'SALE' | null
  final Color placeholderColor;
  final String imageUrl;
  final String category; // 'men' | 'women' | 'kids'
  final String? gender; // 'Boy' | 'Girl'
  final String subCategory; // 'Shirts' | 'T-Shirts' | etc.
  final List<String> availableSizes;
  final List<Color> availableColors;
  final String description;
  final List<ReviewModel> reviews;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.rating = 4.5,
    this.reviewCount = 100,
    this.badge,
    required this.placeholderColor,
    required this.imageUrl,
    required this.category,
    this.gender,
    required this.subCategory,
    this.availableSizes = const ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    this.availableColors = const [Color(0xFFE8365D), Colors.white, Colors.black, Color(0xFF90CAF9)],
    this.description = 'Crafted from premium long-staple cotton, this piece offers a sophisticated silhouette without sacrificing comfort. Designed for a modern lifestyle.\n\n• 100% Premium Fabric\n• Machine wash according to instructions\n• Free expedited shipping on orders over LKR 5,000',
    this.reviews = const [],
    this.inStock = true,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      originalPrice: map['originalPrice'] as String?,
      discountPercent: map['discountPercent'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 100,
      badge: map['badge'] as String?,
      placeholderColor: Color((map['placeholderColorHex'] as num?)?.toInt() ?? 0xFF1B2A4A),
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      gender: map['gender'] as String?,
      subCategory: map['subCategory'] as String? ?? '',
      availableSizes: List<String>.from(map['availableSizes'] ?? const ['XS', 'S', 'M', 'L', 'XL', 'XXL']),
      availableColors: (map['availableColorsHex'] as List?)
              ?.map((c) => Color((c as num).toInt()))
              .toList() ??
          const [Color(0xFFE8365D), Colors.white, Colors.black, Color(0xFF90CAF9)],
      description: map['description'] as String? ?? '',
      reviews: (map['reviews'] as List?)
              ?.map((r) => ReviewModel.fromMap(Map<String, dynamic>.from(r)))
              .toList() ??
          const [],
      inStock: map['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'brand': brand,
        'name': name,
        'price': price,
        'originalPrice': originalPrice,
        'discountPercent': discountPercent,
        'rating': rating,
        'reviewCount': reviewCount,
        'badge': badge,
        'placeholderColorHex': placeholderColor.value,
        'imageUrl': imageUrl,
        'category': category,
        'gender': gender,
        'subCategory': subCategory,
        'availableSizes': availableSizes,
        'availableColorsHex': availableColors.map((c) => c.value).toList(),
        'description': description,
        'reviews': reviews.map((r) => r.toMap()).toList(),
        'inStock': inStock,
      };
}

// ──────────────────────────────────────────────────────────────────────────
//  PRODUCT DATA
// ──────────────────────────────────────────────────────────────────────────

// ── MEN (20 Unique High-Quality Images) ──────────────────────────────────
final List<ProductModel> menProducts = [
  ProductModel(id: 'm1', brand: "MANO'S PREMIUM", name: 'Textured Navy Polo', price: 'LKR 3,450', originalPrice: 'LKR 4,500', rating: 4.6, reviewCount: 142, placeholderColor: const Color(0xFF1B2A4A), imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e32f08286?w=800', category: 'men', subCategory: 'T-Shirts'),
  ProductModel(id: 'm2', brand: 'LUCCI', name: 'Essential Slim Chino', price: 'LKR 4,900', originalPrice: 'LKR 6,200', rating: 4.3, reviewCount: 89, placeholderColor: const Color(0xFF5D7A4E), imageUrl: 'https://images.unsplash.com/photo-1624378441097-40c21345fecd?w=800', category: 'men', subCategory: 'Trousers'),
  ProductModel(id: 'm3', brand: 'ODEL', name: 'Island Linen Blend', price: 'LKR 3,800', badge: 'NEW', placeholderColor: const Color(0xFF8D7B68), imageUrl: 'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm4', brand: 'ROUGH DENIM', name: 'Straight Cut Indigo', price: 'LKR 5,200', rating: 4.8, placeholderColor: const Color(0xFF1A3A5C), imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800', category: 'men', subCategory: 'Denim'),
  ProductModel(id: 'm5', brand: 'HERITAGE', name: 'Oxford Cotton', price: 'LKR 2,499', badge: 'NEW', placeholderColor: const Color(0xFFB0BEC5), imageUrl: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm6', brand: 'MODERN TAILOR', name: 'Patterned Shirt', price: 'LKR 1,999', badge: 'SALE', placeholderColor: const Color(0xFF263238), imageUrl: 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ce3?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm7', brand: 'ECO LINEN', name: 'Summer Linen', price: 'LKR 3,100', placeholderColor: const Color(0xFFD7CCC8), imageUrl: 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm8', brand: 'ESSENTIAL', name: 'Midnight Casual', price: 'LKR 2,150', placeholderColor: const Color(0xFF37474F), imageUrl: 'https://images.unsplash.com/photo-1516826957135-700edeb5f9fa?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm9', brand: 'URBAN', name: 'Portrait Smart Look', price: 'LKR 1,800', placeholderColor: const Color(0xFF424242), imageUrl: 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=800', category: 'men', subCategory: 'T-Shirts'),
  ProductModel(id: 'm10', brand: 'CLASSIC', name: 'White Formal Shirt', price: 'LKR 4,200', placeholderColor: const Color(0xFFECEFF1), imageUrl: 'https://images.unsplash.com/photo-1626497764746-6dc36546b388?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm11', brand: 'DENIM CO', name: 'Black Slim Jeans', price: 'LKR 5,500', placeholderColor: const Color(0xFF212121), imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800', category: 'men', subCategory: 'Denim'),
  ProductModel(id: 'm12', brand: 'SPORT', name: 'Active Joggers', price: 'LKR 3,300', placeholderColor: const Color(0xFF546E7A), imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800', category: 'men', subCategory: 'Trousers'),
  ProductModel(id: 'm13', brand: 'VINTAGE', name: 'Checkered Shirt', price: 'LKR 2,900', placeholderColor: const Color(0xFF8D6E63), imageUrl: 'https://images.unsplash.com/photo-1574180566232-aaad1b5b8450?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm14', brand: 'BASIC', name: 'V-Neck Tee', price: 'LKR 1,200', placeholderColor: const Color(0xFF78909C), imageUrl: 'https://images.unsplash.com/photo-1525171254930-643fc658b64e?w=800', category: 'men', subCategory: 'T-Shirts'),
  ProductModel(id: 'm15', brand: 'PREMIUM', name: 'Tailored Trousers', price: 'LKR 6,000', placeholderColor: const Color(0xFF263238), imageUrl: 'https://images.unsplash.com/photo-1594938298596-eb5fd3f502ff?w=800', category: 'men', subCategory: 'Trousers'),
  ProductModel(id: 'm16', brand: 'STREET', name: 'Oversized Hoodie', price: 'LKR 4,500', placeholderColor: const Color(0xFFBCAAA4), imageUrl: 'https://images.unsplash.com/photo-1578681994506-b8f463449011?w=800', category: 'men', subCategory: 'T-Shirts'),
  ProductModel(id: 'm17', brand: 'LUXURY', name: 'Silk Blend Shirt', price: 'LKR 8,500', placeholderColor: const Color(0xFFFFF59D), imageUrl: 'https://images.unsplash.com/photo-1490367532201-b9bc1dc483f6?w=800', category: 'men', subCategory: 'Shirts'),
  ProductModel(id: 'm18', brand: 'CASUAL', name: 'Cargo Pants', price: 'LKR 4,800', placeholderColor: const Color(0xFFA1887F), imageUrl: 'https://images.unsplash.com/photo-1517438322307-e67111335449?w=800', category: 'men', subCategory: 'Trousers'),
  ProductModel(id: 'm19', brand: 'SUMMER', name: 'Polo T-Shirt', price: 'LKR 2,500', placeholderColor: const Color(0xFF81D4FA), imageUrl: 'https://images.unsplash.com/photo-1480455624313-e29b44bbfde1?w=800', category: 'men', subCategory: 'T-Shirts'),
  ProductModel(id: 'm20', brand: 'SMART', name: 'Smart Business Look', price: 'LKR 7,500', placeholderColor: const Color(0xFF1976D2), imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=800', category: 'men', subCategory: 'Shirts'),
];

// ── WOMEN (20 Unique High-Quality Images) ────────────────────────────────
final List<ProductModel> womenProducts = [
  ProductModel(id: 'w1', brand: 'AMAYA DESIGN', name: 'Silk Wrap Dress', price: 'LKR 5,450', originalPrice: 'LKR 7,000', rating: 4.7, reviewCount: 134, placeholderColor: const Color(0xFF2E7D32), imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800', category: 'women', subCategory: 'Dresses'),
  ProductModel(id: 'w2', brand: 'ETHNICA', name: 'Modern Batik Saree', price: 'LKR 12,900', originalPrice: 'LKR 15,000', rating: 4.9, reviewCount: 201, placeholderColor: const Color(0xFFB71C1C), imageUrl: 'https://images.unsplash.com/photo-1618932260643-eff47dd27568?w=800', category: 'women', subCategory: 'Dresses'),
  ProductModel(id: 'w3', brand: 'SUMMER STORY', name: 'Winter Coat Edit', price: 'LKR 4,900', rating: 4.2, placeholderColor: const Color(0xFF212121), imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800', category: 'women', subCategory: 'Outerwear'),
  ProductModel(id: 'w4', brand: 'WORK', name: 'Black Fashion Top', price: 'LKR 3,450', badge: 'NEW', placeholderColor: const Color(0xFF1A1A2E), imageUrl: 'https://images.unsplash.com/photo-1503341455253-b2e72fbb0dbb?w=800', category: 'women', subCategory: 'Tops'),
  ProductModel(id: 'w5', brand: 'AURA', name: 'White Cotton Blouse', price: 'LKR 2,950', placeholderColor: const Color(0xFF283593), imageUrl: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800', category: 'women', subCategory: 'Blouses'),
  ProductModel(id: 'w6', brand: 'CASUAL', name: 'Denim Collection', price: 'LKR 6,200', badge: 'SALE', placeholderColor: const Color(0xFF1565C0), imageUrl: 'https://images.unsplash.com/photo-1534481358055-6e46571faeb6?w=800', category: 'women', subCategory: 'Tops'),
  ProductModel(id: 'w7', brand: 'BLOOM', name: 'Floral Design Blouse', price: 'LKR 2,800', badge: 'NEW', placeholderColor: const Color(0xFFAD1457), imageUrl: 'https://images.unsplash.com/photo-1434389670869-c8cc23fcdded?w=800', category: 'women', subCategory: 'Blouses'),
  ProductModel(id: 'w8', brand: 'RICHE', name: 'Summer Maxi Dress', price: 'LKR 4,100', placeholderColor: const Color(0xFFE65100), imageUrl: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=800', category: 'women', subCategory: 'Dresses'),
  ProductModel(id: 'w9', brand: 'ELEGANCE', name: 'Evening Luxury Gown', price: 'LKR 15,000', placeholderColor: const Color(0xFF4A148C), imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=800', category: 'women', subCategory: 'Dresses'),
  ProductModel(id: 'w10', brand: 'STREET', name: 'Streetwear Style', price: 'LKR 1,500', placeholderColor: const Color(0xFFF06292), imageUrl: 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?w=800', category: 'women', subCategory: 'Tops'),
  ProductModel(id: 'w11', brand: 'COMFORT', name: 'Linen Trousers', price: 'LKR 4,500', placeholderColor: const Color(0xFFD7CCC8), imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800', category: 'women', subCategory: 'Bottoms'),
  ProductModel(id: 'w12', brand: 'CHIC', name: 'Pleated Skirt', price: 'LKR 3,800', placeholderColor: const Color(0xFFFFCC80), imageUrl: 'https://images.unsplash.com/photo-1582552938357-32b906df4018?w=800', category: 'women', subCategory: 'Bottoms'),
  ProductModel(id: 'w13', brand: 'OFFICE', name: 'Casual Blouse', price: 'LKR 3,200', placeholderColor: const Color(0xFFECEFF1), imageUrl: 'https://images.unsplash.com/photo-1495385794356-15371f348c31?w=800', category: 'women', subCategory: 'Blouses'),
  ProductModel(id: 'w14', brand: 'VINTAGE', name: 'Silk Pattern Dress', price: 'LKR 5,500', placeholderColor: const Color(0xFFD32F2F), imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800', category: 'women', subCategory: 'Dresses'),
  ProductModel(id: 'w15', brand: 'ACTIVE', name: 'Yoga Active Pants', price: 'LKR 2,800', placeholderColor: const Color(0xFF455A64), imageUrl: 'https://images.unsplash.com/photo-1506152983158-b4a74a01c721?w=800', category: 'women', subCategory: 'Bottoms'),
  ProductModel(id: 'w16', brand: 'LOUNGE', name: 'Casual Chic Look', price: 'LKR 6,500', placeholderColor: const Color(0xFFF8BBD0), imageUrl: 'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=800', category: 'women', subCategory: 'Sleepwear'),
  ProductModel(id: 'w17', brand: 'GLAM', name: 'Fashion Crop Top', price: 'LKR 4,800', placeholderColor: const Color(0xFFCFD8DC), imageUrl: 'https://images.unsplash.com/photo-1515347619362-75efb60882e7?w=800', category: 'women', subCategory: 'Tops'),
  ProductModel(id: 'w18', brand: 'BASIC', name: 'Cotton Essentials', price: 'LKR 990', placeholderColor: const Color(0xFFFFF9C4), imageUrl: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800', category: 'women', subCategory: 'Tops'),
  ProductModel(id: 'w19', brand: 'WINTER', name: 'Classic Skirt Edit', price: 'LKR 18,000', placeholderColor: const Color(0xFF5D4037), imageUrl: 'https://images.unsplash.com/photo-1495121605193-b116b5b9c5fe?w=800', category: 'women', subCategory: 'Outerwear'),
  ProductModel(id: 'w20', brand: 'BOHO', name: 'Portrait Fashion Look', price: 'LKR 4,200', placeholderColor: const Color(0xFF81C784), imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800', category: 'women', subCategory: 'Bottoms'),
];

// ── KIDS (20 Unique High-Quality Images) ─────────────────────────────────
final List<ProductModel> kidsProducts = [
  ProductModel(id: 'k1', brand: 'AGE 3-5', name: 'Official Kid Outfit', price: 'LKR 5,820', rating: 4.8, placeholderColor: const Color(0xFF1B2A4A), imageUrl: 'https://images.unsplash.com/photo-1519238321852-5a21e0eb7e31?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Boy'),
  ProductModel(id: 'k2', brand: 'AGE 3-5', name: 'Explorer Yellow T-shirt', price: 'LKR 1,200', rating: 4.6, placeholderColor: const Color(0xFFE8A020), imageUrl: 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Boy'),
  ProductModel(id: 'k3', brand: 'AGE 3-5', name: 'Classic Cotton Polo', price: 'LKR 1,490', rating: 4.4, placeholderColor: const Color(0xFF5D7A4E), imageUrl: 'https://images.unsplash.com/photo-1514316454349-750ca227181c?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Boy'),
  ProductModel(id: 'k4', brand: 'AGE 3-5', name: 'Adventure Cargo Cap', price: 'LKR 1,650', badge: 'NEW', placeholderColor: const Color(0xFFE91E63), imageUrl: 'https://images.unsplash.com/photo-1533512930330-4ac257c86793?w=800', category: 'kids', subCategory: 'Accessories', gender: 'Boy'),
  ProductModel(id: 'k5', brand: 'AGE 0-2', name: 'Soft Baby Romper', price: 'LKR 980', badge: 'NEW', placeholderColor: const Color(0xFF81D4FA), imageUrl: 'https://images.unsplash.com/photo-1604467794349-0b74285de7e7?w=800', category: 'kids', subCategory: 'Frocks', gender: 'Girl'),
  ProductModel(id: 'k6', brand: 'AGE 6-9', name: 'Denim Casual Shorts', price: 'LKR 1,350', rating: 4.2, placeholderColor: const Color(0xFF1A3A5C), imageUrl: 'https://images.unsplash.com/photo-1600863806201-1b9195cfcb17?w=800', category: 'kids', subCategory: 'Shorts', gender: 'Boy'),
  ProductModel(id: 'k7', brand: 'AGE 3-5', name: 'Floral Summer Frock', price: 'LKR 1,750', badge: 'SALE', placeholderColor: const Color(0xFFBA68C8), imageUrl: 'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=800', category: 'kids', subCategory: 'Frocks', gender: 'Girl'),
  ProductModel(id: 'k8', brand: 'AGE 6-9', name: 'Sport Tee Bundle', price: 'LKR 2,100', rating: 4.5, placeholderColor: const Color(0xFFEF5350), imageUrl: 'https://images.unsplash.com/photo-1621458826622-cffde95079a4?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Boy'),
  ProductModel(id: 'k9', brand: 'AGE 6-9', name: 'Pink Party Dress', price: 'LKR 3,500', placeholderColor: const Color(0xFFF48FB1), imageUrl: 'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=800', category: 'kids', subCategory: 'Frocks', gender: 'Girl'),
  ProductModel(id: 'k10', brand: 'AGE 0-2', name: 'Cute Child Portrait', price: 'LKR 850', placeholderColor: const Color(0xFFFFCC80), imageUrl: 'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Boy'),
  ProductModel(id: 'k11', brand: 'AGE 3-5', name: 'Kid Fashion Look', price: 'LKR 1,800', placeholderColor: const Color(0xFF64B5F6), imageUrl: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=800', category: 'kids', subCategory: 'Sleepwear', gender: 'Boy'),
  ProductModel(id: 'k12', brand: 'AGE 6-9', name: 'Unicorn Sweatshirt', price: 'LKR 2,200', placeholderColor: const Color(0xFFCE93D8), imageUrl: 'https://images.unsplash.com/photo-1540479859209-6714a005ee59?w=800', category: 'kids', subCategory: 'T-Shirts', gender: 'Girl'),
  ProductModel(id: 'k13', brand: 'AGE 0-2', name: 'Knitted Baby Style', price: 'LKR 600', placeholderColor: const Color(0xFFBCAAA4), imageUrl: 'https://images.unsplash.com/photo-1519340241574-2dec49daa04c?w=800', category: 'kids', subCategory: 'Accessories', gender: 'Girl'),
  ProductModel(id: 'k14', brand: 'AGE 3-5', name: 'Cargo Denim Shorts', price: 'LKR 2,400', placeholderColor: const Color(0xFF8D6E63), imageUrl: 'https://images.unsplash.com/photo-1515132647015-05670af48d29?w=800', category: 'kids', subCategory: 'Shorts', gender: 'Boy'),
  ProductModel(id: 'k15', brand: 'AGE 6-9', name: 'Glitter Pink Skirt', price: 'LKR 1,900', placeholderColor: const Color(0xFFFFD54F), imageUrl: 'https://images.unsplash.com/photo-1524503033411-c9566986fc8f?w=800', category: 'kids', subCategory: 'Frocks', gender: 'Girl'),
  ProductModel(id: 'k16', brand: 'AGE 0-2', name: 'Striped Beanie Cap', price: 'LKR 450', placeholderColor: const Color(0xFF78909C), imageUrl: 'https://images.unsplash.com/photo-1560506840-ec148e82a604?w=800', category: 'kids', subCategory: 'Accessories', gender: 'Boy'),
  ProductModel(id: 'k17', brand: 'AGE 3-5', name: 'Classic Kid Jacket', price: 'LKR 2,800', placeholderColor: const Color(0xFFFFCA28), imageUrl: 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=800', category: 'kids', subCategory: 'Outerwear', gender: 'Boy'),
  ProductModel(id: 'k18', brand: 'AGE 6-9', name: 'Ballet Kid Shoes', price: 'LKR 1,500', placeholderColor: const Color(0xFFF48FB1), imageUrl: 'https://images.unsplash.com/photo-1519457431-75514b731b73?w=800', category: 'kids', subCategory: 'Footwear', gender: 'Girl'),
  ProductModel(id: 'k19', brand: 'AGE 0-2', name: 'Cotton Baby Mittens', price: 'LKR 300', placeholderColor: const Color(0xFFEEEEEE), imageUrl: 'https://images.unsplash.com/photo-1505373633579-4d6424662be3?w=800', category: 'kids', subCategory: 'Accessories', gender: 'Boy'),
  ProductModel(id: 'k20', brand: 'AGE 3-5', name: 'Summer Hat Look', price: 'LKR 800', placeholderColor: const Color(0xFFFFE082), imageUrl: 'https://images.unsplash.com/photo-1555009393-43d481ac9678?w=800', category: 'kids', subCategory: 'Accessories', gender: 'Girl'),
];

// ── EXTRA PRODUCTS (For Specific Categories) ──────────────────────────────
final List<ProductModel> extraProducts = [
  // Accessories
  ProductModel(id: 'ex1', brand: 'VEXA LUXE', name: 'Minimalist Gold Watch', price: 'LKR 12,500', rating: 4.8, reviewCount: 45, placeholderColor: const Color(0xFFC5A059), imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800', category: 'men', subCategory: 'Accessories'),
  ProductModel(id: 'ex2', brand: 'ELEGANCE', name: 'Diamond Solitaire Ring', price: 'LKR 45,000', rating: 4.9, reviewCount: 22, placeholderColor: const Color(0xFFE0E0E0), imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3f41e?w=800', category: 'women', subCategory: 'Accessories'),
  // Footwear
  ProductModel(id: 'ex3', brand: 'SPEED', name: 'Kids Neon Sneakers', price: 'LKR 3,800', rating: 4.5, reviewCount: 67, placeholderColor: const Color(0xFFF44336), imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800', category: 'kids', subCategory: 'Footwear', gender: 'Boy'),
  ProductModel(id: 'ex4', brand: 'CHIC', name: 'Stiletto Red Heels', price: 'LKR 7,200', rating: 4.7, reviewCount: 89, placeholderColor: const Color(0xFFB71C1C), imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800', category: 'women', subCategory: 'Footwear'),
  ProductModel(id: 'ex7', brand: 'CLASSIC', name: 'Tan Leather Brogues', price: 'LKR 9,500', rating: 4.8, reviewCount: 31, placeholderColor: const Color(0xFF8D6E63), imageUrl: 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=800', category: 'men', subCategory: 'Footwear'),
  // Denim
  ProductModel(id: 'ex5', brand: 'ROUGH', name: 'Classic Denim Shirt', price: 'LKR 3,950', rating: 4.4, reviewCount: 54, placeholderColor: const Color(0xFF5C6BC0), imageUrl: 'https://images.unsplash.com/photo-1527010159945-c4250922b19e?w=800', category: 'men', subCategory: 'Denim'),
  ProductModel(id: 'ex6', brand: 'URBAN', name: 'Denim Trucker Jacket', price: 'LKR 5,500', rating: 4.6, reviewCount: 38, placeholderColor: const Color(0xFF3949AB), imageUrl: 'https://images.unsplash.com/photo-1576905324223-442807e60058?w=800', category: 'women', subCategory: 'Denim'),
];

// ── UNIFIED LIST ──────────────────────────────────────────────────────────
final List<ProductModel> allProducts = [
  ...menProducts,
  ...womenProducts,
  ...kidsProducts,
  ...extraProducts,
];

// Legacy trendingProducts for home page
final List<ProductModel> trendingProducts = [
  ProductModel(
    id: 'p1', brand: 'PREMIUM', name: 'Modern Wool Coat',
    price: 'LKR 12,450', rating: 4.9, reviewCount: 156, badge: 'TRENDING',
    placeholderColor: const Color(0xFF2C3E50), imageUrl: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800', category: 'men', subCategory: 'Outerwear',
  ),
  ProductModel(
    id: 'p2', brand: 'ELEGANCE', name: 'Velvet Evening Gown',
    price: 'LKR 18,900', rating: 4.8, reviewCount: 84, badge: 'HOT',
    placeholderColor: const Color(0xFF4A148C), imageUrl: 'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=800', category: 'women', subCategory: 'Dresses',
  ),
  ProductModel(
    id: 'p3', brand: 'STREETWEAR', name: 'Graphic Oversized Hoodie',
    price: 'LKR 4,200', rating: 4.7, reviewCount: 210, badge: 'BEST',
    placeholderColor: const Color(0xFF212121), imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800', category: 'men', subCategory: 'T-Shirts',
  ),
  ProductModel(
    id: 'p4', brand: 'KIDS PRO', name: 'Active Adventure Set',
    price: 'LKR 3,490', rating: 4.6, reviewCount: 42,
    placeholderColor: const Color(0xFFE8A020), imageUrl: 'https://images.unsplash.com/photo-1621458826622-cffde95079a4?w=800', category: 'kids', subCategory: 'T-Shirts',
  ),
];
