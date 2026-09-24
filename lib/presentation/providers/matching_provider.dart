import 'package:flutter/material.dart';
import '../../data/models/match_result_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../domain/services/matching_engine.dart';

class MatchingProvider extends ChangeNotifier {
  final MarketplaceRepository _repo = MarketplaceRepository();

  List<MatchResultModel> _matches = [];
  bool _isLoading = false;

  List<MatchResultModel> get matches => _matches;
  bool get isLoading => _isLoading;

  /// Find and score smart barter matches for user's owned items
  Future<void> findMatchesForUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userItems = await _repo.getUserItems(userId);
      final marketItems = await _repo.getAvailableItems();

      final List<MatchResultModel> results = [];

      for (var myItem in userItems) {
        for (var target in marketItems) {
          if (target.userId == userId) continue; // Don't match with own items

          final match = MatchingEngine.evaluateMatch(
            myItem: myItem,
            targetItem: target,
          );

          // Only keep good quality matches (>= 50%)
          if (match.totalScore >= 50) {
            results.add(match);
          }
        }
      }

      // Sort by total match score descending
      results.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      _matches = results;
    } catch (e) {
      debugPrint('Error evaluating matches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
