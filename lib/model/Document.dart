class Document {
  String id;
  String countVote;
  String title;
  String body;
  bool mark;
  String createdAt;

  Document.fromJson(Map<String, dynamic> json)
      : id = "${json["id"]}" ?? '',
        title = json["title"] ?? '',
        body = json["body"] ?? '',
        countVote = "${json["count_vote"]}",
        mark = json['mark'] ?? false,
        createdAt = json["created_at"] ?? '';
}
