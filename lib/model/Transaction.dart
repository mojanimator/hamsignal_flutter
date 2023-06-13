class Transaction {
  String id;
  String userId;
  String title;
  String type;
  String amount;
  String coupon;
  String createdAt;
  String updatedAt;

  Transaction.fromJson(Map<String, dynamic> json)
      : id = "${json['id'] ?? 0}",
        userId = "${json['user_id'] ?? 0}",
        amount = "${json['amount'] ?? 0}",
        title = "${json['title'] ?? ''}",
        coupon = "${json['coupon'] ?? ''}",
        type = "${json['type'] ?? ''}",
        createdAt = "${json['created_at'] ?? ''}",
        updatedAt = "${json['updated_at'] ?? ''}";
}
