import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';

class News {
  int id;
  String user_id;
  String category_id;
  String title;
  String link;
  String description;
  String image;
  bool isActive;
  int likes;
  int dislikes;
  String created_at;
  String updated_at;

  News.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? 0,
        user_id = json['user_id'] ?? '',
        category_id = json['category_id'] ?? '',
        link = json['link'] ?? '',
        image = "${Variables.LINK_NEWS_STORAGE}/${json['id']}.jpg",
        description = json['description'] ?? '',
        isActive = json['is_active'] ?? false,
        likes = json['likes'] ?? 0,
        dislikes = json['dislikes'] ?? 0,
        title = json['title'] ?? '',
        created_at = json['created_at'] ?? '',
        updated_at = json['updated_at'] ?? '';

// published_at_date = Helper.toShamsi(json['published_at'])
}
