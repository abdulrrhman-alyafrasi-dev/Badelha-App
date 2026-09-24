class WantedItemModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String brand;
  final String model;
  final double? minValue;
  final double? maxValue;
  final String targetCity;
  final String notes;

  WantedItemModel({
    required this.id,
    required this.userId,
    this.categoryId,
    this.brand = '',
    this.model = '',
    this.minValue,
    this.maxValue,
    this.targetCity = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'min_value': minValue,
      'max_value': maxValue,
      'target_city': targetCity,
      'notes': notes,
    };
  }

  factory WantedItemModel.fromMap(Map<String, dynamic> map) {
    return WantedItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String?,
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      minValue: (map['min_value'] as num?)?.toDouble(),
      maxValue: (map['max_value'] as num?)?.toDouble(),
      targetCity: map['target_city'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}
