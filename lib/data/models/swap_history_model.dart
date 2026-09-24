class SwapHistoryModel {
  final String id;
  final String swapOfferId;
  final String senderId;
  final String receiverId;
  final String offeredItemId;
  final String requestedItemId;
  final String completedAt;
  final String finalStatus; // 'Completed', 'Cancelled'
  final String notes;

  // Joined display attributes (optional)
  final String senderName;
  final String receiverName;
  final String offeredItemTitle;
  final String requestedItemTitle;

  SwapHistoryModel({
    required this.id,
    required this.swapOfferId,
    required this.senderId,
    required this.receiverId,
    required this.offeredItemId,
    required this.requestedItemId,
    required this.completedAt,
    this.finalStatus = 'Completed',
    this.notes = '',
    this.senderName = '',
    this.receiverName = '',
    this.offeredItemTitle = '',
    this.requestedItemTitle = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'swap_offer_id': swapOfferId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'offered_item_id': offeredItemId,
      'requested_item_id': requestedItemId,
      'completed_at': completedAt,
      'final_status': finalStatus,
      'notes': notes,
    };
  }

  factory SwapHistoryModel.fromMap(Map<String, dynamic> map) {
    return SwapHistoryModel(
      id: map['id'] as String,
      swapOfferId: map['swap_offer_id'] as String? ?? '',
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      offeredItemId: map['offered_item_id'] as String,
      requestedItemId: map['requested_item_id'] as String,
      completedAt: map['completed_at'] as String? ?? DateTime.now().toIso8601String(),
      finalStatus: map['final_status'] as String? ?? 'Completed',
      notes: map['notes'] as String? ?? '',
      senderName: map['sender_name'] as String? ?? '',
      receiverName: map['receiver_name'] as String? ?? '',
      offeredItemTitle: map['offered_item_title'] as String? ?? '',
      requestedItemTitle: map['requested_item_title'] as String? ?? '',
    );
  }
}
