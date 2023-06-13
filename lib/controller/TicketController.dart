import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/helpers.dart';
import '../helper/variables.dart';
import '../model/Category.dart';
import '../model/Ticket.dart';
import 'APIProvider.dart';
import 'SettingController.dart';
import 'TicketFilterController.dart';
import 'UserController.dart';

class TicketController extends GetxController with StateMixin<dynamic> {
  List<TicketChat> _data = [];
  bool loading = false;

  late final apiProvider;
  late final SettingController settingController;
  late TicketFilterController filterController;
  late final UserController userController;
  late final Helper helper;
  List<Ticket> tickets = [];

  TicketController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    filterController = TicketFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  Future<List<TicketChat>?> getChat({
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

    Map<String, dynamic> params = {
      ...filterController.filters,
      ...{'ticket_id': param?['ticket_id']}
    };

    // print(params);
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_TICKETS,
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
            .map<TicketChat>((el) => TicketChat.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<TicketChat>((el) => TicketChat.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  Future<dynamic> getTickets({
    Map<String, dynamic>? param,
  }) async {
    loading = true;
    update();

    // print(params);
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_GET_TICKETS,
        param: {'group_by': 'chat_id'},
        ACCESS_TOKEN: userController.ACCESS_TOKEN);
    // print(parsedJson);
    if (parsedJson == null) {
      loading = false;
      change([], status: RxStatus.empty());
      return [];
    } else {
      loading = false;
      tickets =
          parsedJson['data'].map<Ticket>((e) => Ticket.fromJson(e)).toList();

      change(tickets, status: RxStatus.success());
      return parsedJson;
    }
  }

  String getLink(int id) {
    return "";
  }

  Future<TicketChat?> find(Map<String, dynamic> params) async {
    String link = Variables.LINK_GET_TICKETS;

    final parsedJson = await apiProvider.fetch(link,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

    if (parsedJson != null &&
        parsedJson['data'] != null &&
        parsedJson['data'].length > 0)
      return TicketChat.fromJson(parsedJson['data'][0]);
    else
      return null;
  }

  launchFile({required String link}) async {
    if (userController.hasPlan(goShop: true, message: true)) {
      if (await canLaunchUrlString(link))
        launchUrlString(link, mode: LaunchMode.externalApplication);
      else
        helper.showToast(msg: 'cant_load_file'.tr, status: 'danger');
    }
  }

  Future sendMessage({
    String? ticketId,
    required String message,
    required String cmnd,
    String? subject,
  }) async {
    if (message == '') return false;
    final res = await apiProvider.fetch(Variables.LINK_CREATE_TICKET_CHAT,
        method: 'post',
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        param: {
          'subject': subject,
          'ticket_id': ticketId,
          'message': message,
          'cmnd': cmnd
        });
    // print(res);
    String? error = 'problem_send_chat'.tr;
    try {
      if (res != null && res['status'] != null && res['status'] == 'success')
        error = null;
      else if (res != null && res['message'] != null) error = res['message'];
    } catch (e) {}
    if (error != null) helper.showToast(msg: error, status: 'danger');
    return res ?? {};
  }

  Future edit({required Map<String, String?> param}) async {
    final res = await apiProvider.fetch(Variables.LINK_UPDATE_TICKET,
        method: 'post',
        ACCESS_TOKEN: userController.ACCESS_TOKEN,
        param: param);

    return res ?? {};
  }
}
