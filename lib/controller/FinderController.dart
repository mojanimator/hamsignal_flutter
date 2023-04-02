import 'dart:convert';
import 'dart:io';

import 'package:dabel_adl/controller/APIProvider.dart';
import 'package:dabel_adl/controller/BookController.dart';
import 'package:dabel_adl/controller/ContentController.dart';
import 'package:dabel_adl/controller/ContractController.dart';
import 'package:dabel_adl/controller/DocumentController.dart';
import 'package:dabel_adl/controller/FinderFilterController.dart';
import 'package:dabel_adl/controller/LegalController.dart';
import 'package:dabel_adl/controller/LocationController.dart';
import 'package:dabel_adl/controller/SettingController.dart';
import 'package:dabel_adl/controller/UserController.dart';
import 'package:dabel_adl/helper/helpers.dart';
import 'package:dabel_adl/helper/variables.dart';
import 'package:dabel_adl/model/Book.dart';
import 'package:dabel_adl/model/Content.dart';
import 'package:dabel_adl/model/Contract.dart';
import 'package:dabel_adl/model/Finder.dart';
import 'package:dabel_adl/model/Legal.dart';
import 'package:dabel_adl/page/document_details.dart';
import 'package:dabel_adl/page/documents.dart';
import 'package:dabel_adl/widget/grid_book.dart';
import 'package:dabel_adl/widget/grid_content.dart';
import 'package:dabel_adl/widget/grid_contract.dart';
import 'package:dabel_adl/widget/grid_document.dart';
import 'package:dabel_adl/widget/grid_legal.dart';
import 'package:dabel_adl/widget/grid_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/styles.dart';
import '../model/Category.dart';
import '../model/Document.dart';
import '../model/Location.dart';

class FinderController extends GetxController with StateMixin<List<Finder>> {
  List<Finder> _data = [];
  late String _storageLink;
  bool loading = false;

  int get currentLength => _data.length;

  List<Finder> get data => _data;

  String get storageLink => _storageLink;

  set storageLink(String storageLink) {}

  set data(List<Finder> value) {
    _data = value;
  }

  late final apiProvider;
  late final SettingController settingController;
  late FinderFilterController filterController;
  late final UserController userController;

  late final DocumentController documentController;
  late final BookController bookController;
  late final LocationController locationController;
  late final ContractController contractController;
  late final ContentController contentController;
  late final LegalController legalController;

  late final Style styleController;
  late final Helper helper;

  FinderController() {
    apiProvider = Get.find<ApiProvider>();
    settingController = Get.find<SettingController>();
    styleController = Get.find<Style>();
    filterController = FinderFilterController(parent: this);
    userController = Get.find<UserController>();
    helper = Get.find<Helper>();

    documentController = Get.find<DocumentController>();
    bookController = Get.find<BookController>();
    locationController = Get.find<LocationController>();
    contractController = Get.find<ContractController>();
    contentController = Get.find<ContentController>();
    legalController = Get.find<LegalController>();
  }

  @override
  onInit() {
    // getData();
    super.onInit();
  }

  List get types => CategoryRelate.types;

  String type(type_id) {
    var t =
        types.firstWhereOrNull((element) => "${element['id']}" == "$type_id");
    return t == null ? '' : t['title'];
  }

  Future<List<Finder>?> getData({
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
    filterController.filters['finder'] = filterController.filters['search'];
    if (filterController.filters['search'] == '') {
      loading = false;
      change(_data, status: RxStatus.empty());
      return _data;
    }
    Map<String, dynamic> params = {...filterController.filters};
    // change(_data, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(Variables.LINK_FINDER,
        param: params, ACCESS_TOKEN: userController.ACCESS_TOKEN);

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
            .map<Finder>((el) => Finder.fromJson(el))
            .toList());
      else
        _data = parsedJson["data"]
            .map<Finder>((el) => Finder.fromJson(el))
            .toList();

      loading = false;
      change(_data, status: RxStatus.success());

      return _data;
    }
  }

  getGrid({
    required Finder data,
  }) {
    if (data.source == CategoryRelate.Books)
      return GridBook(
          data: Book.fromJson({
            'id': data.id,
            'title': data.title,
          }),
          controller: bookController,
          settingController: settingController,
          styleController: styleController,
          userController: userController,
          colors: styleController.cardBookColors);
    else if (data.source == CategoryRelate.Contents)
      return GridContent(
          data: Content.fromJson({
            'id': data.id,
            'title': data.title,
          }),
          controller: contentController,
          settingController: settingController,
          styleController: styleController,
          colors: styleController.cardContentColors);
    else if ([
      CategoryRelate.Conventions,
      CategoryRelate.Opinions,
      CategoryRelate.Votes
    ].contains(data.source))
      return GridDocument(
        data: Document.fromJson({
          'id': data.id,
          'title': data.title,
        }),
        categoryType: data.source,
        controller: documentController,
        settingController: settingController,
        styleController: styleController,
        userController: userController,
      );
    else if (data.source == CategoryRelate.Legal_Needs)
      return GridLegal(
          data: Legal.fromJson({
            'id': data.id,
            'title': data.title,
          }),
          controller: legalController,
          settingController: settingController,
          styleController: styleController,
          userController: userController,
          colors: styleController.cardContentColors);
    else if (data.source == CategoryRelate.Locations) {
      List latLong = data.extra.split(',');
      return GridLocation(
        data: Location.fromJson({
          'id': data.id,
          'title': data.title,
          'lat': latLong.length > 1 ? latLong[0] : '',
          'long': latLong.length > 1 ? latLong[1] : '',
          'address': data.content,
        }),
        controller: locationController,
        settingController: settingController,
        styleController: styleController,
        userController: userController,
      );
    } else if (data.source == CategoryRelate.Locations)
      return GridContract(
          data: Contract.fromJson({
            'id': data.id,
            'title': data.title,
          }),
          controller: contractController,
          settingController: settingController,
          styleController: styleController,
          userController: userController,
          colors: styleController.cardContentColors);
  }
}
