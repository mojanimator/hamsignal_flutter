import 'package:dabel_sport/helper/variables.dart';

class Product {
  int id;
  int shop_id;
  String group_id;
  String price;
  String discount_price;
  String name;
  String description;
  String sold;
  String count;
  String tags;
  String salePercent;
  String props;
  bool active;
  bool in_review;
  List<dynamic> docLinks;
  String updated_at;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        shop_id = json['shop_id'] ?? '',
        group_id = json['group_id'] ?? '',
        price = json['price'] ?? '',
        discount_price = json['discount_price'] ?? '',
        salePercent = json['salePercent'] ?? '0%',
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        sold = json['sold'] ?? '',
        count = json['count'] ?? '',
        tags = json['tags'] ?? '',
        in_review = json['in_review'] as bool,
        active = json['active'] as bool,
        props = json['props'] ?? '',
        docLinks = (json['docs'] ?? []) as List<dynamic>,
        updated_at = json['created_at']
  // published_at_date = Helper.toShamsi(json['published_at'])
  ;
}

String getDocLink(type, allDocs) {
  for (Map<String, dynamic> doc in allDocs) {
    if (doc['docable_type'] == type) {
      return "${Variables.LINK_STORAGE}/${doc['type_id']}/${doc['id']}.jpg";
    }
  }
  return Variables.NOIMAGE_LINK;
}
