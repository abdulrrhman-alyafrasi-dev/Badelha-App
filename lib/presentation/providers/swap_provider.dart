import 'package:flutter/material.dart';
import '../../data/models/circular_swap_model.dart';
import '../../data/models/swap_offer_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../data/repositories/swap_repository.dart';
import '../../domain/services/circular_swap_engine.dart';

class SwapProvider extends ChangeNotifier {
  final SwapRepository _swapRepo = SwapRepository();
  final MarketplaceRepository _marketRepo = MarketplaceRepository();

  List<SwapOfferModel> _receivedOffers = [];
  List<SwapOfferModel> _sentOffers = [];
  List<CircularSwapModel> _circularSwaps = [];
  bool _isLoading = false;

  List<SwapOfferModel> get receivedOffers => _receivedOffers;
  List<SwapOfferModel> get sentOffers => _sentOffers;
  List<CircularSwapModel> get circularSwaps => _circularSwaps;
  bool get isLoading => _isLoading;

  /// Load user's received and sent offers
  Future<void> loadOffers(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _receivedOffers = await _swapRepo.getReceivedOffers(userId);
      _sentOffers = await _swapRepo.getSentOffers(userId);
    } catch (e) {
      debugPrint('Error loading swap offers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a swap proposal
  Future<void> sendSwapOffer(SwapOfferModel offer) async {
    await _swapRepo.createSwapOffer(offer);
    await loadOffers(offer.senderId);
  }

  /// Accept an offer (Optimistic & fast)
  Future<void> acceptOffer(String offerId, String userId) async {
    _updateLocalOfferStatus(offerId, 'Accepted');
    notifyListeners();
    await _swapRepo.updateOfferStatus(offerId, 'Accepted');
    await loadOffers(userId);
  }

  /// Reject an offer (Optimistic & fast)
  Future<void> rejectOffer(String offerId, String userId) async {
    _updateLocalOfferStatus(offerId, 'Rejected');
    notifyListeners();
    await _swapRepo.updateOfferStatus(offerId, 'Rejected');
    await loadOffers(userId);
  }

  /// Complete a swap (after mutual handover)
  Future<void> completeSwap(String offerId, String userId) async {
    _updateLocalOfferStatus(offerId, 'Completed');
    notifyListeners();
    await _swapRepo.updateOfferStatus(offerId, 'Completed');
    await loadOffers(userId);
  }

  /// Transition swap offer through lifecycle
  Future<void> updateOfferStatus(String offerId, String status, String userId) async {
    _updateLocalOfferStatus(offerId, status);
    notifyListeners();
    await _swapRepo.updateOfferStatus(offerId, status);
    await loadOffers(userId);
  }

  void _updateLocalOfferStatus(String offerId, String status) {
    for (int i = 0; i < _receivedOffers.length; i++) {
      if (_receivedOffers[i].id == offerId) {
        _receivedOffers[i] = _receivedOffers[i].copyWith(status: status);
      }
    }
    for (int i = 0; i < _sentOffers.length; i++) {
      if (_sentOffers[i].id == offerId) {
        _sentOffers[i] = _sentOffers[i].copyWith(status: status);
      }
    }
  }

  /// Discover circular 3-way swaps
  Future<void> loadCircularSwaps() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allItems = await _marketRepo.getAvailableItems();
      final allUsers = await _marketRepo.getAllUsers();
      _circularSwaps = CircularSwapEngine.findTriangularSwaps(
        allItems: allItems,
        allUsers: allUsers,
      );
    } catch (e) {
      debugPrint('Error discovering circular swaps: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
