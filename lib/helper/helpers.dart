import 'dart:io';
import 'dart:typed_data';

import 'package:hamsignal/controller/APIProvider.dart';
import 'package:hamsignal/helper/styles.dart';
import 'package:hamsignal/helper/variables.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pushpole/pushpole.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:share_plus/share_plus.dart';

enum TYPE { BOORS, CRYPTO, FOREX }

class Helper {
  static late GetStorage box;

  late final Style style;
  static late ApiProvider apiProvider;

  static PackageInfo? packageInfo;

  static AndroidDeviceInfo? androidInfo;

  Helper() {
    box = GetStorage();

    style = Get.find<Style>();
    apiProvider = ApiProvider();
    getAndroidInfo();
    getPackageInfo();
  }

  static localStorage({required String key, dynamic def, dynamic write}) {
    if (write != null) {
      box.write(key, write);
    } else {
      return box.read(key) ?? def;
    }
  }

  static Future<AndroidDeviceInfo?> getAndroidInfo() async {
    androidInfo ??= await DeviceInfoPlugin().androidInfo;
    return androidInfo;
  }

  static Future<PackageInfo?> getPackageInfo() async {
    packageInfo ??= await PackageInfo.fromPlatform();
    return packageInfo;
  }

  showToast({required String msg, String status = 'info'}) {
    final snackBar = Get.snackbar(
      '$msg',
      '',
      colorText: Colors.white,
      padding: EdgeInsets.all(style.cardMargin / 2),
      margin: EdgeInsets.all(style.cardMargin / 2),
      onTap: (snack) => Get.closeCurrentSnackbar(),
      borderRadius: style.cardBorderRadius,
      icon: status == 'danger'
          ? Icon(
              Icons.dangerous_outlined,
              color: Colors.white,
            )
          : status == 'success'
              ? Icon(Icons.done, color: Colors.white)
              : Icon(Icons.info_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,

      // messageText: Center(
      //   child: Text(
      //     msg,
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 20,
          offset: Offset(0, 6), // changes position of shadow
        ),
      ],

      backgroundColor: status == 'success'
          ? Colors.green
          : status == 'danger'
              ? Colors.red
              : style.primaryColor,
    );
  }

  static String toShamsi(date) {
    if (date != null) {
      JalaliFormatter f =
          Jalali.fromDateTime(DateTime.fromMillisecondsSinceEpoch(date * 1000))
              .formatter;
      return e2f(
          " ${f.d} ${f.mN} | ${"${f.date.hour}".padLeft(2, '0')}:${"${f.date.minute}".padLeft(2, '0')}"); //⏰
      // int hours = (DateTime.tryParse(date).toUtc().millisecondsSinceEpoch -
      //         DateTime.now().millisecondsSinceEpoch) ~/
      //     3600000;
      // int hours = DateTime.tryParse(date).difference(DateTime.now()).inHours +
      //     (DateTime.now().toLocal().hour - DateTime.now().toUtc().hour);
      //
      // return (hours > 24
      //     ? " ${hours ~/ 24} ${Variable.LANG == 'fa' ? 'روز' : 'Day' + (hours ~/ 24 > 1 ? 's' : '')} "
      //     : "$hours ${Variable.LANG == 'fa' ? 'ساعت' : 'Hour' + (hours > 1 ? 's' : '')} ")
      //     .toString();
    } else
      return "";
  }

  static void shareFile({path, text}) async {
    String dir = (await getTemporaryDirectory()).path;
    File temp = File('$dir/temp.jpg');
    final ByteData imageData =
        await NetworkAssetBundle(Uri.parse(path)).load('');
    final Uint8List bytes = imageData.buffer.asUint8List();
    await temp.writeAsBytes(bytes);
    /*do something with temp file*/

    await Share.shareFiles(
      [temp.path],
      text: text,
      subject: 'label'.tr,
    );
    temp.delete();
  }

  static sendError(Map<String, String> params) async {
    androidInfo ??= await DeviceInfoPlugin().androidInfo;
    var release = androidInfo?.version.release;
    var sdkInt = androidInfo?.version.sdkInt;
    var manufacturer = androidInfo?.manufacturer;
    var model = androidInfo?.model;
    packageInfo ??= await PackageInfo.fromPlatform();
    String? buildNumber = packageInfo?.buildNumber;

    params['message'] =
        "${Variables.LABEL} ❎ version:$buildNumber\n$model\n$release\n$sdkInt\n$manufacturer\n${params['message']}";

    return await apiProvider.fetch(Variables.LINK_SEND_ERROR,
        param: params, method: 'post');
  }

  static Future<bool> initPushPole() async {
    if (!await PushPole.isPushPoleInitialized()) await PushPole.initialize();
    PushPole.isPushPoleInitialized().then((initialized) async {
      if (initialized) {
        // var id = await PushPole.getId();
        PushPole.subscribe(Variables.LABEL);
        return true;
      }
    });
    return false;
  }
}

String e2f(String s) {
  var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(RegExp(enNumbers[i]), persianNumbers[i]);
  }
  return s;
}

String f2e(String s) {
  var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(RegExp(persianNumbers[i]), enNumbers[i]);
  }
  return s;
}

extension RangeExtension on int {
  List<int> to(int max, {int step = 1}) =>
      [for (int i = this; i <= max; i += step) i];
}

extension PriceViewExtension on String {
  String asPrice() =>
      this.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) {
        return '${m[1]},';
      });
}

extension ToEngExtension on String {
  String toEng() => f2e(this);
}

extension ToFaExtension on String {
  String toFa() => e2f(this);
}
