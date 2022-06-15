import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AppController extends GetxController     {
  final count = 0.obs;

  void increment() {
    count.value++;
    // update(); when use getBuilder<AppController>() in scaffold
  }
}
