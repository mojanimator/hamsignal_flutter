import 'dart:convert';

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/controller/TransactionFilterController.dart';
import 'package:hamsignal/controller/SettingController.dart';
import 'package:hamsignal/controller/UserController.dart';
import 'package:hamsignal/helper/helpers.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:hamsignal/model/Transaction.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Category.dart';

class TransactionController extends GetxController
    with StateMixin<List<Transaction>> {
  List<Transaction> _data = [];
  bool loading = false;

  int get currentLength => _data.length;

  List<Transaction> get data => _data;

  set data(List<Transaction> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late TransactionFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  TransactionController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = TransactionFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  Future<List<Transaction>?> getData({
    Map<String, dynamic>? param,
  }) async {
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
    // print(params);
    //add sport,province,county to name search
    if (params['search'] != null && params['search'] != '') {}
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_TRANSACTIONS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null ||
        parsedJson['data'] == null ||
        parsedJson['data'].length == 0) {
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
            .map<Transaction>((el) => Transaction.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<Transaction>((el) => Transaction.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }
}
