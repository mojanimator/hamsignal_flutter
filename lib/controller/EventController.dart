import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:get/get.dart';

class EventController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  late ApiProvider apiProvider;
  Map<String, dynamic> _data = {};

  String today = '';

  bool loading = false;

  RxInt currentTabIndex = 0.obs;

  EventController() {
    apiProvider = Get.find<ApiProvider>();
  }

  Future<Map<String, dynamic>?> getData({Map<String, dynamic>? params}) async {
    loading = true;
    change(null, status: RxStatus.loading());
    final parsedJson = await apiProvider.fetch(
      Variables.LINK_GET_EVENTS,
      param: params,
    );
    loading = false;
    // print(parsedJson?['days']['شنبه'].length);
    if (parsedJson == null) {
      change(null, status: RxStatus.empty());
      return null;
    } else {

      if (parsedJson['days'] != null) _data = parsedJson['days'].length==0?{}:parsedJson['days'] ;
      today = parsedJson['today'];
      if(!_data.containsKey(today)){
        _data.addAll({today: null});
      }
      change(_data, status: RxStatus.success());
      return _data;
    }
  }


}
