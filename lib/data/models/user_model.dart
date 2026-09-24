class UserModel {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String image;
  final String email;
  final String city;
  final String createdAt;
  final String updatedAt;
  final String role; // 'customer', 'merchant', 'admin'
  final String status; // 'active', 'suspended', 'banned'
  final double rating;
  final int trustScore;
  final bool isVerified;
  final int swapsCompleted;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    this.image = '',
    this.email = '',
    required this.city,
    required this.createdAt,
    String? updatedAt,
    this.role = 'customer',
    this.status = 'active',
    this.rating = 5.0,
    this.trustScore = 80,
    this.isVerified = false,
    this.swapsCompleted = 0,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get isAdmin => role == 'admin';
  bool get isMerchant => role == 'merchant';
  bool get isCustomer => role == 'customer';
  bool get isActive => status == 'active';
  bool get isBanned => status == 'banned';
  bool get isSuspended => status == 'suspended';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'password': password,
      'image': image,
      'email': email,
      'city': city,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role,
      'status': status,
      'rating': rating,
      'trust_score': trustScore,
      'is_verified': isVerified ? 1 : 0,
      'swaps_completed': swapsCompleted,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String? ?? '',
      image: map['image'] as String? ?? '',
      email: map['email'] as String? ?? '',
      city: map['city'] as String? ?? 'صنعاء',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String?,
      role: map['role'] as String? ?? 'customer',
      status: map['status'] as String? ?? 'active',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      trustScore: (map['trust_score'] as num?)?.toInt() ?? 80,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      swapsCompleted: (map['swaps_completed'] as num?)?.toInt() ?? 0,
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? password,
    String? image,
    String? email,
    String? city,
    String? role,
    String? status,
    String? updatedAt,
    double? rating,
    int? trustScore,
    bool? isVerified,
    int? swapsCompleted,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      image: image ?? this.image,
      email: email ?? this.email,
      city: city ?? this.city,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      trustScore: trustScore ?? this.trustScore,
      isVerified: isVerified ?? this.isVerified,
      swapsCompleted: swapsCompleted ?? this.swapsCompleted,
    );
  }
}
