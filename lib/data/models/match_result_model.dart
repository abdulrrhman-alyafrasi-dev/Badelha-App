import 'item_model.dart';

class MatchResultModel {
  final ItemModel userItem;
  final ItemModel targetItem;
  final int totalScore; // 0 to 100
  final int categoryScore; // 0 to 30
  final int valueScore; // 0 to 25
  final int qualityScore; // 0 to 15
  final int locationScore; // 0 to 15
  final int preferenceScore; // 0 to 15
  final List<String> reasons;
  final double suggestedCashDifference;
  final String cashPayer; // 'none', 'user_pays', 'target_pays'

  MatchResultModel({
    required this.userItem,
    required this.targetItem,
    required this.totalScore,
    required this.categoryScore,
    required this.valueScore,
    required this.qualityScore,
    required this.locationScore,
    required this.preferenceScore,
    required this.reasons,
    this.suggestedCashDifference = 0.0,
    this.cashPayer = 'none',
  });
}
