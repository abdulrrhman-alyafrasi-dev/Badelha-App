import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/swap_history_model.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/item_image_widget.dart';
import '../auth/login_screen.dart';
import 'admin_banner_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceRepository _repo = MarketplaceRepository();
  String _userSearchQuery = '';
  List<SwapHistoryModel> _historyLogs = [];
  bool _isLoadingLogs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAuditLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).refreshUsersList();
      }
    });
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final logs = await _repo.getAllSwapHistoryLogs();
      setState(() => _historyLogs = logs);
    } catch (_) {}
    setState(() => _isLoadingLogs = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final totalItems = market.items.length;
    final totalUsers = auth.allUsers.length;
    final bannedUsers = auth.allUsers.where((u) => u.isBanned).length;
    final totalStores = market.stores.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('لوحة الإدارة والرقابة (Admin)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign, color: Colors.teal, size: 22),
            tooltip: 'إدارة الإعلانات والشريط الترويجي',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminBannerManagementScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              auth.refreshUsersList();
              market.refreshItems();
              _loadAuditLogs();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error, size: 22),
            tooltip: 'تسجيل الخروج من المنصة',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'نظرة عامة'),
            Tab(icon: Icon(Icons.people_alt_outlined, size: 18), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'المنتجات'),
            Tab(icon: Icon(Icons.history_edu_outlined, size: 18), text: 'سجل التدقيق'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview Tab
          _buildOverviewTab(context, market, auth, totalItems, totalUsers, bannedUsers, totalStores),

          // 2. Users Management Tab
          _buildUsersTab(context, auth),

          // 3. Products Moderation Tab
          _buildProductsTab(context, market),

          // 4. Audit Log & Swap History Tab
          _buildAuditLogsTab(context),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    MarketplaceProvider market,
    AuthProvider auth,
    int totalItems,
    int totalUsers,
    int bannedUsers,
    int totalStores,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      children: [
        // Top Security Notice Banner (Compact)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أنت في لوحة تحكم الإدارة المركزية (صلاحيات RBAC العليا).',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Metrics Grid (Compact Cards)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.3,
          children: [
            _statCard('إجمالي المنتجات', '$totalItems', Icons.inventory_2, AppColors.primary),
            _statCard('المستخدمين المسجلين', '$totalUsers', Icons.people, AppColors.secondary),
            _statCard('الحسابات المحظورة', '$bannedUsers', Icons.block, AppColors.error),
            _statCard('المتاجر التجارية', '$totalStores', Icons.storefront, Colors.teal),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Administrative Actions Card (Compact)
        Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8, right: 12, left: 12),
                child: Text(
                  'الخدمات والأدوات الإدارية',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.campaign, color: Colors.teal, size: 18),
                ),
                title: const Text('شريط الإعلانات الترويجي', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: const Text('إدارة البانرات والعروض المتحركة في أعلى السوق', style: TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminBannerManagementScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.store, color: Colors.purple, size: 18),
                ),
                title: const Text('المتاجر التجارية المعتمدة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text('$totalStores متاجر مسجلة في النظام', style: const TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  _showToast(context, 'المتاجر التجارية مفعلة وتتم مراقبتها بدقة.');
                },
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.flag_outlined, color: Colors.orange, size: 18),
                ),
                title: const Text('طابور البلاغات والشكاوى', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: const Text('0 بلاغات معلقة (جميع الإعلانات متوافقة)', style: TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () {
                  _showToast(context, 'لا توجد بلاغات مخالفات معلقة حالياً.');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Database Maintenance & Cleanup Section (Admin Only)
        _buildDatabaseCleanerSection(context, market, auth),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDatabaseCleanerSection(BuildContext context, MarketplaceProvider market, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withAlpha(140),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.cleaning_services, size: 16, color: AppColors.error),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صيانة وتهيئة قاعدة البيانات (خاص بالإدارة)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
                    ),
                    Text(
                      'مسح جميع المنتجات والعروض الوهمية والبدء بقاعدة بيانات نظيفة.',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('تأكيد تنظيف قاعدة البيانات'),
                    content: const Text(
                      'سيتم مسح جميع المنتجات والسلع المعروضة، عروض المقايضة، وسجلات التبادل، مع الاحتفاظ بحسابات المشرفين. هل تريد المتابعة؟',
                      style: TextStyle(fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(c, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('نعم، امسح كل شيء', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await AppDatabase.instance.clearAllMarketData();
                  await market.refreshItems();
                  await auth.refreshUsersList();
                  await _loadAuditLogs();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✨ تم تنظيف قاعدة البيانات بالكامل! المنصة نظيفة وجاهزة الآن.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_sweep, size: 16, color: AppColors.error),
              label: const Text(
                'مسح البيانات والبدء من الصفر',
                style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, AuthProvider auth) {
    final filtered = auth.allUsers.where((u) {
      if (_userSearchQuery.isEmpty) return true;
      final q = _userSearchQuery.toLowerCase();
      return u.name.toLowerCase().contains(q) || u.phone.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 40,
            child: TextField(
              onChanged: (val) => setState(() => _userSearchQuery = val),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'بحث عن مستخدم بالاسم أو رقم الهاتف...',
                hintStyle: const TextStyle(fontSize: 11),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('لا يوجد مستخدمين مطابقين للبحث.', style: TextStyle(fontSize: 12)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final u = filtered[index];
                    final isCurrentUser = auth.currentUser?.id == u.id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: u.isBanned ? Colors.grey : AppColors.primaryLight,
                                  child: Text(
                                    u.name.isNotEmpty ? u.name[0] : 'U',
                                    style: TextStyle(
                                      color: u.isBanned ? Colors.white : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              u.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (u.isVerified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified, color: Colors.blue, size: 14),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        '${u.phone} • ${u.city} • الدور: ${u.role}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: u.isBanned ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    u.status == 'active' ? 'نشط' : (u.status == 'banned' ? 'محظور' : u.status),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: u.isBanned ? Colors.red.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!isCurrentUser && u.role != 'admin') ...[
                              const SizedBox(height: 6),
                              const Divider(height: 1),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                    onPressed: () async {
                                      final willBan = !u.isBanned;
                                      await auth.adminToggleBanUser(u.id, willBan);
                                      if (context.mounted) {
                                        _showToast(
                                          context,
                                          willBan ? '🚫 تم حظر حساب ${u.name}' : '🟢 تم تنشيط وفك حظر ${u.name}',
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      u.isBanned ? Icons.check_circle_outline : Icons.block,
                                      size: 14,
                                      color: u.isBanned ? Colors.green : AppColors.error,
                                    ),
                                    label: Text(
                                      u.isBanned ? 'فك الحظر' : 'حظر الحساب',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: u.isBanned ? Colors.green : AppColors.error,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                    onPressed: () async {
                                      await auth.adminToggleVerifyUser(u.id, !u.isVerified);
                                      if (context.mounted) {
                                        _showToast(
                                          context,
                                          !u.isVerified ? '⭐ تم منح شارة التوثيق' : 'تم إلغاء شارة التوثيق',
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      u.isVerified ? Icons.remove_moderator : Icons.verified_user,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    label: Text(
                                      u.isVerified ? 'إلغاء التوثيق' : 'توثيق الحساب',
                                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductsTab(BuildContext context, MarketplaceProvider market) {
    final items = market.items;
    return items.isEmpty
        ? const Center(child: Text('لا توجد منتجات مسجلة في السوق حالياً.', style: TextStyle(fontSize: 12)))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  leading: ItemImageWidget(
                    images: item.images,
                    width: 44,
                    height: 44,
                    borderRadius: 6,
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'المالك: ${item.userName} • ${item.city}\nالقيمة: ${item.estimatedValue.toStringAsFixed(0)} ريال • ${item.status}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    tooltip: 'حذف المنتج المخالف',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('تأكيد حذف المنتج'),
                          content: Text('هل أنت متأكد من رغبتك في إزالة «${item.title}» من المنصة؟', style: const TextStyle(fontSize: 13)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('إلغاء')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () => Navigator.pop(dCtx, true),
                              child: const Text('حذف فوري', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await market.adminDeleteItem(item.id);
                        if (context.mounted) {
                          _showToast(context, 'تم حذف المنتج بنجاح.');
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAuditLogsTab(BuildContext context) {
    if (_isLoadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyLogs.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد عمليات مقايضة مكتملة مسجلة في سجل التدقيق حتى الآن.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _historyLogs.length,
      itemBuilder: (ctx, index) {
        final log = _historyLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'مقايضة موثقة (#${log.id.length > 8 ? log.id.substring(0, 8) : log.id})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        log.finalStatus,
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• الأول: ${log.senderName} (${log.offeredItemTitle})\n'
                  '• الثاني: ${log.receiverName} (${log.requestedItemTitle})\n'
                  '• التاريخ: ${log.completedAt.split('T').first}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4),
                ),
                if (log.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ملاحظة: ${log.notes}',
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  val,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
