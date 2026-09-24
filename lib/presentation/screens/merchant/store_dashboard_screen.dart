import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/swap_provider.dart';
import '../add_item/add_item_screen.dart';
import '../auth/login_screen.dart';
import '../offers/offers_screen.dart';
import '../../widgets/item_image_widget.dart';

class StoreDashboardScreen extends StatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<MarketplaceProvider>(context, listen: false).loadUserItems(auth.currentUser!.id);
        Provider.of<SwapProvider>(context, listen: false).loadOffers(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final market = Provider.of<MarketplaceProvider>(context);
    final swap = Provider.of<SwapProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة المتجر التجاري')),
        body: const Center(child: Text('يرجى تسجيل الدخول بحساب تاجر أولاً.')),
      );
    }

    final storeItems = market.myItems;
    final activeOffers = swap.receivedOffers.where((o) => o.status == 'Pending' || o.status == 'Accepted').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المتجر (Merchant Hub)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              market.loadUserItems(user.id);
              swap.loadOffers(user.id);
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
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Store Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.storefront, color: Color(0xFF203A43), size: 36),
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 12, color: Colors.black),
                                    SizedBox(width: 4),
                                    Text(
                                      'متجر موثق',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.city} • هاتف: ${user.phone}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${user.rating.toStringAsFixed(1)} تقييم المتجر (${user.swapsCompleted} صفقة)',
                                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricBadge('إجمالي المنتجات', '${storeItems.length}', Icons.inventory_2),
                    _metricBadge('عروض معلقة', '$activeOffers', Icons.swap_horizontal_circle),
                    _metricBadge('صفقات منجزة', '${user.swapsCompleted}', Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),

          // Action Button: Add new store product
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddItemScreen()),
                  );
                },
                icon: const Icon(Icons.add_business),
                label: const Text('إضافة منتج تجاري جديد إلى الكتالوج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'منتجات المتجر (${storeItems.length})'),
              Tab(text: 'عروض المقايضة الواردة (${swap.receivedOffers.length})'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Products List
                storeItems.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد منتجات معروضة حالياً في متجرك.\nاضغط على الزر أعلاه لإضافة أول منتج.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: storeItems.length,
                        itemBuilder: (ctx, index) {
                          final item = storeItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ItemImageWidget(
                                    images: item.images,
                                    width: 70,
                                    height: 70,
                                    borderRadius: 10,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'القيمة: ${item.estimatedValue.toStringAsFixed(0)} ريال • ${item.condition}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item.isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.status,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (item.isExpired)
                                              const Text(
                                                'منتهي الصلاحية',
                                                style: TextStyle(fontSize: 10, color: AppColors.error),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Refresh listing button (Bumps product to top)
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                                    tooltip: 'تجديد وتنشيط العرض في السوق',
                                    onPressed: () async {
                                      final success = await market.refreshListing(item.id, user.id);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✨ تم تجديد وتنشيط العرض بنجاح ورفعه لقمة نتائج السوق!'),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // Offers list
                swap.receivedOffers.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد عروض مقايضة واردة لمتجرك حالياً.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: swap.receivedOffers.length,
                        itemBuilder: (ctx, index) {
                          final offer = swap.receivedOffers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              leading: const Icon(Icons.swap_calls, color: AppColors.primary),
                              title: Text('عرض من: ${offer.senderName}'),
                              subtitle: Text(
                                'السلعة المعروضة: ${offer.offeredItemTitle}\nالمطلوبة: ${offer.requestedItemTitle}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                offer.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: offer.isCompleted ? Colors.green : AppColors.primary,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const OffersScreen()),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBadge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}
