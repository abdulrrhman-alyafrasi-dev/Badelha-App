import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/notification_model.dart';
import '../models/store_model.dart';
import '../models/user_model.dart';
import '../models/wanted_item_model.dart';
import '../models/swap_history_model.dart';
import '../services/api_client.dart';

class MarketplaceRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  Future<Database> get database => _dbProvider.database;

  /// Fetch all active items with joined user and category details
  Future<List<ItemModel>> getAvailableItems({
    String? categoryId,
    String? city,
    String? condition,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String? sortBy, // 'newest', 'value_asc', 'value_desc', 'highest_rated'
  }) async {
    try {
      final response = await ApiClient().getItems(
        categoryId: categoryId,
        city: city,
        condition: condition,
        minValue: minPrice,
        maxValue: maxPrice,
        search: searchQuery,
      );

      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final List<dynamic> dataList = response.data['data'];
        final remoteItems = dataList.map((j) => ItemModel.fromJson(j as Map<String, dynamic>)).toList();
        if (remoteItems.isNotEmpty) {
          _cacheRemoteItems(remoteItems);
          return remoteItems;
        }
      }
    } catch (e) {
      debugPrint('ApiClient getAvailableItems fallback to local SQLite: $e');
    }

    final db = await _dbProvider.database;

    String query = '''
      SELECT i.*, 
             u.name as user_name, u.city as user_city, u.rating as user_rating, 
             u.trust_score as user_trust_score, u.image as user_image, u.email as user_email, u.is_verified as user_is_verified,
             c.name as category_name
      FROM items i
      LEFT JOIN users u ON i.user_id = u.id
      LEFT JOIN categories c ON i.category_id = c.id
      WHERE i.status = 'Available'
    ''';

    final List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId.isNotEmpty) {
      query += ' AND (i.category_id = ? OR c.parent_id = ?)';
      whereArgs.add(categoryId);
      whereArgs.add(categoryId);
    }

    if (city != null && city.isNotEmpty && city != 'الكل') {
      query += ' AND i.city = ?';
      whereArgs.add(city);
    }

    if (condition != null && condition.isNotEmpty && condition != 'الكل') {
      query += ' AND i.condition = ?';
      whereArgs.add(condition);
    }

    if (brand != null && brand.isNotEmpty && brand != 'الكل') {
      query += ' AND i.brand LIKE ?';
      whereArgs.add('%$brand%');
    }

    if (minPrice != null) {
      query += ' AND i.estimated_value >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      query += ' AND i.estimated_value <= ?';
      whereArgs.add(maxPrice);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query += ''' AND (
        i.title LIKE ? OR 
        i.description LIKE ? OR 
        i.brand LIKE ? OR 
        i.model LIKE ? OR 
        i.wanted_description LIKE ? OR
        u.name LIKE ?
      )''';
      final term = '%${searchQuery.trim()}%';
      whereArgs.addAll([term, term, term, term, term, term]);
    }

    // Sorting
    switch (sortBy) {
      case 'value_asc':
        query += ' ORDER BY i.estimated_value ASC';
        break;
      case 'value_desc':
        query += ' ORDER BY i.estimated_value DESC';
        break;
      case 'highest_rated':
        query += ' ORDER BY u.trust_score DESC';
        break;
      case 'newest':
      default:
        query += ' ORDER BY i.is_featured DESC, COALESCE(i.last_refresh_at, i.created_at) DESC, i.created_at DESC';
        break;
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    final List<ItemModel> items = [];
    for (var map in maps) {
      final images = await getItemImages(map['id'] as String);
      items.add(ItemModel.fromMap(map, imagesList: images));
    }

    return items;
  }

  /// Get image paths for an item
  Future<List<String>> getItemImages(String itemId) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'item_images',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'is_primary DESC',
    );
    return res.map((e) => e['image_path'] as String).toList();
  }

  /// Fetch single item by ID
  Future<ItemModel?> getItemById(String itemId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, 
             u.name as user_name, u.city as user_city, u.rating as user_rating, 
             u.trust_score as user_trust_score, u.image as user_image, u.email as user_email, u.is_verified as user_is_verified,
             c.name as category_name
      FROM items i
      LEFT JOIN users u ON i.user_id = u.id
      LEFT JOIN categories c ON i.category_id = c.id
      WHERE i.id = ?
    ''', [itemId]);

    if (maps.isEmpty) return null;
    final images = await getItemImages(itemId);
    return ItemModel.fromMap(maps.first, imagesList: images);
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbProvider.database;
    final res = await db.query('categories');
    return res.map((e) => CategoryModel.fromMap(e)).toList();
  }

  String _mapCategoryIdToNumeric(String catId) {
    if (int.tryParse(catId) != null) return catId;
    switch (catId) {
      case 'cat_phones':
        return '1';
      case 'cat_laptops':
        return '2';
      case 'cat_gaming':
        return '3';
      case 'cat_electronics':
        return '4';
      case 'cat_watches':
        return '5';
      case 'cat_home':
        return '6';
      case 'cat_vehicles':
        return '7';
      default:
        return '1';
    }
  }

  String _mapConditionToDbEnum(String condition) {
    final c = condition.trim();
    if (c == 'new' || c == 'like_new' || c == 'excellent' || c == 'good' || c == 'fair') {
      return c;
    }
    if (c.contains('جديد بالكرتون') || c == 'جديد') return 'new';
    if (c.contains('شبه جديد')) return 'like_new';
    if (c.contains('ممتاز')) return 'excellent';
    if (c.contains('جيد')) return 'good';
    if (c.contains('مقبول')) return 'fair';
    return 'like_new';
  }

  String _mapSwapTypeToDbEnum(String swapType) {
    final s = swapType.trim();
    if (s == 'exact_match' || s == 'cash_adjustment' || s == 'any') {
      return s;
    }
    if (s == 'Swap+Cash' || s.contains('فرق')) return 'cash_adjustment';
    if (s == 'Any' || s.contains('أي عرض')) return 'any';
    return 'exact_match';
  }

  /// Add new Item
  Future<void> addItem(ItemModel item, List<String> images) async {
    try {
      final res = await ApiClient().createItem({
        'category_id': _mapCategoryIdToNumeric(item.categoryId),
        'title': item.title,
        'description': item.description,
        'estimated_value': item.estimatedValue,
        'city': item.city.isNotEmpty ? item.city : 'صنعاء',
        'condition': _mapConditionToDbEnum(item.condition),
        'swap_type': _mapSwapTypeToDbEnum(item.swapType),
        'wanted_category_id': item.wantedCategoryId != null ? _mapCategoryIdToNumeric(item.wantedCategoryId!) : null,
        'wanted_description': item.wantedDescription,
        'images': images.isNotEmpty ? images : item.images,
      });
      debugPrint('✅ PostgreSQL 18 Item Created Successfully: ${res.statusCode}');
    } catch (e) {
      debugPrint('ApiClient addItem remote sync error: $e');
    }

    final db = await _dbProvider.database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    for (int i = 0; i < images.length; i++) {
      await db.insert('item_images', {
        'id': '${item.id}_img_$i',
        'item_id': item.id,
        'image_path': images[i],
        'is_primary': i == 0 ? 1 : 0,
      });
    }
  }

  /// Update Item (Strictly owned by user or admin)
  Future<bool> updateItem(
    ItemModel item,
    List<String> images, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    // 1. Verify ownership locally
    if (!isAdmin && item.userId != currentUserId) {
      debugPrint('⛔ Security: User $currentUserId attempted to edit item ${item.id} belonging to ${item.userId}');
      return false;
    }

    // 2. Remote API sync
    try {
      await ApiClient().updateItem(item.id, {
        'category_id': _mapCategoryIdToNumeric(item.categoryId),
        'title': item.title,
        'description': item.description,
        'estimated_value': item.estimatedValue,
        'city': item.city.isNotEmpty ? item.city : 'صنعاء',
        'condition': _mapConditionToDbEnum(item.condition),
        'swap_type': _mapSwapTypeToDbEnum(item.swapType),
        'wanted_category_id': item.wantedCategoryId != null ? _mapCategoryIdToNumeric(item.wantedCategoryId!) : null,
        'wanted_description': item.wantedDescription,
        'images': images.isNotEmpty ? images : item.images,
      });
    } catch (e) {
      debugPrint('ApiClient updateItem remote sync error: $e');
    }

    // 3. Local SQLite atomic update
    final db = await _dbProvider.database;
    final whereClause = isAdmin ? 'id = ?' : 'id = ? AND user_id = ?';
    final whereArgs = isAdmin ? [item.id] : [item.id, currentUserId];

    final count = await db.update('items', item.toMap(), where: whereClause, whereArgs: whereArgs);

    if (images.isNotEmpty) {
      await db.delete('item_images', where: 'item_id = ?', whereArgs: [item.id]);
      for (int i = 0; i < images.length; i++) {
        await db.insert('item_images', {
          'id': '${item.id}_img_$i',
          'item_id': item.id,
          'image_path': images[i],
          'is_primary': i == 0 ? 1 : 0,
        });
      }
    }

    return count > 0;
  }

  /// Delete Item (Strictly owned by user or admin)
  Future<bool> deleteItem(
    String itemId, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    // 1. Remote API sync
    try {
      await ApiClient().deleteItem(itemId);
    } catch (e) {
      debugPrint('ApiClient deleteItem remote sync error: $e');
    }

    // 2. Local SQLite delete with ownership check
    final db = await _dbProvider.database;
    final whereClause = isAdmin ? 'id = ?' : 'id = ? AND user_id = ?';
    final whereArgs = isAdmin ? [itemId] : [itemId, currentUserId];

    final count = await db.delete('items', where: whereClause, whereArgs: whereArgs);
    if (count > 0) {
      await db.delete('item_images', where: 'item_id = ?', whereArgs: [itemId]);
    }
    return count > 0;
  }

  /// Update item status
  Future<void> updateItemStatus(String itemId, String newStatus) async {
    final db = await _dbProvider.database;
    await db.update(
      'items',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Get items belonging to a specific user
  Future<List<ItemModel>> getUserItems(String userId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, 
             u.name as user_name, u.city as user_city, u.rating as user_rating, 
             u.trust_score as user_trust_score, u.image as user_image, u.email as user_email, u.is_verified as user_is_verified,
             c.name as category_name
      FROM items i
      LEFT JOIN users u ON i.user_id = u.id
      LEFT JOIN categories c ON i.category_id = c.id
      WHERE i.user_id = ?
      ORDER BY i.created_at DESC
    ''', [userId]);

    final List<ItemModel> items = [];
    for (var map in maps) {
      final images = await getItemImages(map['id'] as String);
      items.add(ItemModel.fromMap(map, imagesList: images));
    }
    return items;
  }

  /// Get Wanted items for a user
  Future<List<WantedItemModel>> getUserWantedItems(String userId) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'wanted_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => WantedItemModel.fromMap(e)).toList();
  }

  /// Add a wanted item expectation
  Future<void> addWantedItem(WantedItemModel wanted) async {
    final db = await _dbProvider.database;
    await db.insert('wanted_items', wanted.toMap());
  }

  /// Get all verified stores
  Future<List<StoreModel>> getStores() async {
    final db = await _dbProvider.database;
    final res = await db.query('stores');
    final List<StoreModel> stores = [];
    for (var row in res) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM items WHERE user_id = ?', [row['user_id']]),
      ) ?? 0;
      stores.add(StoreModel.fromMap(row, itemsCount: count));
    }
    return stores;
  }

  /// Get user notifications
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return res.map((e) => NotificationModel.fromMap(e)).toList();
  }

  /// Mark notification read
  Future<void> markNotificationRead(String id) async {
    final db = await _dbProvider.database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Add a notification
  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    final db = await _dbProvider.database;
    await db.insert('notifications', {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode.abs()}',
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'related_id': relatedId,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (res.isEmpty) return null;
    return UserModel.fromMap(res.first);
  }

  /// Get all users for admin or test switching
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await ApiClient().getAdminUsers();
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final List<dynamic> dataList = response.data['data'];
        final remoteUsers = dataList.map((j) {
          final map = j as Map<String, dynamic>;
          return UserModel.fromMap({
            'id': map['id'].toString(),
            'name': map['name'] ?? '',
            'email': map['email'] ?? '',
            'phone': map['phone'] ?? '',
            'password': '',
            'city': map['city'] ?? 'صنعاء',
            'role': map['role'] ?? 'customer',
            'status': map['status'] ?? 'active',
            'rating': (map['rating'] as num?)?.toDouble() ?? 5.0,
            'trust_score': (map['trust_score'] as num?)?.toInt() ?? 100,
            'is_verified': map['is_verified'] == true ? 1 : 0,
            'image': map['image'] ?? '',
            'created_at': map['created_at'] ?? DateTime.now().toIso8601String(),
          });
        }).toList();

        if (remoteUsers.isNotEmpty) {
          final db = await _dbProvider.database;
          await db.delete('users'); // Clear legacy seed users
          for (var u in remoteUsers) {
            await db.insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
          return remoteUsers;
        }
      }
    } catch (e) {
      debugPrint('ApiClient getAdminUsers fallback to local SQLite: $e');
    }

    final db = await _dbProvider.database;
    final res = await db.query('users');
    return res.map((e) => UserModel.fromMap(e)).toList();
  }

  /// Toggle Favorite
  Future<bool> toggleFavorite(String userId, String itemId) async {
    final db = await _dbProvider.database;
    final check = await db.query(
      'favorites',
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );

    if (check.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, itemId],
      );
      return false;
    } else {
      await db.insert('favorites', {
        'id': 'fav_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'item_id': itemId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    }
  }

  Future<bool> isItemFavorite(String userId, String itemId) async {
    final db = await _dbProvider.database;
    final check = await db.query(
      'favorites',
      where: 'user_id = ? AND item_id = ?',
      whereArgs: [userId, itemId],
    );
    return check.isNotEmpty;
  }

  /// 🔄 Refresh/Renew an item listing (Resets expiration timer to 30 days & updates last_refresh_at)
  Future<bool> refreshItemListing(String itemId) async {
    final db = await _dbProvider.database;
    final now = DateTime.now();
    final expires = now.add(const Duration(days: 30)).toIso8601String();
    final count = await db.update(
      'items',
      {
        'status': 'Available',
        'last_refresh_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'expires_at': expires,
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
    return count > 0;
  }

  /// ⏰ Automatically check and expire items whose expiration date has passed
  Future<int> checkAndExpireListings() async {
    final db = await _dbProvider.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'items',
      {
        'status': 'Expired',
        'updated_at': now,
      },
      where: 'status = ? AND expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: ['Available', now],
    );
  }

  /// 🛡️ Admin: Delete / remove listing
  Future<bool> adminDeleteItem(String itemId) async {
    final db = await _dbProvider.database;
    final count = await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
    return count > 0;
  }

  /// 🛡️ Admin: Toggle user ban or active status
  Future<bool> adminSetUserStatus(String userId, String status) async {
    final db = await _dbProvider.database;
    final count = await db.update(
      'users',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  /// 🛡️ Admin: Toggle verification badge on user
  Future<bool> adminToggleUserVerification(String userId, bool isVerified) async {
    final db = await _dbProvider.database;
    final count = await db.update(
      'users',
      {
        'is_verified': isVerified ? 1 : 0,
        'trust_score': isVerified ? 98 : 75,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  /// 🛡️ Admin: Toggle verification badge on commercial store
  Future<bool> adminToggleStoreVerification(String storeId, bool isVerified) async {
    final db = await _dbProvider.database;
    final count = await db.update(
      'stores',
      {'is_verified': isVerified ? 1 : 0},
      where: 'id = ?',
      whereArgs: [storeId],
    );
    return count > 0;
  }

  /// 📜 Immutable Audit Log: Add record of completed or cancelled swap
  Future<void> addSwapHistoryLog(SwapHistoryModel log) async {
    final db = await _dbProvider.database;
    await db.insert('swap_history_log', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 📜 Fetch all audit logs for admin review
  Future<List<SwapHistoryModel>> getAllSwapHistoryLogs() async {
    final db = await _dbProvider.database;
    final res = await db.rawQuery('''
      SELECT sh.*, 
             u1.name as sender_name, u2.name as receiver_name,
             i1.title as offered_item_title, i2.title as requested_item_title
      FROM swap_history_log sh
      LEFT JOIN users u1 ON sh.sender_id = u1.id
      LEFT JOIN users u2 ON sh.receiver_id = u2.id
      LEFT JOIN items i1 ON sh.offered_item_id = i1.id
      LEFT JOIN items i2 ON sh.requested_item_id = i2.id
      ORDER BY sh.completed_at DESC
    ''');
    return res.map((e) => SwapHistoryModel.fromMap(e)).toList();
  }

  Future<void> _cacheRemoteItems(List<ItemModel> items) async {
    try {
      final db = await _dbProvider.database;
      final batch = db.batch();
      for (final item in items) {
        batch.insert(
          'items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (item.images.isNotEmpty) {
          for (int i = 0; i < item.images.length; i++) {
            batch.insert(
              'item_images',
              {
                'id': '${item.id}_img_$i',
                'item_id': item.id,
                'image_path': item.images[i],
                'is_primary': i == 0 ? 1 : 0,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error caching remote items into SQLite: $e');
    }
  }
}
