class ItemModel {
  final String id;
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final String brand;
  final String model;
  final String condition; // جديد، ممتاز، شبه جديد، جيد، مقبول
  final String quality; // أصلي، درجة أولى، تجاري
  final int quantity;
  final double estimatedValue;
  final String city;
  final String phoneNumber;
  final String wantedDescription; // ماذا يريد صاحب المنتج مقابله
  final String? wantedCategoryId;
  final String swapType; // Direct, Swap+Cash, Any
  final String status; // Draft, Available, Reserved, In Swap, Completed, Expired, Removed
  final bool isFeatured;
  final int viewsCount;
  final String createdAt;
  final String updatedAt;
  final String expiresAt;
  final String lastRefreshAt;

  // Joined/Helper fields
  final List<String> images;
  final String userName;
  final int userTrustScore;
  final double userRating;
  final String userCity;
  final String userImage;
  final String userEmail;
  final bool userIsVerified;
  final String categoryName;

  ItemModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.brand = '',
    this.model = '',
    required this.condition,
    this.quality = 'أصلي وكالة',
    this.quantity = 1,
    required this.estimatedValue,
    required this.city,
    required this.phoneNumber,
    this.wantedDescription = 'أي عرض مناسب أو جهاز متوافق',
    this.wantedCategoryId,
    this.swapType = 'Direct',
    this.status = 'Available',
    this.isFeatured = false,
    this.viewsCount = 0,
    required this.createdAt,
    String? updatedAt,
    String? expiresAt,
    String? lastRefreshAt,
    this.images = const [],
    this.userName = '',
    this.userTrustScore = 85,
    this.userRating = 5.0,
    this.userCity = '',
    this.userImage = '',
    this.userEmail = '',
    this.userIsVerified = false,
    this.categoryName = '',
  })  : updatedAt = updatedAt ?? createdAt,
        expiresAt = expiresAt ??
            DateTime.tryParse(createdAt)
                ?.add(const Duration(days: 30))
                .toIso8601String() ??
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        lastRefreshAt = lastRefreshAt ?? createdAt;

  bool get isExpired => status == 'Expired';
  bool get isAvailable => status == 'Available';
  bool get isReserved => status == 'Reserved';
  bool get isInSwap => status == 'In Swap';
  bool get isCompleted => status == 'Completed' || status == 'Swapped';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'brand': brand,
      'model': model,
      'condition': condition,
      'quality': quality,
      'quantity': quantity,
      'estimated_value': estimatedValue,
      'city': city,
      'phone_number': phoneNumber,
      'wanted_description': wantedDescription,
      'wanted_category_id': wantedCategoryId,
      'swap_type': swapType,
      'status': status,
      'is_featured': isFeatured ? 1 : 0,
      'views_count': viewsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'expires_at': expiresAt,
      'last_refresh_at': lastRefreshAt,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, {List<String>? imagesList}) {
    final created = map['created_at'] as String? ?? DateTime.now().toIso8601String();
    return ItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      condition: map['condition'] as String? ?? 'ممتاز',
      quality: map['quality'] as String? ?? 'أصلي وكالة',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      estimatedValue: (map['estimated_value'] as num?)?.toDouble() ?? 0.0,
      city: map['city'] as String? ?? 'صنعاء',
      phoneNumber: map['phone_number'] as String? ?? '',
      wantedDescription: map['wanted_description'] as String? ?? 'أي عرض بديل مناسب',
      wantedCategoryId: map['wanted_category_id'] as String?,
      swapType: map['swap_type'] as String? ?? 'Direct',
      status: map['status'] as String? ?? 'Available',
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      viewsCount: (map['views_count'] as num?)?.toInt() ?? 0,
      createdAt: created,
      updatedAt: map['updated_at'] as String? ?? created,
      expiresAt: map['expires_at'] as String?,
      lastRefreshAt: map['last_refresh_at'] as String? ?? created,
      images: imagesList ?? [],
      userName: map['user_name'] as String? ?? '',
      userTrustScore: (map['user_trust_score'] as num?)?.toInt() ?? 85,
      userRating: (map['user_rating'] as num?)?.toDouble() ?? 5.0,
      userCity: map['user_city'] as String? ?? '',
      userImage: map['user_image'] as String? ?? '',
      userEmail: map['user_email'] as String? ?? '',
      userIsVerified: (map['user_is_verified'] as int? ?? 0) == 1,
      categoryName: map['category_name'] as String? ?? '',
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    final catData = json['category'] as Map<String, dynamic>?;
    final rawImages = json['images'];
    List<String> imgList = [];
    if (rawImages is List) {
      imgList = rawImages.map((e) => e.toString()).toList();
    }

    final created = json['created_at']?.toString() ?? DateTime.now().toIso8601String();

    String rawCondition = json['condition']?.toString() ?? 'like_new';
    String mappedCondition = 'ممتاز';
    if (rawCondition == 'new') mappedCondition = 'جديد بالكرتون';
    else if (rawCondition == 'like_new') mappedCondition = 'شبه جديد';
    else if (rawCondition == 'excellent') mappedCondition = 'ممتاز';
    else if (rawCondition == 'good') mappedCondition = 'جيد جداً';
    else if (rawCondition == 'fair') mappedCondition = 'مقبول';
    else if (rawCondition.isNotEmpty) mappedCondition = rawCondition;

    String rawSwapType = json['swap_type']?.toString() ?? 'exact_match';
    String mappedSwapType = 'Direct';
    if (rawSwapType == 'cash_adjustment') mappedSwapType = 'Swap+Cash';
    else if (rawSwapType == 'any') mappedSwapType = 'Any';
    else if (rawSwapType == 'exact_match') mappedSwapType = 'Direct';
    else if (rawSwapType.isNotEmpty) mappedSwapType = rawSwapType;

    String rawStatus = json['status']?.toString() ?? 'available';
    String mappedStatus = 'Available';
    if (rawStatus.toLowerCase() == 'available') mappedStatus = 'Available';
    else if (rawStatus.toLowerCase() == 'reserved') mappedStatus = 'Reserved';
    else if (rawStatus.toLowerCase() == 'swapped') mappedStatus = 'Completed';
    else mappedStatus = rawStatus;

    return ItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      condition: mappedCondition,
      estimatedValue: (json['estimated_value'] as num?)?.toDouble() ?? 0.0,
      city: json['city']?.toString() ?? 'صنعاء',
      phoneNumber: userData?['phone']?.toString() ?? '',
      wantedDescription: json['wanted_description']?.toString() ?? 'أي عرض بديل مناسب',
      wantedCategoryId: json['wanted_category_id']?.toString(),
      swapType: mappedSwapType,
      status: mappedStatus,
      createdAt: created,
      expiresAt: json['expires_at']?.toString(),
      lastRefreshAt: json['last_refresh_at']?.toString() ?? created,
      images: imgList,
      userName: userData?['name']?.toString() ?? '',
      userTrustScore: (userData?['trust_score'] as num?)?.toInt() ?? 85,
      userRating: (userData?['rating'] as num?)?.toDouble() ?? 5.0,
      userCity: userData?['city']?.toString() ?? '',
      userImage: userData?['avatar']?.toString() ?? '',
      userEmail: userData?['email']?.toString() ?? '',
      userIsVerified: userData?['is_verified'] == true,
      categoryName: catData?['name']?.toString() ?? '',
    );
  }

  ItemModel copyWith({
    String? title,
    String? description,
    String? brand,
    String? model,
    String? condition,
    String? quality,
    int? quantity,
    double? estimatedValue,
    String? city,
    String? phoneNumber,
    String? wantedDescription,
    String? wantedCategoryId,
    String? swapType,
    String? status,
    bool? isFeatured,
    int? viewsCount,
    String? updatedAt,
    String? expiresAt,
    String? lastRefreshAt,
    List<String>? images,
  }) {
    return ItemModel(
      id: id,
      userId: userId,
      categoryId: categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      condition: condition ?? this.condition,
      quality: quality ?? this.quality,
      quantity: quantity ?? this.quantity,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      city: city ?? this.city,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      wantedDescription: wantedDescription ?? this.wantedDescription,
      wantedCategoryId: wantedCategoryId ?? this.wantedCategoryId,
      swapType: swapType ?? this.swapType,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      images: images ?? this.images,
      userName: userName,
      userTrustScore: userTrustScore,
      userRating: userRating,
      userCity: userCity,
      userImage: userImage,
      userEmail: userEmail,
      userIsVerified: userIsVerified,
      categoryName: categoryName,
    );
  }
}
