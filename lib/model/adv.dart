import 'package:flutter/material.dart';

class Adv {
  String id;
  String title;
  Map type;
  Map keys;
  List<AdvItem> advs;
  Widget? nativeWidget;

  Adv.fromJson(Map<String, dynamic> json)
      : id = "${json['id'] ?? ''}",
        title = "${json['title'] ?? ''}",
        keys = json['keys'] ?? {},
        advs = (json['data'] ?? [])
            .map<AdvItem>((e) => AdvItem.fromJson(e))
            .toList(),
        type = json['type'] ?? {};
}

class AdvItem {
  String id;
  String title;
  int clicks;
  bool active;
  String bannerLink;
  String clickLink;

  AdvItem.fromJson(Map<String, dynamic> json)
      : id = "${json['id'] ?? ''}",
        title = "${json['title'] ?? ''}",
        clicks = json['clicks'] ?? 0,
        active = json['active'] ?? json['is_active'] == true,
        bannerLink = "${json['banner_link'] ?? ''}",
        clickLink = "${json['click_link'] ?? ''}";
}
