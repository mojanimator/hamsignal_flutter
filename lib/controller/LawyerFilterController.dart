import 'package:dabel_adl/controller/APIController.dart';
import 'package:dabel_adl/controller/LawyerController.dart';
import 'package:get/get.dart';

class LawyerFilterController extends APIController<bool> {
  int _total = -1;
  LawyerController parent;

  String searchHintText = 'name'.tr

      /*+
      ',' +
      'experience'.tr +
      ',' +
      'province'.tr +
      ',' +
      'county'.tr*/
      ;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'target': 'lawyer',
    'search': '',
    'gender': null,
    'sport': null,
    'province': null,
    'county': null,
    'age_l': '',
    'age_h': '',
    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  LawyerFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type, {idx}) {
    if (type == 'target') {
      if (filters[type] == 'expert')
        return [false, true];
      else
        return [true, false];
    } else
      return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'target':
        return filters[type] == 'lawyer'
            ? 'lawyer'.tr
            : filters[type] == 'expert'
                ? 'expert'.tr
                : '';
      case 'province':
        return this
            .parent
            .settingController
            .province("${filters["province_id"]}");
      case 'county':
        return this.parent.settingController.county("${filters["city_id"]}");
      case 'category_id':
        return this
            .parent
            .settingController
            .category("${filters["category_id"]}");

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      if (type == 'province') {
        filters[type] = null;
        filters["${type}_id"] = null;
        filters['county'] = null;
        filters['city_id'] = null;
      } else
        filters[type] = null;
    } else
      switch (type) {
        case 'target':
          if (idx == 0) {
            if (filters[type] == 'lawyer')
              filters[type] = null;
            else
              filters[type] = 'lawyer';
          } else if (idx == 1) {
            if (filters[type] == 'expert')
              filters[type] = null;
            else
              filters[type] = 'expert';
          } else if (idx == 0) filters[type] = null;
          filters['category_id'] = null;
          break;
        case 'category_id':
          filters[type] = idx;
          break;
        case 'province':
          filters["${type}_id"] = idx;
          filters['city_id'] = null;
          filters["province"] = idx;
          filters['county'] = null;
          break;
        case 'county':
          filters['city_id'] = idx;
          filters['county'] = idx;

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
