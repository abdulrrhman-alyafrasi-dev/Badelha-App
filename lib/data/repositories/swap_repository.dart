import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/swap_offer_model.dart';

class SwapRepository {
  final AppDatabase _dbProvider = AppDatabase.instance;

  /// Create a new swap offer
  Future<void> createSwapOffer(SwapOfferModel offer) async {
    final db = await _dbProvider.database;
    await db.insert(
      'swap_offers',
      offer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Create an automated notification for the receiver
    await db.insert('notifications', {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': offer.receiverId,
      'title': '🔄 عرض مقايضة جديد!',
      'body': 'تلقيت عرض مقايضة جديد لمنتجك.',
      'type': 'offer_received',
      'payload': offer.id,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get offers received by user
  Future<List<SwapOfferModel>> getReceivedOffers(String userId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT o.*,
             offered.title as offered_item_title, offered.estimated_value as offered_item_value,
             requested.title as requested_item_title, requested.estimated_value as requested_item_value,
             sender.name as sender_name, sender.phone as sender_phone,
             receiver.name as receiver_name, receiver.phone as receiver_phone
      FROM swap_offers o
      LEFT JOIN items offered ON o.offered_item_id = offered.id
      LEFT JOIN items requested ON o.requested_item_id = requested.id
      LEFT JOIN users sender ON o.sender_id = sender.id
      LEFT JOIN users receiver ON o.receiver_id = receiver.id
      WHERE o.receiver_id = ?
      ORDER BY o.created_at DESC
    ''', [userId]);

    final List<SwapOfferModel> offers = [];
    for (var map in maps) {
      final offeredImg = await _getFirstImage(db, map['offered_item_id']);
      final requestedImg = await _getFirstImage(db, map['requested_item_id']);

      final fullMap = Map<String, dynamic>.from(map);
      fullMap['offered_item_image'] = offeredImg;
      fullMap['requested_item_image'] = requestedImg;
      offers.add(SwapOfferModel.fromMap(fullMap));
    }
    return offers;
  }

  /// Get offers sent by user
  Future<List<SwapOfferModel>> getSentOffers(String userId) async {
    final db = await _dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT o.*,
             offered.title as offered_item_title, offered.estimated_value as offered_item_value,
             requested.title as requested_item_title, requested.estimated_value as requested_item_value,
             sender.name as sender_name, sender.phone as sender_phone,
             receiver.name as receiver_name, receiver.phone as receiver_phone
      FROM swap_offers o
      LEFT JOIN items offered ON o.offered_item_id = offered.id
      LEFT JOIN items requested ON o.requested_item_id = requested.id
      LEFT JOIN users sender ON o.sender_id = sender.id
      LEFT JOIN users receiver ON o.receiver_id = receiver.id
      WHERE o.sender_id = ?
      ORDER BY o.created_at DESC
    ''', [userId]);

    final List<SwapOfferModel> offers = [];
    for (var map in maps) {
      final offeredImg = await _getFirstImage(db, map['offered_item_id']);
      final requestedImg = await _getFirstImage(db, map['requested_item_id']);

      final fullMap = Map<String, dynamic>.from(map);
      fullMap['offered_item_image'] = offeredImg;
      fullMap['requested_item_image'] = requestedImg;
      offers.add(SwapOfferModel.fromMap(fullMap));
    }
    return offers;
  }

  Future<String> _getFirstImage(Database db, String itemId) async {
    final res = await db.query(
      'item_images',
      where: 'item_id = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return res.first['image_path'] as String;
    }
    return '';
  }

  /// Update offer status (Accepted, Rejected, Cancelled)
  Future<void> updateOfferStatus(String offerId, String newStatus) async {
    final db = await _dbProvider.database;
    await db.update(
      'swap_offers',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [offerId],
    );

    // If accepted, reserve both items and notify sender
    if (newStatus == 'Accepted' || newStatus == 'Safety Confirmation') {
      final res = await db.query('swap_offers', where: 'id = ?', whereArgs: [offerId]);
      if (res.isNotEmpty) {
        final offer = res.first;
        await db.update('items', {'status': 'Reserved'}, where: 'id = ?', whereArgs: [offer['offered_item_id']]);
        await db.update('items', {'status': 'Reserved'}, where: 'id = ?', whereArgs: [offer['requested_item_id']]);

        await db.insert('notifications', {
          'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': offer['sender_id'],
          'title': '🎉 تم قبول عرض المقايضة!',
          'body': 'تم قبول عرض المقايضة. يرجى مراجعة إرشادات الأمان وسياسة التحقق المباشر قبل إتمام الصفقة.',
          'type': 'offer_accepted',
          'payload': offerId,
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } else if (newStatus == 'Meeting Pending') {
      final res = await db.query('swap_offers', where: 'id = ?', whereArgs: [offerId]);
      if (res.isNotEmpty) {
        final offer = res.first;
        await db.update('items', {'status': 'In Swap'}, where: 'id = ?', whereArgs: [offer['offered_item_id']]);
        await db.update('items', {'status': 'In Swap'}, where: 'id = ?', whereArgs: [offer['requested_item_id']]);

        // Send meeting safety reminders to both parties
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await db.insert('notifications', {
          'id': 'notif_${timestamp}_1',
          'user_id': offer['sender_id'],
          'title': '🛡️ تذكير أمني قبل المقابلة',
          'body': 'تذكير: افحص المنتج وتأكد من هوية الطرف المقايض بعناية في مكان عام وآمن قبل تسليم سلعتك.',
          'type': 'safety_reminder',
          'payload': offerId,
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
        await db.insert('notifications', {
          'id': 'notif_${timestamp}_2',
          'user_id': offer['receiver_id'],
          'title': '🛡️ تذكير أمني قبل المقابلة',
          'body': 'تذكير: افحص المنتج وتأكد من هوية الطرف المقايض بعناية في مكان عام وآمن قبل تسليم سلعتك.',
          'type': 'safety_reminder',
          'payload': offerId,
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } else if (newStatus == 'Completed') {
      // Complete swap workflow
      final res = await db.query('swap_offers', where: 'id = ?', whereArgs: [offerId]);
      if (res.isNotEmpty) {
        final offer = res.first;
        await db.update('items', {'status': 'Completed'}, where: 'id = ?', whereArgs: [offer['offered_item_id']]);
        await db.update('items', {'status': 'Completed'}, where: 'id = ?', whereArgs: [offer['requested_item_id']]);

        // Increment completed swaps for both users
        await db.rawUpdate('UPDATE users SET swaps_completed = swaps_completed + 1 WHERE id = ?', [offer['sender_id']]);
        await db.rawUpdate('UPDATE users SET swaps_completed = swaps_completed + 1 WHERE id = ?', [offer['receiver_id']]);

        // Insert immutable audit log into swap_history_log
        await db.insert('swap_history_log', {
          'id': 'audit_${DateTime.now().millisecondsSinceEpoch}',
          'swap_offer_id': offerId,
          'sender_id': offer['sender_id'],
          'receiver_id': offer['receiver_id'],
          'offered_item_id': offer['offered_item_id'],
          'requested_item_id': offer['requested_item_id'],
          'completed_at': DateTime.now().toIso8601String(),
          'final_status': 'Completed',
          'notes': 'تمت عملية التبادل بنجاح عبر تأكيد الأمان الثنائي والمقابلة المادية المباشرة.',
        });

        // Notifications: Can now rate partner
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await db.insert('notifications', {
          'id': 'notif_${timestamp}_rate1',
          'user_id': offer['sender_id'],
          'title': '⭐ تم تسجيل المقايضة بنجاح!',
          'body': 'تم إتمام المقايضة وتوثيقها رسمياً. يمكنك الآن تقييم شريكك في التبادل.',
          'type': 'rate_partner',
          'payload': offerId,
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
        await db.insert('notifications', {
          'id': 'notif_${timestamp}_rate2',
          'user_id': offer['receiver_id'],
          'title': '⭐ تم تسجيل المقايضة بنجاح!',
          'body': 'تم إتمام المقايضة وتوثيقها رسمياً. يمكنك الآن تقييم شريكك في التبادل.',
          'type': 'rate_partner',
          'payload': offerId,
          'is_read': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }
}
