import 'package:get/get.dart';

import 'APIController.dart';
import 'TicketController.dart';

class TicketFilterController extends APIController<bool> {
  int _total = -1;
  TicketController parent;

  String searchHintText = 'search'.tr;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  Map<String, dynamic> initFilters = {
    'page': '0',
    'search': null,
    // 'paginate':8

    // 'panel': '',
  };
  late Map<String, dynamic> filters;

  TicketFilterController({required this.parent}) {
    filters = {...initFilters};
  }

  @override
  onInit() {
    change(true, status: RxStatus.success());
    super.onInit();
  }

  dynamic getFilterSelected(type, {idx}) {
    return filters[type];
  }

  dynamic getFilterName(type) {
    switch (type) {
      case 'chat_id':
        return this.parent.settingController.category(filters[type]);

      default:
        return filters[type].toString();
    }
  }

  dynamic toggleFilter(String type, {idx}) {
    if (idx == null) {
      filters[type] = null;
    } else
      switch (type) {
        case 'chat_id':
          filters['chat_id'] = idx;
          break;
      }
    update();
  } //set pre filters for list

  void set(Map<String, String> filter) {
    filters = {...initFilters};

    if (filter == {}) {
    } else {
      for (var key in filter.keys) filters[key] = filter[key];
    }
  }
}
