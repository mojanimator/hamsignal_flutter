import 'dart:convert';

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/LinkFilterController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Link.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/Link.dart';

class LinkController extends GetxController with StateMixin<List<Link>> {
  List<Link> _data = [];
  String storageLink = "${Variables.LINK_STORAGE}/link";
  bool loading = false;

  int get currentLength => _data.length;

  List<Link> get data => _data;

  set data(List<Link> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late LinkFilterController filterController;
  late final UserController userController;
  late final Helper helper;

  LinkController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = LinkFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  String getProfileLink(int? id) {
    if (id != null)
      return "${storageLink}/$id.png";
    else
      return Variables.NOIMAGE_LINK;
  }

  Future<List<Link>?> getData({Map<String, dynamic>? param}) async {
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

    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_LINKS,
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

      if (int.parse(params['page']) > 1)
        _data.addAll(
            parsedJson["data"].map<Link>((el) => Link.fromJson(el)).toList());
      else
        _data =
            parsedJson["data"].map<Link>((el) => Link.fromJson(el)).toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  String getIconLink(String id) {
    return "${Variables.LINK_STORAGE}/link/$id.png";
  }

  Future<Link?> find(Map<String, dynamic> params) async {
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_LINKS,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);
// print(parsedJson);
    if (parsedJson != null && parsedJson?['data'].length > 0)
      return Link.fromJson(parsedJson?['data']?[0]);
    else
      return null;
  }

  Future<dynamic>? create(
      {required Map<String, dynamic> params,
      Function(double percent)? onProgress}) async {
// print(params);
    // send video after verifying other inputs

    var parsedJson = await apiProvider.fetch(Variables.LINK_CREATE_Link,
        param: params,
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        method: 'upload',
        onProgress: (percent) =>
            onProgress != null ? onProgress(percent) : null);

    // print(params);
    if (parsedJson != null && parsedJson['errors'] != null) {
      helper.showToast(
          msg: parsedJson['errors']?[parsedJson['errors'].keys.elementAt(0)]
              ?.join("\n"),
          status: 'danger');
      return null;
    }
    return parsedJson;
  }

  Future<dynamic> edit(
      {required Map<String, dynamic> params,
      Function(double percent)? onProgress}) async {
    var parsedJson = await apiProvider.fetch(Variables.LINK_EDIT_LinkES,
        param: params,
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        method: 'post',
        onProgress: (percent) =>
            onProgress != null ? onProgress(percent) : null);

    if (parsedJson != null && parsedJson['errors'] != null) {
      var msg;
      if (parsedJson['errors'] is List<dynamic>)
        msg = parsedJson['errors']?.join("\n").toString();
      else
        msg = parsedJson['errors'][parsedJson['errors'].keys.elementAt(0)]
            .join("\n");
      helper.showToast(msg: msg, status: 'danger');
      return null;
    }

    return parsedJson;
  }

  void launchUrl(Link link) async {
    if (!link.isLocked || userController.hasPlan(goShop: true, message: true)) {
      if (await canLaunchUrlString(link.url))
        launchUrlString(link.url, mode: LaunchMode.externalApplication);
      else
        helper.showToast(msg: 'cant_launch_url'.tr, status: 'danger');
    }
  }
}
