import 'dart:convert' as converter;

import 'package:dabel_adl/helper/variables.dart';

class Club {
  int id;
  String user_id;
  String province_id;
  String county_id;
  String? sport_id;
  int? sport_rule_id;
  String name;
  String address;
  String? location;
  bool active;
  bool  in_review;
  bool? hidden;
  String? phone;
  String? description;
  List<dynamic> times;
  List<dynamic> docLinks;
  int expires_at;

  Club.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user_id = json['user_id'],
        province_id = json['province_id'] ?? '',
        county_id = json['county_id'] ?? '',
        sport_id = json['sport_id'] ?? '',
        sport_rule_id = json['sport-rule_id'],
        name = json['name'],
        address = json['address'] ?? '',
        times = json['times'] != null
            ? converter.json.decode(json['times']) as List<dynamic>
            : [],
        location = json['location'],
        active = json['active'] as bool,
        in_review = json['in_review'] as bool,
        hidden = json['hidden'] as bool,
        phone = json['phone'],
        description = json['description'],
        docLinks = (json['docs'] ?? []) as List<dynamic>,
        expires_at = json['expires_at'] ?? -1;

  static get(json) {
    return (json ?? []) as List<dynamic>;
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
