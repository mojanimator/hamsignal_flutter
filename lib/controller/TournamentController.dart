import 'dart:convert';

import 'package:dabel_sport/controller/APIProvider.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/controller/TournamentFilterController.dart';
import 'package:dabel_sport/controller/UserController.dart';
import 'package:dabel_sport/helper/variables.dart';
import 'package:dabel_sport/model/Tournament.dart';
import 'package:get/get.dart';

class TournamentController extends GetxController
    with StateMixin<List<Tournament>> {
  late ApiProvider apiProvider;
  late TournamentFilterController filterController;
  late SettingController settingController;
  late UserController userController;

  List<Tournament> _data = [];

  List<Tournament> get data => _data;

  set data(List<Tournament> value) {
    _data = value;
  }

  String today = '';

  bool loading = false;

  RxInt currentTabIndex = 0.obs;

  TournamentController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    userController = Get.find<UserController>();
    filterController = Get.put(TournamentFilterController(parent: this));
  }

  Future<List<Tournament>?> getData({Map<String, dynamic>? param}) async {
    loading = true;
    update();
    if (param != null && param['page'] == 'clear') {
      filterController.total = -1;
      filterController.filters['page'] = '0';
      _data.clear();
      change(_data, status: RxStatus.loading());
    }

    if (filterController.total == 0 ||
        (filterController.total > 0 &&
            _data.length >= filterController.total)) {
      loading = false;
      change(_data, status: RxStatus.success());
      return null;
    }
    filterController.filters['page'] =
        (int.parse(filterController.filters['page']) + 1).toString();
    filterController.update();

    Map<String, dynamic> params = {...filterController.filters};

    //add sport,province,county to name search
    if (    params['name'] != '') {
      if (params['sport'] == null) {
        params['sport'] = settingController.sports
            .where((e) => e['name'].contains(params['name']))
            .map((e) => e['id'])
            .toList();
        if (params['sport'].length == 0)
          params['sport'] = null;
        else
          params['sport'] = json.encode(params['sport']);
      }
    }
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_TOURNAMENTS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson == null || parsedJson['data'].length == 0) {
      loading = false;
      if (int.parse(filterController.filters['page']) > 1)
        change(_data, status: RxStatus.success());
      else
        change(_data, status: RxStatus.empty());
      return _data;
    } else {
      filterController.total = parsedJson["total"];

      if (int.parse(params['page']) > 0)
        _data.addAll(parsedJson["data"]
            .map<Tournament>((el) => Tournament.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<Tournament>((el) => Tournament.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  String getSport(id) {
    return settingController.sport(id);
  }

  String getProfileLink(id) {
    var t = settingController.getDocType('tournament');

    return "${Variables.LINK_STORAGE}/${t}/${id}.jpg";
  }

  Future<Tournament?> find(Map<String, dynamic> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_TOURNAMENTS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson);
    if (parsedJson != null && parsedJson['data'].length > 0)
      return Tournament.fromJson(parsedJson['data']?[0]);
    else
      return null;
  }
}
