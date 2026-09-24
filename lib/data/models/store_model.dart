class StoreModel {
  final String id;
  final String userId;
  final String storeName;
  final String logo;
  final String bio;
  final String city;
  final String phone;
  final bool isVerified;
  final double rating;
  final int itemsCount;

  StoreModel({
    required this.id,
    required this.userId,
    required this.storeName,
    this.logo = '',
    this.bio = '',
    required this.city,
    required this.phone,
    this.isVerified = true,
    this.rating = 5.0,
    this.itemsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'logo': logo,
      'bio': bio,
      'city': city,
      'phone': phone,
      'is_verified': isVerified ? 1 : 0,
      'rating': rating,
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map, {int itemsCount = 0}) {
    return StoreModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      storeName: map['store_name'] as String,
      logo: map['logo'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      city: map['city'] as String? ?? 'صنعاء',
      phone: map['phone'] as String? ?? '',
      isVerified: (map['is_verified'] as int? ?? 1) == 1,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      itemsCount: itemsCount,
    );
  }
}
