import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Style {
  late ThemeData themeData;

  late bool isBigSize;

  Style() {
    isBigSize = false;
    themeData = ThemeData(
      primarySwatch: primaryMaterial,
      backgroundColor: primaryMaterial[50],
      splashColor: secondaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Shabnam',
      textTheme: const TextTheme(
        headline1: TextStyle(
            fontSize: 72.0, fontWeight: FontWeight.bold, fontFamily: 'Shabnam'),
        headline6: TextStyle(
            fontSize: 24.0, fontWeight: FontWeight.w500, fontFamily: 'Shabnam'),
        bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Shabnam'),
      ),
    );
    themeData = Get.isDarkMode ? ThemeData.dark() : themeData;

    themeData.copyWith(
      primaryColor: primaryColor,
    );
    buttonStyle = (color) => ButtonStyle(
        elevation: MaterialStateProperty.all(2),
        shadowColor: MaterialStateProperty.all(color.withOpacity(.5)),
        padding: MaterialStateProperty.all(EdgeInsets.all(cardMargin / 2)),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            return states.contains(MaterialState.pressed) ? color : null;
          },
        ),
        backgroundColor: MaterialStateProperty.all(color.withOpacity(.8)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          side: BorderSide(color: color),
          borderRadius: BorderRadius.all(
            Radius.circular(cardBorderRadius / 2),
          ),
        )));
  }

  Color get primaryColor => const Color(0xFF343265);

  Color get secondaryColor => const Color(0xFF18ffff);

  MaterialColor primaryMaterial = MaterialColor(
    0xFF343265,
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe7e7ea), //10%
      100: Color(0xffaeadc1), //20%
      200: Color(0xff9a99b2), //30%
      300: Color(0xff8584a3), //40%
      400: Color(0xff717093), //50%
      500: Color(0xFF343265), //60%
      600: Color(0xFF343265), //70%
      700: Color(0xFF343265), //80%
      800: Color(0xff0a0a14), //90%
      900: Color(0xff05050a), //100%
    },
  );

  get theme => themeData;

  double get tabHeight => isBigSize ? 48.0 : 48.0;

  double get cardMargin => isBigSize ? 32.0 : 16.0;

  get cardColor => Colors.white.withOpacity(1);

  get iconHeight => 50.0;

  get topOffset => Get.height / 4;

  get cardBorderRadius => 20.0;

  get cardVitrinHeight => 200.0;

  get imageHeight => 120.0;

  double get gridHeight => 150;

  TextStyle get textBigLightStyle => TextStyle(
      color: primaryMaterial[50], fontSize: 20, fontWeight: FontWeight.bold);

  TextStyle get textBigStyle => TextStyle(
      color: primaryMaterial[500], fontSize: 20, fontWeight: FontWeight.bold);

  TextStyle get textHeaderLightStyle => TextStyle(
      color: primaryMaterial[50], fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle get textTinyLightStyle =>
      TextStyle(color: primaryMaterial[50], fontSize: 10);

  TextStyle get textSmallStyle => TextStyle(
        color: primaryMaterial[800],
        fontSize: 12,
      );

  TextStyle get textSmallLightStyle => TextStyle(
        color: Colors.white,
        fontSize: 12,
      );

  TextStyle get textMediumLightStyle => TextStyle(
        color: Colors.white,
        fontSize: 14,
      );

  TextStyle get textMediumStyle => TextStyle(
        color: primaryColor,
        fontSize: 14,
      );

  TextStyle get textHeaderStyle => TextStyle(
        color: primaryColor,
        fontSize: 16,
      );

  LinearGradient get splashBackground => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [secondaryColor, primaryMaterial[700]!, primaryMaterial[900]!]);

  LinearGradient get splashBackgroundReverse => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryMaterial[900]!,
            primaryMaterial[700]!,
            secondaryColor,
          ]);

  // ButtonStyle get buttonStyle =>
  //     ButtonStyle(backgroundColor: MaterialStateProperty.all(primaryColor));

  LinearGradient get mainGradientBackground => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.white, primaryMaterial[100]!]);

  late Function(Color color) buttonStyle;

  double get bottomNavigationBarHeight => 70.0;

  MaterialColor get cardPlayerColors => Colors.blueGrey;

  MaterialColor get cardCoachColors => Colors.pink;

  MaterialColor get cardClubColors => Colors.indigo;

  MaterialColor get cardShopColors => Colors.brown;

  MaterialColor get cardProductColors => Colors.teal;

  MaterialColor get cardBlogColors => Colors.purple;

  MaterialColor get cardTournamentColors => Colors.orange;


  int get gridLength => 1;
}
