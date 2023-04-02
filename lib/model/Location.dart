class Location {
  String id;
  bool mark;
  String title;
  String address;
  String long;
  String lat;
  String createdAt;

  Location.fromJson(Map<String, dynamic> json)
      : id = "${json['id']}",
        title = json['title'] ?? '',
        address = json['address'] ?? '',
        long = json['long'] ?? '',
        lat = json['lat'] ?? '',
        mark = json['mark'] ?? false,
        createdAt = json['createdAt'] ?? '';
}
