import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';

class Signal {
  String id;
  String user_id;
  String category_id;
  String name;
  String vorood;
  String hadeZarar;
  String target1;
  String target2;
  String timeTahlil;
  String vahedeTimeTahlil;
  String position;
  String description;
  String link;
  bool isActive;
  bool isBookmark;
  int likes;
  String created_at;

  Signal.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        user_id = json['user_id'] ?? '',
        category_id = json['category_id'] ?? '',
        vorood = json['vorood'] ?? '',
        target1 = json['target1'] ?? '',
        target2 = json['target2'] ?? '',
        position = json['position'] ?? '',
        hadeZarar = json['hade_zarar'] ?? '',
        timeTahlil = json['time_tahlil'] ?? '',
        vahedeTimeTahlil = json['vahede_time_tahlil'] ?? '',
        link = json['link'] ?? '',
        description = json['description'] ?? '',
        isActive = json['is_active'] ?? false,
        isBookmark = json['bookmark_exists'] ?? false,
        likes = json['likes'] ?? 0,
        name = json['name'] ?? '',
        created_at = json['created_at'] ?? '';


// published_at_date = Helper.toShamsi(json['published_at'])
}
