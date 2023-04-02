import 'package:dabel_adl/helper/helpers.dart';

class Content {
  String id;
  String type;
  bool mark;
  List<dynamic> photos;
  String image;
  String title;
  String body;
  String created_at;

  String short_body;

  Content.fromJson(Map<String, dynamic> json)
      : id = "${json['id']}" ,
        type = json['type'] ?? '',
        mark = json['mark'] ?? false,
        image = json['image'] ?? '',
        photos = json['photos'] ?? [],
        title = json['title'] ?? '',
        short_body = json['short_body'] ?? '',
        body = json['body'] ?? '',
        created_at = json['created_at'] ?? '';

// published_at_date = Helper.toShamsi(json['published_at'])
}
