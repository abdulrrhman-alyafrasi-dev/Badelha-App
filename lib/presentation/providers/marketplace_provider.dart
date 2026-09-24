import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/store_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../domain/services/semantic_search_engine.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceRepository _repo = MarketplaceRepository();

  List<ItemModel> _items = [];
  List<ItemModel> _myItems = [];
  List<CategoryModel> _categories = [];
  List<StoreModel> _stores = [];
  final Set<String> _favoriteItemIds = {};

  bool _isLoading = false;
  String _selectedCategory = '';
  String _selectedCity = 'الكل';
  String _selectedCondition = 'الكل';
  String _sortBy = 'newest';
  String _searchQuery = '';
  double? _minPrice;
  double? _maxPrice;

  // Wanted search mode
  bool _isWantedSearchActive = false;
  List<ItemModel> _wantedSearchResults = [];

  List<ItemModel> get items => _items;
  List<ItemModel> get myItems => _myItems;
  List<CategoryModel> get categories => _categories;
  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedCity => _selectedCity;
  String get selectedCondition => _selectedCondition;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  bool get isWantedSearchActive => _isWantedSearchActive;
  List<ItemModel> get wantedSearchResults => _wantedSearchResults;

  /// Initialize and load marketplace data
  Future<void> init(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repo.getCategories();
      _stores = await _repo.getStores();
      await refreshItems();
      await loadUserItems(currentUserId);
    } catch (e) {
      debugPrint('Error loading marketplace: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload items according to current filters
  Future<void> refreshItems() async {
    // Check and expire overdue listings automatically
    await _repo.checkAndExpireListings();

    _items = await _repo.getAvailableItems(
      categoryId: _selectedCategory.isEmpty ? null : _selectedCategory,
      city: _selectedCity,
      condition: _selectedCondition,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      sortBy: _sortBy,
    );
    notifyListeners();
  }

  /// Load current user items
  Future<void> loadUserItems(String userId) async {
    _myItems = await _repo.getUserItems(userId);
    notifyListeners();
  }

  /// Set category filter
  void selectCategory(String catId) {
    if (_selectedCategory == catId) {
      _selectedCategory = ''; // Toggle off
    } else {
      _selectedCategory = catId;
    }
    refreshItems();
  }

  /// Set city filter
  void selectCity(String city) {
    _selectedCity = city;
    refreshItems();
  }

  /// Set condition filter
  void selectCondition(String condition) {
    _selectedCondition = condition;
    refreshItems();
  }

  /// Set sort option
  void setSortBy(String sort) {
    _sortBy = sort;
    refreshItems();
  }

  /// Search with semantic query expansion
  Future<void> search(String query) async {
    _searchQuery = query;
    _isWantedSearchActive = false;
    await refreshItems();
  }

  /// "من يريد منتجي؟" (Wanted search)
  Future<void> searchWhoWantsMyItem(ItemModel myItem) async {
    _isWantedSearchActive = true;
    _isLoading = true;
    notifyListeners();

    final allItems = await _repo.getAvailableItems();
    _wantedSearchResults = SemanticSearchEngine.findWhoWantsMyItem(
      myItem: myItem,
      allMarketItems: allItems,
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearWantedSearch() {
    _isWantedSearchActive = false;
    _wantedSearchResults = [];
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _selectedCategory = '';
    _selectedCity = 'الكل';
    _selectedCondition = 'الكل';
    _sortBy = 'newest';
    _searchQuery = '';
    _minPrice = null;
    _maxPrice = null;
    _isWantedSearchActive = false;
    refreshItems();
  }

  /// 🚀 Ultra-Fast Optimistic Add new Item
  Future<void> addNewItem(ItemModel item, List<String> images) async {
    // 1. Instant Optimistic UI Update (< 1ms)
    final newItemWithImages = item.copyWith(images: images);
    _items.insert(0, newItemWithImages);
    _myItems.insert(0, newItemWithImages);
    notifyListeners();

    // 2. Persist to SQLite & Remote PostgreSQL in background
    try {
      await _repo.addItem(item, images);
    } catch (e) {
      debugPrint('Error in background addItem: $e');
    }

    // 3. Silent reconcile
    await refreshItems();
    await loadUserItems(item.userId);
  }

  /// 🚀 Ultra-Fast Optimistic Update Item (Strictly owned by user)
  Future<bool> updateUserItem(
    ItemModel item,
    List<String> images, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    if (!isAdmin && item.userId != currentUserId) {
      return false;
    }

    // 1. Instant Optimistic UI Update
    final updatedItem = item.copyWith(images: images.isNotEmpty ? images : item.images);
    final itemIdx = _items.indexWhere((i) => i.id == item.id);
    if (itemIdx != -1) {
      _items[itemIdx] = updatedItem;
    }
    final myIdx = _myItems.indexWhere((i) => i.id == item.id);
    if (myIdx != -1) {
      _myItems[myIdx] = updatedItem;
    }
    notifyListeners();

    // 2. Background sync
    final success = await _repo.updateItem(
      item,
      images,
      currentUserId: currentUserId,
      isAdmin: isAdmin,
    );

    // 3. Silent reconcile
    await refreshItems();
    await loadUserItems(currentUserId);
    return success;
  }

  /// 🚀 Ultra-Fast Optimistic Delete Item (Strictly owned by user)
  Future<bool> deleteUserItem(
    String itemId, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    // 1. Instant Optimistic UI removal
    _items.removeWhere((i) => i.id == itemId);
    _myItems.removeWhere((i) => i.id == itemId);
    notifyListeners();

    // 2. Background sync
    final success = await _repo.deleteItem(
      itemId,
      currentUserId: currentUserId,
      isAdmin: isAdmin,
    );

    // 3. Silent reconcile
    await refreshItems();
    await loadUserItems(currentUserId);
    return success;
  }

  /// Toggle Favorite
  Future<bool> toggleFavorite(String userId, String itemId) async {
    final isFav = await _repo.toggleFavorite(userId, itemId);
    if (isFav) {
      _favoriteItemIds.add(itemId);
    } else {
      _favoriteItemIds.remove(itemId);
    }
    notifyListeners();
    return isFav;
  }

  bool isFavorite(String itemId) => _favoriteItemIds.contains(itemId);

  /// 🔄 Refresh / Renew an item listing (bumps to top, resets expiration timer)
  Future<bool> refreshListing(String itemId, String userId) async {
    final success = await _repo.refreshItemListing(itemId);
    if (success) {
      await refreshItems();
      await loadUserItems(userId);
    }
    return success;
  }

  /// 🛡️ Admin: Delete / remove listing
  Future<bool> adminDeleteItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    _myItems.removeWhere((i) => i.id == itemId);
    notifyListeners();

    final success = await _repo.adminDeleteItem(itemId);
    if (success) {
      await refreshItems();
    }
    return success;
  }
}
