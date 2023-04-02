import 'package:dabel_adl/controller/APIController.dart';
import 'package:dabel_adl/controller/DocumentController.dart';
import 'package:dabel_adl/model/Category.dart';
import 'package:get/get.dart';

class DocumentFilterController extends APIController<bool> {
  int _total = -1;
  DocumentController parent;

  String searchHintText = 'name'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': '',
    'province_id': null,
    'county_id': null,
    'categoryId': null,
    'document_type': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  DocumentFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type,{idx}) {
    return filters[type];
  }

  dynamic getFilterName(type) {

    switch (type) {
      case 'categoryId':

        return this.parent.category("${filters[type]}");

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else
      switch (type) {
        case 'categoryId':
          filters['categoryId'] = idx;
          break;
      }
    update();
    this.parent.getData(param: {'page': 'clear'});
  } //set pre filters for list

  void set(Map<String, String> filter) {
    filters = {...initFilters};

    if (filter == {}) {
    } else {
      for (var key in filter.keys) filters[key] = filter[key];
    }
  }
}
