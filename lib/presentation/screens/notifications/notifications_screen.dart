import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../matching/smart_matches_screen.dart';
import '../offers/offers_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.id ?? 'guest_user';
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.currentUser?.id ?? 'guest_user';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('التنبيهات والإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث التنبيهات',
            onPressed: () {
              notifProvider.loadNotifications(userId);
            },
          ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none, size: 54, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'لا توجد تنبيهات جديدة حالياً',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ستظهر هنا إشعارات الصفقات، التطابق الذكي، والتحديثات.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => notifProvider.loadNotifications(userId),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('تحميل التنبيهات الآن'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: notifProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifProvider.notifications[index];
                    final notifColor = _getNotifColor(n.type);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: n.isRead ? const Color(0xFFE2E8F0) : notifColor.withAlpha(100),
                          width: n.isRead ? 0.6 : 1.2,
                        ),
                      ),
                      color: n.isRead ? Colors.white : notifColor.withAlpha(12),
                      child: InkWell(
                        onTap: () {
                          if (!n.isRead && auth.currentUser != null) {
                            notifProvider.markAsRead(n.id, auth.currentUser!.id);
                          }
                          _handleNotifTap(context, n.type);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: notifColor.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getNotifIcon(n.type), color: notifColor, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: notifColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      n.body,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _handleNotifTap(BuildContext context, String type) {
    if (type == 'match_found') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SmartMatchesScreen()));
    } else if (type.contains('offer')) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OffersScreen()));
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'match_found':
        return Colors.deepPurple;
      case 'offer_received':
      case 'offer_accepted':
        return AppColors.primary;
      case 'safety_tip':
        return Colors.teal;
      case 'welcome':
        return Colors.blue;
      case 'rating_received':
        return Colors.amber.shade800;
      default:
        return AppColors.primary;
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'match_found':
        return Icons.bolt;
      case 'offer_received':
        return Icons.sync;
      case 'offer_accepted':
        return Icons.check_circle;
      case 'safety_tip':
        return Icons.shield_outlined;
      case 'welcome':
        return Icons.verified_user_outlined;
      case 'rating_received':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
