import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../merchant/store_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../offers/offers_screen.dart';
import '../item_details/item_details_screen.dart';
import '../../widgets/item_image_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);

    // If Guest (Not Logged In)
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person_outline, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'وضع المتصفح (زائر)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'يمكنك تصفح السوق والسلع بحرية. ولكن للاتصال بالمقايضين، إرسال رسائل، أو تقديم عروض المقايضة، يلزم تسجيل الدخول.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (c) => const LoginScreen(returnAfterLogin: true)),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('تسجيل الدخول / إنشاء حساب جديد'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي ونظام الثقة'),
        actions: [
          if (user.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
              tooltip: 'لوحة الإدارة المركزية (Admin)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
          if (user.isMerchant)
            IconButton(
              icon: const Icon(Icons.storefront, color: Colors.teal),
              tooltip: 'لوحة تحكم المتجر التجاري',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StoreDashboardScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح وحذف جلسة العمل.')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Main Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      await auth.updateAvatar(picked.path);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث صورتك الشخصية بنجاح!')),
                        );
                      }
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        backgroundImage: _getAvatarProvider(user.image),
                        child: (user.image.isEmpty || _getAvatarProvider(user.image) == null)
                            ? Text(
                                user.name.isNotEmpty ? user.name[0] : 'U',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.white, size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.city} • هاتف: ${user.phone}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          auth.trustBadgeTitle,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Trust System Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'نظام الثقة والسمعة التجارية (Trust Score)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricCol('درجة الثقة', '${user.trustScore}/100', AppColors.primaryDark),
                    _metricCol('المقايضات المكتملة', '${user.swapsCompleted}', AppColors.secondary),
                    _metricCol('متوسط التقييم', '${user.rating} ★', AppColors.accent),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: user.trustScore / 100.0,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Options List
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync_alt, color: AppColors.primary),
                  title: const Text('إدارة صفقاتي وعروض المقايضة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (c) => const OffersScreen()));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: AppColors.secondary),
                  title: Text('منتجاتي المعروضة وتجديد العروض (${market.myItems.length})'),
                  subtitle: const Text('متابعة صلاحية الإعلانات وتنشيطها لرفعها في السوق'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    _showMyItemsSheet(context, market, user.id);
                  },
                ),
                if (user.isMerchant) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.storefront, color: Colors.teal),
                    title: const Text('لوحة تحكم المتجر التجاري (Merchant Hub)'),
                    subtitle: const Text('إدارة كتالوج المنتجات وتوثيق المتجر'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoreDashboardScreen()));
                    },
                  ),
                ],
                if (user.isAdmin) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.purple),
                    title: const Text('لوحة الإدارة المركزية (Admin Dashboard)'),
                    subtitle: const Text('إدارة المستخدمين، الرقابة، وحظر الحسابات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _metricCol(String title, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  ImageProvider? _getAvatarProvider(String image) {
    if (image.isEmpty) return null;
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return NetworkImage(image);
    }
    final file = File(image);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  void _showMyItemsSheet(BuildContext context, MarketplaceProvider market, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'إدارة وتجديد المنتجات المعروضة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'يمكنك تجديد أي إعلان منتهي أو قديم لإعادة رفعه إلى أعلى نتائج البحث والسوق.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Divider(height: 20),
              Expanded(
                child: market.myItems.isEmpty
                    ? const Center(child: Text('لم تقم بإضافة أي منتجات بعد.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: market.myItems.length,
                        itemBuilder: (c, idx) {
                          final item = market.myItems[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ItemDetailsScreen(item: item)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ItemImageWidget(
                                      images: item.images,
                                      width: 60,
                                      height: 60,
                                      borderRadius: 8,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.estimatedValue.toStringAsFixed(0)} ريال • ${item.city}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: item.isExpired ? Colors.red.shade50 : Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item.isExpired ? 'منتهي الصلاحية' : item.status,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: item.isExpired ? Colors.red : Colors.green.shade800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Refresh Button
                                    IconButton(
                                      tooltip: 'تجديد العرض',
                                      icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                                      onPressed: () async {
                                        final success = await market.refreshListing(item.id, userId);
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✨ تم تجديد العرض بنجاح ورفعه لقمة نتائج البحث!'),
                                              backgroundColor: AppColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    // Delete Button
                                    IconButton(
                                      tooltip: 'حذف المنتج',
                                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                                      onPressed: () async {
                                        final bool? confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
                                            title: const Text('تأكيد الحذف'),
                                            content: Text('هل أنت متأكد من حذف "${item.title}"؟'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('إلغاء')),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(dCtx, true),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('حذف'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await market.deleteUserItem(item.id, currentUserId: userId);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('🗑️ تم حذف المنتج بنجاح')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
