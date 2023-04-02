class Finder {
  String id;
  String title;
  int source;
  String content;
  String extra;

  Finder.fromJson(Map<String, dynamic> json)
      : id = "${json["id"]}" ?? '',
        title = json["title"] ?? '',
        source = json["source"] ?? 0,
        content = json["content"] ?? '',
        extra = json["extra"] ?? '';
}
