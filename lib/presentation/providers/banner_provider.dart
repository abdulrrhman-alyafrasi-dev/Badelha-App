import 'package:flutter/material.dart';
import '../../data/models/admin_banner_model.dart';
import '../../data/database/app_database.dart';

class BannerProvider with ChangeNotifier {
  final List<AdminBannerModel> _banners = [];
  bool _isLoading = false;

  List<AdminBannerModel> get banners => _banners.where((b) => b.isActive).toList();
  List<AdminBannerModel> get allBanners => List.unmodifiable(_banners);
  bool get isLoading => _isLoading;

  BannerProvider() {
    loadBanners();
  }

  Future<void> loadBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await AppDatabase.instance.database;

      // Ensure table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS admin_banners (
          id TEXT PRIMARY KEY,
          tag TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          icon_type TEXT NOT NULL,
          action_url TEXT,
          badge_color TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute("""
          UPDATE admin_banners 
          SET action_url = 'https://t.me/Al_YafarsiDev77' 
          WHERE id = 'banner_dev_channel' OR tag LIKE '%مطور%'
        """);
        final List<Map<String, dynamic>> maps = await db.query(
        'admin_banners',
        orderBy: 'created_at DESC',
      );

      _banners.clear();
      if (maps.isNotEmpty) {
        for (var map in maps) {
          _banners.add(AdminBannerModel.fromMap(map));
        }
      } else {
        // Seed default official administrative banners
        final initialBanners = [
          AdminBannerModel(
            id: 'banner_dev_channel',
            tag: '🚀 قناة مطور التطبيق',
            title: '🇾🇪 بدلها - القناة والمجتمع الرسمي',
            description: 'انضم للقناة الرسمية للحصول على آخر التحديثات والصفقات الحصرية ودعم المقايضة...',
            iconType: 'star',
            actionUrl: 'https://t.me/Al_YafarsiDev77',
            badgeColor: '0xFFFFCC00',
            createdAt: DateTime.now().toIso8601String(),
          ),
          AdminBannerModel(
            id: 'banner_security',
            tag: '🛡️ أمان المقايضة',
            title: '🤝 نصائح المقايضة اليدوية الآمنة',
            description: 'احرص على فحص الأجهزة يداً بيد والتأكد من نظافة القطع والبطارية قبل إتمام المقايضة...',
            iconType: 'shield',
            badgeColor: '0xFF00D084',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          ),
          AdminBannerModel(
            id: 'banner_deals_week',
            tag: '🔥 عروض ومطابقات هذا الأسبوع',
            title: '📱 تبادل الهواتف الذكية والأجهزة اللوحية',
            description: 'أكثر من 150 مقايض في صنعاء وعدن وتعز يبحثون عن أجهزة آيفون وسامسونج الآن...',
            iconType: 'swap',
            badgeColor: '0xFFFF8A00',
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          ),
        ];

        for (var b in initialBanners) {
          await db.insert('admin_banners', b.toMap());
          _banners.add(b);
        }
      }
    } catch (e) {
      // Fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin-only: Add new banner
  Future<void> addBanner(AdminBannerModel banner) async {
    try {
      final db = await AppDatabase.instance.database;
      await db.insert('admin_banners', banner.toMap());
      _banners.insert(0, banner);
      notifyListeners();
    } catch (e) {
      // Error handling
    }
  }

  /// Admin-only: Toggle banner active state
  Future<void> toggleBanner(String bannerId) async {
    final index = _banners.indexWhere((b) => b.id == bannerId);
    if (index == -1) return;

    final current = _banners[index];
    final updated = AdminBannerModel(
      id: current.id,
      tag: current.tag,
      title: current.title,
      description: current.description,
      iconType: current.iconType,
      actionUrl: current.actionUrl,
      badgeColor: current.badgeColor,
      isActive: !current.isActive,
      createdAt: current.createdAt,
    );

    _banners[index] = updated;
    notifyListeners();

    try {
      final db = await AppDatabase.instance.database;
      await db.update(
        'admin_banners',
        {'is_active': updated.isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [bannerId],
      );
    } catch (_) {}
  }

  /// Admin-only: Delete banner
  Future<void> deleteBanner(String bannerId) async {
    _banners.removeWhere((b) => b.id == bannerId);
    notifyListeners();

    try {
      final db = await AppDatabase.instance.database;
      await db.delete(
        'admin_banners',
        where: 'id = ?',
        whereArgs: [bannerId],
      );
    } catch (_) {}
  }
}
