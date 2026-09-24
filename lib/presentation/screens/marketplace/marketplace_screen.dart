import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/admin_banner_carousel.dart';
import '../../widgets/item_card.dart';
import '../search/search_filter_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sync_alt, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('سوق المقايضة الحي'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'فلاتر وبحث متقدم',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchFilterScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => market.refreshItems(),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Top Official Admin Banner Moving Carousel (Auto-scroll & Swipe)
            const AdminBannerCarousel(),

            // Search Bar Shortcut
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SearchFilterScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        market.searchQuery.isNotEmpty ? market.searchQuery : 'ابحث في آلاف الصفقات، الأجهزة، المدن...',
                        style: TextStyle(
                          color: market.searchQuery.isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Horizontal Categories Selector
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: market.categories.length + 1,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    final isAll = market.selectedCategory.isEmpty;
                    return ChoiceChip(
                      label: const Text('الكل'),
                      selected: isAll,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isAll ? Colors.white : AppColors.textPrimary,
                        fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) => market.selectCategory(''),
                    );
                  }

                  final cat = market.categories[i - 1];
                  final isSelected = market.selectedCategory == cat.id;

                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => market.selectCategory(cat.id),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Main Product Feed
            Expanded(
              child: market.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : market.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 56, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'لا توجد سلع متطابقة مع الفلترة المختارة',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => market.resetFilters(),
                                child: const Text('إظهار جميع سلع السوق'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.74,
                          ),
                          itemCount: market.items.length,
                          itemBuilder: (context, index) {
                            final item = market.items[index];
                            return ItemCard(
                              item: item,
                              isFavorite: market.isFavorite(item.id),
                              onFavoriteToggle: () {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                if (auth.currentUser != null) {
                                  market.toggleFavorite(auth.currentUser!.id, item.id);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
