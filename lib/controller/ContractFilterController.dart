import 'package:hamsignal/controller/APIController.dart';
import 'package:hamsignal/controller/ContractController.dart';
import 'package:get/get.dart';

class ContractFilterController extends APIController<bool> {
  int _total = -1;
  ContractController parent;

  String searchHintText = 'name'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': '',
    'categoryId': null,

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  ContractFilterController({required this.parent}) {
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

  dynamic getFilterName(type,{idx}) {
    print(type);
    switch (type) {
      case 'categoryId':
        return this.parent.settingController.category(filters[type]);


      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      if (type == 'province_id') {
        filters['province_id'] = null;
        filters['county_id'] = null;
      } else if (type == 'county_id') {
        filters['county_id'] = null;
      } else
        filters[type] = null;
    } else
      switch (type) {
        case 'province_id':
          filters["province_id"] = idx;
          filters['county_id'] = null;
          break;
        case 'county_id':
          filters['county_id'] = idx;
          break;
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
