class Contract {
  String id;
  String title;
  String download;
  String photo;
  bool reserve;
  String price;
  String createdAt;

  Contract.fromJson(Map<String, dynamic> json)
      : id = "${json["id"]}" ?? '',
        title = json["title"] ?? '',
        download = json["download"] ?? '',
        photo = json["photo"] ?? '',
        price = json["price"] ?? '',
        reserve = json['reserve'] ?? false,
        createdAt = json["created_at"] ?? '';
}
