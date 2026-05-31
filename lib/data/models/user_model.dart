// ──────────────────────────────────────────────────────────────────────────
//  USER MODEL
//  Clean, serializable, Firebase-ready.
//  When Firestore is connected: use UserModel.fromFirestore(snapshot).
// ──────────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String language;
  final String currency;
  final int orderCount;
  final int wishlistCount;
  final int reviewCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImageUrl,
    this.language = 'English',
    this.currency = 'LKR',
    this.orderCount = 0,
    this.wishlistCount = 0,
    this.reviewCount = 0,
  });

  // ── Firebase: fromMap ───────────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? map['uid']) as String? ?? '',
      name: map['name'] as String? ?? 'Guest',
      email: map['email'] as String? ?? '',
      phone: (map['phone'] ?? map['phoneNumber']) as String? ?? '',
      profileImageUrl: (map['profileImageUrl'] ?? map['profileImage'] ?? map['photoUrl']) as String?,
      language: map['language'] as String? ?? 'English',
      currency: map['currency'] as String? ?? 'LKR',
      orderCount: (map['orderCount'] as num?)?.toInt() ?? 0,
      wishlistCount: (map['wishlistCount'] as num?)?.toInt() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  // ── Firebase: toMap ─────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': id,
        'name': name,
        'email': email,
        'phone': phone,
        'phoneNumber': phone,
        'profileImageUrl': profileImageUrl,
        'profileImage': profileImageUrl,
        'photoUrl': profileImageUrl,
        'provider': email.isEmpty ? 'phone' : (email.contains('@gmail.com') ? 'google' : 'email'),
        'authProvider': email.isEmpty ? 'phone' : (email.contains('@gmail.com') ? 'google' : 'email'),
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'language': language,
        'currency': currency,
        'orderCount': orderCount,
        'wishlistCount': wishlistCount,
        'reviewCount': reviewCount,
      };

  // ── copyWith ────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? language,
    String? currency,
    int? orderCount,
    int? wishlistCount,
    int? reviewCount,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      orderCount: orderCount ?? this.orderCount,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  static const UserModel guest = UserModel(
    id: 'guest',
    name: 'Guest',
    email: 'guest@vexa.com',
    phone: '',
    orderCount: 0,
    wishlistCount: 0,
    reviewCount: 0,
  );
}
