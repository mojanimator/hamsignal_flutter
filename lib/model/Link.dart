class Link {
  String id;
  String name;
  String url;
  bool isActive;
  bool isLocked;
  int? createdAt;
  int? updatedAt;

  Link.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? '',
        name = json["name"] ?? '',
        url = json["url"] ?? '',
        isActive = json["is_active"] == 1,
        isLocked = json["is_locked"] == 1,
        createdAt = json["created_at"],
        updatedAt = json["updated_at"];
}
