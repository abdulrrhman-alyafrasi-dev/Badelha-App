import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/item_model.dart';
import '../../providers/marketplace_provider.dart';
import '../item_details/item_details_screen.dart';
import '../../widgets/item_image_widget.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  ItemModel? _selectedMyItemForWantedSearch;

  final List<String> _quickSynonymSuggestions = [
    'جوال',
    'آيفون',
    'سامسونج S23',
    'لابتوب ديل',
    'ماك بوك',
    'بلايستيشن 5',
    'ساعة أبل',
    'دراجة تريك',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث المتقدم والمطابقات'),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              market.resetFilters();
            },
            child: const Text('إعادة ضبط', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Container
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: (query) => market.search(query),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن هاتف، لابتوب، سوني، ماركة، مدينة...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              market.search('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Semantic Quick Tags
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickSynonymSuggestions.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final term = _quickSynonymSuggestions[i];
                      return ActionChip(
                        label: Text(term, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.background,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () {
                          _searchController.text = term;
                          market.search(term);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // "من يريد منتجي؟" (Wanted Search Engine Tab)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                const Icon(Icons.person_search_outlined, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.whoWantsMyItem,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      Text(
                        'ابحث عمن يحتاج السلعة التي تمتلكها حالياً',
                        style: TextStyle(fontSize: 10, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _showWhoWantsMyItemDialog(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('حدد منتجك', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Filters and Sorting Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                // City Filter Dropdown (All 22 Yemeni Governorates)
                DropdownButton<String>(
                  value: (market.selectedCity == 'الكل' || AppConstants.yemenGovernorates.contains(market.selectedCity))
                      ? market.selectedCity
                      : 'الكل',
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  items: [
                    const DropdownMenuItem(value: 'الكل', child: Text('جميع المحافظات', style: TextStyle(fontSize: 12))),
                    ...AppConstants.yemenGovernorates.map((gov) {
                      return DropdownMenuItem(
                        value: gov,
                        child: Text(gov, style: const TextStyle(fontSize: 12)),
                      );
                    }),
                  ],
                  onChanged: (v) {
                    if (v != null) market.selectCity(v);
                  },
                ),
                const Spacer(),
                // Sorting Dropdown
                DropdownButton<String>(
                  value: market.sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, size: 18, color: AppColors.primary),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('الأحدث إضافة', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'highest_rated', child: Text('الأعلى ثقة وتقييماً', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'value_asc', child: Text('الأقل قيمة', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'value_desc', child: Text('الأعلى قيمة', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) {
                    if (v != null) market.setSortBy(v);
                  },
                ),
              ],
            ),
          ),

          // Results Feed
          Expanded(
            child: market.isLoading
                ? const Center(child: CircularProgressIndicator())
                : market.isWantedSearchActive
                    ? _buildWantedSearchResults(context, market)
                    : market.items.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد نتائج تطابق معايير البحث الحالية.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: market.items.length,
                            itemBuilder: (context, index) {
                              final item = market.items[index];
                              return ListTile(
                                leading: ItemImageWidget(
                                  images: item.images,
                                  width: 50,
                                  height: 50,
                                  borderRadius: 8,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('يريد: ${item.wantedDescription}', style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                                    Text('${item.city} • ${item.estimatedValue.toStringAsFixed(0)} ريال', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: item)),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildWantedSearchResults(BuildContext context, MarketplaceProvider market) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.amber.shade50,
          child: Row(
            children: [
              Text(
                'نتائج من يريد: ${_selectedMyItemForWantedSearch?.title ?? 'منتجك'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => market.clearWantedSearch(),
              ),
            ],
          ),
        ),
        Expanded(
          child: market.wantedSearchResults.isEmpty
              ? const Center(
                  child: Text('لم نجد حالياً مستخدمين يطلبون هذا المنتج تحديداً.'),
                )
              : ListView.builder(
                  itemCount: market.wantedSearchResults.length,
                  itemBuilder: (context, index) {
                    final target = market.wantedSearchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        title: Text(target.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'يمتلك: ${target.title}\nويبحث عن: ${target.wantedDescription}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: target)),
                            );
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          child: const Text('عرض', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showWhoWantsMyItemDialog(BuildContext context) {
    final market = Provider.of<MarketplaceProvider>(context, listen: false);

    if (market.myItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف منتجاً أولاً لتتمكن من معرفة من يبحث عنه في السوق!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر منتجك المعروض:'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: market.myItems.length,
            itemBuilder: (ctx, i) {
              final item = market.myItems[i];
              return ListTile(
                title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('${item.estimatedValue.toStringAsFixed(0)} ريال'),
                onTap: () {
                  setState(() => _selectedMyItemForWantedSearch = item);
                  market.searchWhoWantsMyItem(item);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
