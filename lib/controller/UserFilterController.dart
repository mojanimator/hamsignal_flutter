import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dabel_adl/controller/APIController.dart';
import 'package:http/http.dart' as http;

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/User.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../model/Category.dart';
import '../page/shop.dart';
import 'UserController.dart';

class UserFilterController extends APIController {
  late final box = GetStorage();

  late final Helper helper;
  late final SettingController settingController;

  late final ApiProvider apiProvider;

  TextEditingController textNameCtrl = TextEditingController();
  TextEditingController textEmailCtrl = TextEditingController();
  TextEditingController textPaswOldCtrl = TextEditingController();
  TextEditingController textPaswCtrl = TextEditingController();
  TextEditingController textPaswConfCtrl = TextEditingController();
  TextEditingController textTelCtrl = TextEditingController();
  TextEditingController textMelliCodeCtrl = TextEditingController();
  TextEditingController textCityCtrl = TextEditingController();
  TextEditingController textLawyerCodeCtrl = TextEditingController();
  TextEditingController textLawyerBioCtrl = TextEditingController();
  TextEditingController textLawyerAddressCtrl = TextEditingController();
  UserController parent;

  User? user;

  UserFilterController(this.parent) {
    // _ACCESS_TOKEN.val = '';
    apiProvider = Get.find<ApiProvider>();
    helper = Get.find<Helper>();
    settingController = Get.find<SettingController>();
    user = this.parent.user;
  }

  late Map<String, dynamic> filters = {
    'province': '',
    'county': '',
    'day': '',
    'month': '',
    'year': '',
    'sex': false,
    'lawyer/expert': false,
    'categories': categories(),
  };

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null)
      filters[type] = null;
    else
      switch (type) {
        case 'province':
          filters[type] = idx;
          filters['county'] = null;
          break;
        case 'county':
          filters[type] = idx;
          break;
        case 'sex':
          filters[type] = idx == 1;
          break;
        case 'lawyer/expert':
          filters[type] = idx == 1;
          break;
        default:
          filters[type] = "$idx";
          break;
      }
    update();
  }

  dynamic getFilterSelected(type, {idx}) {
    if (type == 'sex') {
      if (filters[type] == true)
        return [false, true];
      else
        return [true, false];
    } else if (type == 'lawyer/expert') {
      if (filters[type] == true)
        return [false, true];
      else
        return [true, false];
    } else
      return filters[type];
  }

// final username = ''.val('username');
// final age = 0.val('age');
// final price = 1000.val('price', getBox: _otherBox);

// or

  @override
  void onInit() async {
    // ACCESS_TOKEN = '';
    change(user, status: RxStatus.success());
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

// Future<bool> sendActivationCode({required String phone}) async {
//   return await settingController.sendActivationCode(phone: phone);
// }

  List categories() {
    return settingController.categories
        .where((element) => element['related'] == CategoryRelate.Lawyer)
        .map<Map>((e) => {
              ...e,
              ...{
                'selected': user != null &&
                        user!.categories.split(', ').contains(e['title'])
                    ? true
                    : false
              }
            })
        .toList();
  }

  String category(String? category_id) {
    var t = categories()
        .firstWhereOrNull((element) => element['id'] == category_id);
    return t == null ? '' : t['title'];
  }

  Future initFilters() async {
    user = parent.user;
    filters['sex'] = user?.lawyerSex != null ? user?.lawyerSex : false;

    filters['lawyer/expert'] =
        user?.isExpert != null && user?.isExpert == true ? true : false;
    DateTime? beforeData = DateTime.tryParse(user?.lawyerBirthday ?? '');
    Jalali? j = beforeData != null ? Jalali.fromDateTime(beforeData) : null;
    filters['day'] =
        settingController.dates['days'].contains(j?.day) ? "${j?.day}" : '';
    filters['month'] = settingController.dates['months'].contains(j?.month)
        ? "${j?.month}"
        : '';
    filters['year'] =
        settingController.dates['years'].contains(j?.year) ? "${j?.year}" : '';
    filters['county'] = user?.cityId ?? '';
    var city = settingController.counties
        .firstWhereOrNull((e) => "${e['id']}" == "${filters['county']}");
    if (city != null) {
      filters['province'] = int.parse("${city['province_id']}");
      filters['county'] = int.parse("${city['id']}");
    }
    await getImageFile(url: "${user?.avatar}", type: 'avatar');
    await getImageFile(url: "${user?.lawyerDocument}", type: 'document');

    change(user, status: RxStatus.success());
  }

  Future<File?> getImageFile(
      {required String url, required String type}) async {
    var rng = Random();
    var link = Uri.tryParse("$url?rev=${rng.nextInt(100)}" );
    dynamic response = link != null && link?.host != null && link?.host != ''
        ? (await http.get(link))
        : Response(statusCode: 404);
    if (response.statusCode == 200) {
      filters[type] =
          await File((await getTemporaryDirectory()).path + '/' + "${type}")
              .writeAsBytes(response.bodyBytes);
      return filters[type];
    }
    return null;
  }
}
