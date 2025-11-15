class StoreOrder {
  final String id;
  final String storeId;
  final String orderId;
  final String state;  // This corresponds to status in the API docs
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreOrder({
    required this.id,
    required this.storeId,
    required this.orderId,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    return StoreOrder(
      id: json['_id'],
      storeId: json['storeId'],
      orderId: json['orderId'],
      state: json['state'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'orderId': orderId,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}