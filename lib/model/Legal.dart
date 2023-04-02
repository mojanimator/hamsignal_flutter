class Legal {
  String id;
  String title;
  String download;
  bool mark;
  String createdAt;

  Legal.fromJson(Map<String, dynamic> json)
      : id = "${json["id"]}" ?? '',
        title = json["title"] ?? '',
        download = json["download"] ?? '',
        mark = json['mark'] ?? false,
        createdAt = json["created_at"] ?? '';
}
