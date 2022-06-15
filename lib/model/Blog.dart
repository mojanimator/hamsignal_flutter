import 'package:dabel_sport/helper/helpers.dart';

class Blog {
  int id;
  String category_id;

  String title;
  String summary;
  String content;
  String tags;
  String published_at;
  String updated_at;
  List<dynamic> docLinks;
  bool active;

  Blog.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        category_id = json['category_id'] ?? '',
        title = json['title'] ?? '',
        summary = json['summary'] ?? '',
        content = json['content'] ?? '',
        tags = json['tags'] ?? '',
        published_at = Helper.toShamsi(json['published_at']),
        updated_at = json['updated_at'] ?? '',
        active =  json['active'] == 1 || json['active'] == '1',
        docLinks = (json['docs'] ?? []) as List<dynamic>
  // published_at_date = Helper.toShamsi(json['published_at'])
  ;
}
