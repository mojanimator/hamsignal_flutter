import 'package:dabel_sport/helper/variables.dart';

class Player {
  int id;
  String? user_id;
  String province_id;
  String county_id;
  String? sport_id;
  int? sport_rule_id;
  String name;
  String family;
  String height;
  String weight;
  String? age;
  bool? is_man;
  bool active;
  bool? hidden;
  String? phone;
  String? description;
  int expires_at;
  int? born_at;
  List<dynamic>? docLinks;

  Player.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user_id = json['user_id'] ?? '',
        province_id = json['province_id'] ?? '',
        county_id = json['county_id'] ?? '',
        sport_id = json['sport_id'] ?? '',
        sport_rule_id = json['sport-rule_id'],
        name = json['name'] ?? '',
        family = json['family'] ?? '',
        height = json['height'] ?? '',
        weight = json['weight'] ?? '',
        is_man = json['is_man'] as bool,
        active = json['active'] as bool,
        hidden = json['hidden'] as bool,
        phone = json['phone'],
        description = json['description'],
        docLinks = (json['docs'] ?? []) as List<dynamic>,
        born_at = json['born_at'],
        age = getAge(json['born_at']),
        expires_at = json['expires_at'] ?? -1;

  Player.fromNull()
      : id = -1,
        user_id = '',
        province_id = '',
        county_id = '',
        sport_id = '',
        sport_rule_id = -1,
        name = '',
        family = '',
        height = '',
        weight = '',
        is_man = null,
        active = false,
        hidden = false,
        phone = '',
        description = '',
        docLinks = [],
        age = '0',
        born_at = -1,
        expires_at = -1;

  static getAge(int? timestamp) {
    if (timestamp==null) return '0';
    DateTime currentDate = DateTime.now();
    DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }

    return age >= 0 ? "$age" : "0";
  }
}

String getDocLink(type, allDocs) {
  for (Map<String, dynamic> doc in allDocs) {
    if (doc['docable_type'] == type) {
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    }
  }
  return Variables.NOIMAGE_LINK;
}
