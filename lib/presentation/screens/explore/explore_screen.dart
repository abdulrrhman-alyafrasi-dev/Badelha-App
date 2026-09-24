import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/item_image_widget.dart';
import '../item_details/item_details_screen.dart';
import '../search/search_filter_screen.dart';
import '../store/store_profile_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketplaceProvider>();
    final auth = context.watch<AuthProvider>();
    final userCity = auth.currentUser?.city ?? 'صنعاء';

    final nearbyItems = market.items.where((i) => i.city == userCity).toList();
    final featuredItems = market.items.where((i) => i.isFeatured).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navExplore),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 1. Featured Deals (منتجات مميزة)
          if (featuredItems.isNotEmpty) ...[
            _buildSectionHeader('💎 منتجات وصفقات مميزة', 'عروض حصرية موثوقة'),
            const SizedBox(height: 10),
            SizedBox(
              height: 195,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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
              child: Text(
                'لا توجد عروض في $userCity حالياً، تصفح بقية المدن أدناه.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            SliverFillRemainingWrapper(
              child: SizedBox(
                height: 168,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: nearbyItems.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) => _buildMiniProductCard(context, nearbyItems[i]),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // 3. Top Trusted Traders (مستخدمون موثوقون)
          if (auth.allUsers.isNotEmpty) ...[
            _buildSectionHeader('⭐ مقايضون موثوقون ذوو سمعة عالية', 'أعلى درجات Trust Score وتقييمات مكتملة'),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: auth.allUsers.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final user = auth.allUsers[i];
                  return Container(
                    width: 145,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 12, color: AppColors.accent),
                            const SizedBox(width: 2),
                            Text(user.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 10.5)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${user.trustScore}% ثقة',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
          ],

          // 4. Commercial Verified Stores (المتاجر المعتمدة)
          if (market.stores.isNotEmpty) ...[
            _buildSectionHeader('🏪 متاجر بدلها الرسمية المعتمدة', 'مقايضة مع ضمان تجربة وفحص رسمي'),
            const SizedBox(height: 10),
            ...market.stores.map((s) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryLight,
                      child: Icon(Icons.store, color: AppColors.secondary),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.storeName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
            const SizedBox(height: 24),
          ],

          // 5. Most Wanted Categories & Recently Added
          _buildSectionHeader('📱 الأكثر طلباً للمقايضة', 'اضغط على السلعة للبحث المباشر عن عروضها'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, 'آيفون 15 برو ماكس'),
                _chip(context, 'بلايستيشن 5'),
                _chip(context, 'ماك بوك M2'),
                _chip(context, 'سامسونج S24 Ultra'),
                _chip(context, 'ساعة أبل ألترا'),
                _chip(context, 'دراجات جبلية'),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: ItemImageWidget(
                images: item.images,
                categoryId: item.categoryId,
                width: double.infinity,
                height: 95,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.estimatedValue.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 11.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'يريد: ${item.wantedDescription}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          mainAxisSize: MainAxisSize.min,
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
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.estimatedValue.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final market = context.read<MarketplaceProvider>();
          market.search(label);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SearchFilterScreen()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class SliverFillRemainingWrapper extends StatelessWidget {
  final Widget child;
  const SliverFillRemainingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}