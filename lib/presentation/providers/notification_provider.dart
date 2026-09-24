import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/marketplace_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final MarketplaceRepository _repo = MarketplaceRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repo.getNotifications(userId);
      if (_notifications.isEmpty && userId.isNotEmpty && userId != 'guest') {
        await _repo.addNotification(
          userId: userId,
          title: '⚡ فرص مقايضة ذكية متاحة لسلعك',
          body: 'يقوم محرك المطابقة الذكي برصد العروض والسلع الجديدة الملائمة لاهتماماتك في السوق الحي.',
          type: 'match_found',
        );
        await _repo.addNotification(
          userId: userId,
          title: '🛡️ نصائح المقايضة والمعاينة الآمنة',
          body: 'حرصاً على سلامتك: احرص دائماً على مقابلة شريك المقايضة نهاراً في مكان عام وفحص السلعة يداً بيد.',
          type: 'safety_tip',
        );
        await _repo.addNotification(
          userId: userId,
          title: '✨ مرحباً بك في منصة بدلها',
          body: 'حسابك مفعل بنجاح وموثق برصيد ثقة قياسي. يمكنك الآن نشر سلعك وتقديم عروض التبادل بحرية.',
          type: 'welcome',
        );
        _notifications = await _repo.getNotifications(userId);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notifId, String userId) async {
    await _repo.markNotificationRead(notifId);
    await loadNotifications(userId);
  }
}
