import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/item_image_widget.dart';
import '../item_details/item_details_screen.dart';
import '../store/store_profile_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final userCity = auth.currentUser?.city ?? 'صنعاء';

    final nearbyItems = market.items.where((i) => i.city == userCity).toList();
    final featuredItems = market.items.where((i) => i.isFeatured).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navExplore),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 1. Featured Deals (منتجات مميزة)
          if (featuredItems.isNotEmpty) ...[
            _buildSectionHeader('💎 منتجات وصفقات مميزة', 'عروض حصرية موثوقة'),
            const SizedBox(height: 10),
            SizedBox(
              height: 170,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: featuredItems.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) => _buildFeaturedCard(context, featuredItems[i]),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 2. Nearby Deals (صفقات قريبة منك)
          _buildSectionHeader('🔥 صفقات قريبة منك في ($userCity)', 'معاينة واستلام فوري يد بيد'),
          const SizedBox(height: 10),
          if (nearbyItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('لا توجد عروض في $userCity حالياً، تصفح بقية المدن أدناه.', style: const TextStyle(color: AppColors.textMuted)),
            )
          else
            SizedBox(
              height: 155,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: nearbyItems.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) => _buildMiniProductCard(context, nearbyItems[i]),
              ),
            ),

          const SizedBox(height: 24),

          // 3. Top Trusted Traders (مستخدمون موثوقون)
          _buildSectionHeader('⭐ مقايضون موثوقون ذوو سمعة عالية', 'أعلى درجات Trust Score وتقييمات مكتملة'),
          const SizedBox(height: 10),
          SizedBox(
            height: 125,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: auth.allUsers.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final user = auth.allUsers[i];
                return Container(
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      const SizedBox(height: 6),
                      Text(user.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.accent),
                          Text(user.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
                            child: Text('${user.trustScore}% ثقة', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 4. Commercial Verified Stores (المتاجر المعتمدة)
          if (market.stores.isNotEmpty) ...[
            _buildSectionHeader('🏪 متاجر بدلها الرسمية المعتمدة', 'مقايضة مع ضمان تجربة وفحص رسمي'),
            const SizedBox(height: 10),
            ...market.stores.map((s) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryLight,
                      child: Icon(Icons.store, color: AppColors.secondary),
                    ),
                    title: Row(
                      children: [
                        Text(s.storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.primary),
                      ],
                    ),
                    subtitle: Text(s.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => StoreProfileScreen(store: s)),
                      );
                    },
                  ),
                )),
          ],

          const SizedBox(height: 24),

          // 5. Most Wanted Categories & Recently Added
          _buildSectionHeader('📱 الأكثر طلباً للمقايضة', 'سلع يبحث عنها الكثير من المستخدمين الآن'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('آيفون 15 برو ماكس'),
                _chip('بلايستيشن 5'),
                _chip('ماك بوك M2'),
                _chip('سامسونج S24 Ultra'),
                _chip('ساعة أبل ألترا'),
                _chip('دراجات جبلية'),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, ItemModel item) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withAlpha(120), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => ItemDetailsScreen(item: item))),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: ItemImageWidget(
                images: item.images,
                categoryId: item.categoryId,
                width: double.infinity,
                height: 100,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${item.estimatedValue.toStringAsFixed(0)} ريال', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 12)),
                  Text('يريد: ${item.wantedDescription}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniProductCard(BuildContext context, ItemModel item) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => ItemDetailsScreen(item: item))),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: ItemImageWidget(
                images: item.images,
                categoryId: item.categoryId,
                width: double.infinity,
                height: 90,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${item.estimatedValue.toStringAsFixed(0)} ريال', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}
