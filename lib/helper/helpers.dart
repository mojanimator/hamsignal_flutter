import 'dart:io';
import 'dart:typed_data';

import 'package:dabel_sport/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:share_plus/share_plus.dart';

class Helper {
  late final Style styleController;

  Helper() {
    styleController = Get.find<Style>();
  }

  showToast({required String msg, String status = 'info'}) {
    final snackBar = Get.snackbar(
      '$msg',
      '',
      colorText: Colors.white,
      padding: EdgeInsets.all(styleController.cardMargin / 2),
      margin: EdgeInsets.all(styleController.cardMargin / 2),
      onTap: (snack) => Get.closeCurrentSnackbar(),
      borderRadius: styleController.cardBorderRadius,
      icon: status == 'danger'
          ? Icon(Icons.dangerous_outlined)
          : status == 'success'
              ? Icon(Icons.done)
              : Icon(Icons.info_outline),
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
              : styleController.primaryColor,
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
}

String e2f(String s) {
  var persianNumbers = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var enNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];

  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(RegExp(enNumbers[i]), persianNumbers[i]);
  }
  return s;
}

extension RangeExtension on int {
  List<int> to(int max, {int step = 1}) =>
      [for (int i = this; i <= max; i += step) i];
}

extension PriceViewExtension on String {
  String asPrice() => this.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}
