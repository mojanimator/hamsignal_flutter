class Table {
  final int id;
  final String tournament_id;
  final String title;

  final String tags;
  final String content;

  final bool active;

  Table.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tournament_id = "${json['tournament_id']}",
        title = json['title'] ?? '',
        tags = json['tags'] ?? '',
        content = json['content'] ?? '',
        active = json['active'];
}
