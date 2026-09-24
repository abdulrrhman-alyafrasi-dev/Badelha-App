import 'package:sqflite/sqflite.dart';

class SeedData {
  /// Ensures essential categories and PostgreSQL-aligned users exist
  static Future<void> populateIfEmpty(Database db) async {
    final catCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );

    if (catCount == null || catCount == 0) {
      await db.rawInsert('''
        INSERT INTO categories (id, name, parent_id, icon) VALUES
        ('1', 'إلكترونيات', NULL, 'devices'),
        ('2', 'سيارات ومركبات', NULL, 'directions_car'),
        ('3', 'عقارات', NULL, 'apartment'),
        ('4', 'أزياء وملابس', NULL, 'checkroom'),
        ('5', 'أثاث وديكور', NULL, 'chair'),
        ('6', 'كتب وروايات', NULL, 'menu_book'),
        ('7', 'ألعاب فيديو', NULL, 'sports_esports'),
        ('8', 'رياضة ولياقة', NULL, 'fitness_center'),
        ('9', 'أخرى', NULL, 'category')
      ''');
    }

    // Replace legacy users with PostgreSQL-aligned 6 default users
    final now = DateTime.now().toIso8601String();
    await db.rawInsert('''
      INSERT OR REPLACE INTO users (id, name, phone, password, image, email, city, role, status, created_at, rating, trust_score, is_verified, swaps_completed) VALUES
      ('1', 'مدير النظام', '777000000', 'admin123', '', 'admin@badelha.com', 'صنعاء', 'admin', 'active', '$now', 5.0, 100, 1, 0),
      ('2', 'متجر التكنولوجيا الحديثة', '777111222', 'password123', '', 'techstore@badelha.com', 'صنعاء', 'merchant', 'active', '$now', 4.9, 98, 1, 24),
      ('3', 'أحمد المقايض', '771234567', 'password123', '', 'ahmed@badelha.com', 'صنعاء', 'customer', 'active', '$now', 4.85, 95, 1, 8),
      ('4', 'سارة الشامري', '772345678', 'password123', '', 'sara@badelha.com', 'عدن', 'customer', 'active', '$now', 5.0, 96, 1, 5),
      ('5', 'علي صالح', '775556677', 'password123', '', '775556677@badelha.ye', 'ذمار', 'customer', 'active', '$now', 4.8, 80, 1, 3),
      ('6', 'عبدالرحمن اليافرسي', '772442264', 'password123', '', '772442264@badelha.ye', 'إب', 'customer', 'active', '$now', 4.9, 90, 1, 4)
    ''');

    await db.rawInsert('''
      INSERT OR REPLACE INTO stores (id, user_id, store_name, logo, bio, city, phone, is_verified, rating) VALUES
      ('store_01', '2', 'متجر التكنولوجيا الحديثة', '', 'أفضل عروض المقايضة في عالم الإلكترونيات والهواتف الذكية', 'صنعاء', '777111222', 1, 4.9)
    ''');

    final itemCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM items'),
    );

    if (itemCount == null || itemCount == 0) {
      await db.rawInsert('''
        INSERT OR REPLACE INTO items (id, user_id, category_id, title, description, brand, model, condition, quality, quantity, estimated_value, city, phone_number, wanted_description, wanted_category_id, swap_type, status, is_featured, views_count, created_at) VALUES
        ('1', '3', '1', 'آيفون 13 برو ماكس 256GB', 'مستعمل بحالة ممتازة جداً بطارية 89% مع كافة كرتونه وملحقاته الأصلية', 'Apple', '13 Pro Max', 'ممتاز', 'أصلي وكالة', 1, 650.0, 'صنعاء', '771234567', 'أرغب بمقايضته بلابتوب قيمنق إم إس أي أو ماك بوك برو M1', '1', 'Direct', 'Available', 1, 45, '$now'),
        ('2', '2', '1', 'سامسونج S23 ألترا 512GB', 'جديد تماماً بالكرتون، مع ضمان المتجر لمدة 6 أشهر. متاح للمقايضة مع آيفون أو أجهزة لوحية', 'Samsung', 'S23 Ultra', 'جديد', 'أصلي وكالة', 1, 750.0, 'صنعاء', '777111222', 'آيفون 13 أو 14 برو ماكس مع دفع الفارق', '1', 'Swap+Cash', 'Available', 1, 88, '$now'),
        ('3', '4', '5', 'طقم كنب تركي فاخر 7 مقاعد', 'طقم صالون تركي قماش مخمل عالي الجودة بحالة ممتازة جداً ونظيف جداً', 'Istikbal', '2024', 'شبه جديد', 'درجة أولى', 1, 450.0, 'عدن', '772345678', 'أرغب بمقايضته بشاشة تلفزيون ذكية 65 بوصة أو أيباد حديث', '1', 'Direct', 'Available', 0, 32, '$now'),
        ('4', '3', '7', 'بلايستيشن 5 مع يدين تحكم و 4 ألعاب', 'PS5 النسخة الرقمية مع يدين أصلية وألعاب فيفا وجاد أوف وور وسبايدرمان', 'Sony', 'PS5 Digital', 'شبه جديد', 'أصلي وكالة', 1, 480.0, 'صنعاء', '771234567', 'طقم جلوس أو شاشة 4K', '5', 'Direct', 'Available', 1, 64, '$now');
      ''');

      await db.rawInsert('''
        INSERT OR REPLACE INTO item_images (id, item_id, image_path, is_primary) VALUES
        ('img_1', '1', 'assets/images/placeholder_iphone.png', 1),
        ('img_2', '2', 'assets/images/placeholder_s23.png', 1),
        ('img_3', '3', 'assets/images/placeholder_furniture.png', 1),
        ('img_4', '4', 'assets/images/placeholder_ps5.png', 1);
      ''');
    }
  }

  /// Cleans all user data, items, offers, and notifications
  static Future<void> clearAllUserAndMarketData(Database db) async {
    await db.delete('items');
    await db.delete('item_images');
    await db.delete('wanted_items');
    await db.delete('swap_offers');
    await db.delete('swap_history_log');
    await db.delete('notifications');
    await db.delete('favorites');
    await db.delete('ratings');
    await db.delete('reports');
    await db.delete('stores');
    await db.delete('users');
  }
}
