import 'item_model.dart';
import 'user_model.dart';

class CircularSwapModel {
  final String id;
  final UserModel userA;
  final ItemModel itemA;
  final UserModel userB;
  final ItemModel itemB;
  final UserModel userC;
  final ItemModel itemC;
  final int compatibilityScore;
  final String summary;

  CircularSwapModel({
    required this.id,
    required this.userA,
    required this.itemA,
    required this.userB,
    required this.itemB,
    required this.userC,
    required this.itemC,
    required this.compatibilityScore,
    required this.summary,
  });
}
