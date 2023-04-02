class Book {
  String id;
  String title;
  String download;
  String author;
  String publisher;
  String translator;
  String photo;
  String price;
  bool mark;
  bool reserve;
  String createdAt;

  Book.fromJson(Map<String, dynamic> json)
      : id = "${json["id"]}" ?? '',
        title = json["title"] ?? '',
        author = json["author"] ?? '',
        publisher = json["publisher"] ?? '',
        price = json["price"] ?? '',
        translator = json["translator"] ?? '',
        photo = json["photo"] ?? '',
        download = json["download"] ?? '',
        mark = json['mark'] ?? false,
        reserve = json['reserve'] ?? false,
        createdAt = json["created_at"] ?? '';
}
