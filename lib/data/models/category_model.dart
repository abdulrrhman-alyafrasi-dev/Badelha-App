class CategoryModel {
  final String id;
  final String name;
  final String? parentId;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon': icon,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      icon: map['icon'] as String? ?? 'category',
    );
  }
}
