class AdminBannerModel {
  final String id;
  final String tag;
  final String title;
  final String description;
  final String iconType; // 'star', 'swap', 'shield', 'campaign', 'store'
  final String actionUrl;
  final String badgeColor; // hex or preset
  final bool isActive;
  final String createdAt;

  AdminBannerModel({
    required this.id,
    required this.tag,
    required this.title,
    required this.description,
    this.iconType = 'star',
    this.actionUrl = '',
    this.badgeColor = '0xFFFFCC00',
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'title': title,
      'description': description,
      'icon_type': iconType,
      'action_url': actionUrl,
      'badge_color': badgeColor,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AdminBannerModel.fromMap(Map<String, dynamic> map) {
    return AdminBannerModel(
      id: map['id'] as String,
      tag: map['tag'] as String? ?? '📢 إعلان الإدارة',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconType: map['icon_type'] as String? ?? 'star',
      actionUrl: map['action_url'] as String? ?? '',
      badgeColor: map['badge_color'] as String? ?? '0xFFFFCC00',
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
