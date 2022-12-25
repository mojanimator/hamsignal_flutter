import 'package:dabel_sport/helper/variables.dart';

class Latest {
  int id;
  String province_id;
  String county_id;
  String price;
  String discount_price;
  String name;
  String type;
  String salePercent;
  String created_at;
  String docLink;

  Latest.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        province_id = json['province_id'] ?? '',
        county_id = json['county_id'] ?? '',
        price = json['province_id'] ?? '',
        discount_price = json['county_id'] ?? '',
        name = json['name'],
        type = json['type'],
        salePercent = json['salePercent'] ?? '',
        docLink = getDocLink(json['type'], json['alldocs']),
        created_at = json['created_at']
  // published_at_date = Helper.toShamsi(json['published_at'])
  ;
}

String getDocLink(type, allDocs) {
  for (Map<String, dynamic> doc in allDocs) {
    if (doc['docable_type'] == type && doc['type_id'] != '5') {
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    }
  }
  return Variables.NOIMAGE_LINK;
}
