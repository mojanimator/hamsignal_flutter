import 'package:package_info_plus/package_info_plus.dart';

class App {
  final String phone;
  final String versionName;
  int? versionUpdate;
  final String appLink;
  final String commentsLink;
  final String telegramLink;
  final String instagramLink;
  final String siteLink;
  final String emailLink;
  String whatsappLink;

  String? appName;
  String? packageName;
  String? buildNumber;
  bool needUpdate;

  App({
    this.phone = '',
    this.versionName = '1.0.0',
    this.appLink = '',
    this.commentsLink = '',
    this.telegramLink = '',
    this.instagramLink = '',
    this.siteLink = '',
    this.emailLink = '',
    this.whatsappLink = '',
    this.versionUpdate,
    this.appName,
    this.packageName,
    this.buildNumber,
    this.needUpdate = false,
  });

  factory App.fromJson(Map<String, dynamic> json, PackageInfo packageInfo) {
    // print(packageInfo.version); //1.0.0
    // print(packageInfo.appName); // دبل اسپورت
    // print(packageInfo.packageName); //com.dabel.dabel_sport
    // print(packageInfo.buildNumber); //1
    return App(
        needUpdate: int.tryParse("${json['version']}") == null
            ? false
            : int.tryParse(packageInfo.buildNumber) == null
                ? false
                : int.parse(packageInfo.buildNumber) <
                        int.parse("${json['version']}")
                    ? true
                    : false,
        versionName: packageInfo.version,
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        buildNumber: packageInfo.buildNumber,
        phone: json['phone'] ?? '',
        versionUpdate: json['version'] ?? '',
        emailLink: json['links']?['email'] ?? '',
        appLink: json['links']?['app'] ?? '',
        siteLink: json['links']?['site'] ?? '',
        commentsLink: json['links']?['comment'] ?? '',
        telegramLink: json['links']?['telegram'] ?? '',
        instagramLink: json['links']?['instagram'] ?? '');
  }
}
