class SwapOfferModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String offeredItemId;
  final String requestedItemId;
  final double cashDifference;
  final String cashPayer; // 'sender' or 'receiver'
  final String message;
  final String status; // Pending, Accepted, Rejected, Completed, Cancelled
  final String createdAt;

  // Joined display attributes
  final String offeredItemTitle;
  final String requestedItemTitle;
  final double offeredItemValue;
  final double requestedItemValue;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final String offeredItemImage;
  final String requestedItemImage;

  SwapOfferModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.offeredItemId,
    required this.requestedItemId,
    this.cashDifference = 0.0,
    this.cashPayer = 'sender',
    this.message = '',
    this.status = 'Pending',
    required this.createdAt,
    this.offeredItemTitle = '',
    this.requestedItemTitle = '',
    this.offeredItemValue = 0.0,
    this.requestedItemValue = 0.0,
    this.senderName = '',
    this.receiverName = '',
    this.senderPhone = '',
    this.receiverPhone = '',
    this.offeredItemImage = '',
    this.requestedItemImage = '',
  });

  bool get isPending => status == 'Pending';
  bool get isAccepted => status == 'Accepted';
  bool get isSafetyConfirmation => status == 'Safety Confirmation';
  bool get isMeetingPending => status == 'Meeting Pending';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';
  bool get isRejected => status == 'Rejected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'offered_item_id': offeredItemId,
      'requested_item_id': requestedItemId,
      'cash_difference': cashDifference,
      'cash_payer': cashPayer,
      'message': message,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory SwapOfferModel.fromMap(Map<String, dynamic> map) {
    return SwapOfferModel(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      offeredItemId: map['offered_item_id'] as String,
      requestedItemId: map['requested_item_id'] as String,
      cashDifference: (map['cash_difference'] as num?)?.toDouble() ?? 0.0,
      cashPayer: map['cash_payer'] as String? ?? 'sender',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'Pending',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      offeredItemTitle: map['offered_item_title'] as String? ?? '',
      requestedItemTitle: map['requested_item_title'] as String? ?? '',
      offeredItemValue: (map['offered_item_value'] as num?)?.toDouble() ?? 0.0,
      requestedItemValue: (map['requested_item_value'] as num?)?.toDouble() ?? 0.0,
      senderName: map['sender_name'] as String? ?? '',
      receiverName: map['receiver_name'] as String? ?? '',
      senderPhone: map['sender_phone'] as String? ?? '',
      receiverPhone: map['receiver_phone'] as String? ?? '',
      offeredItemImage: map['offered_item_image'] as String? ?? '',
      requestedItemImage: map['requested_item_image'] as String? ?? '',
    );
  }

  SwapOfferModel copyWith({
    String? status,
    String? message,
  }) {
    return SwapOfferModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      offeredItemId: offeredItemId,
      requestedItemId: requestedItemId,
      cashDifference: cashDifference,
      cashPayer: cashPayer,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt,
      offeredItemTitle: offeredItemTitle,
      requestedItemTitle: requestedItemTitle,
      offeredItemValue: offeredItemValue,
      requestedItemValue: requestedItemValue,
      senderName: senderName,
      receiverName: receiverName,
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      offeredItemImage: offeredItemImage,
      requestedItemImage: requestedItemImage,
    );
  }
}
