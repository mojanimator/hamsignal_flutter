import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Style {
  late ThemeData themeData;

  late bool isBigSize;
  late Function(
      {Color? backgroundColor,
      EdgeInsets? padding,
      double? elevation,
      OutlinedBorder? shape,
      BorderRadius? radius,
      Color? splashColor}) buttonStyle;

  Style() {
    isBigSize = false;
    themeData = ThemeData(
      primarySwatch: primaryMaterial,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primaryContainer: primaryColor,
        primary: primaryColor,
        onPrimary: primaryMaterial[100]!,
        secondary: secondaryColor,
        secondaryContainer: secondaryColor,
        onTertiary: primaryColor,
        onSecondary: Color(0xFFEAEAEA),
        error: Color(0xFFF32424),
        onError: Color(0xFFF32424),
        background: Color(0xFFF1F2F3),
        onBackground: Color(0xFFFFFFFF),
        surface: primaryMaterial[50]!,
        onSurface: primaryMaterial[100]!,
      ),
      splashColor: secondaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Shabnam',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
            fontSize: 72.0, fontWeight: FontWeight.bold, fontFamily: 'Shabnam'),
        titleLarge: TextStyle(
            fontSize: 24.0, fontWeight: FontWeight.w500, fontFamily: 'Shabnam'),
        bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Shabnam'),
      ),
    );
    themeData = Get.isDarkMode ? ThemeData.dark() : themeData;

    themeData.copyWith(
      primaryColor: primaryColor,
    );
    buttonStyle = (
            {Color? backgroundColor = const Color(0xFF7e394b),
            EdgeInsets? padding,
            double? elevation,
            OutlinedBorder? shape,
            BorderRadius? radius,
            Color? splashColor}) =>
        ButtonStyle(
            elevation: MaterialStateProperty.all(elevation ?? 2),
            shadowColor:
                MaterialStateProperty.all(backgroundColor?.withOpacity(.5)),
            padding: MaterialStateProperty.all(
                padding ?? EdgeInsets.all(cardMargin)),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              return states.contains(MaterialState.disabled)
                  ? backgroundColor?.withOpacity(.6)
                  : backgroundColor;
            }),
            overlayColor: MaterialStateProperty.resolveWith(
              (states) {
                return states.contains(MaterialState.pressed)
                    ? (splashColor ?? secondaryColor.withOpacity(.2))
                    : null;
              },
            ),
            shape: MaterialStateProperty.all(shape ??
                RoundedRectangleBorder(
                  side: BorderSide(color: backgroundColor ?? primaryColor),
                  borderRadius: radius ??
                      BorderRadius.all(
                        Radius.circular(cardMargin),
                      ),
                )));
  }

  get linksGridCount => isBigSize ? 3 : 2;

  get linksRatio => isBigSize ? 2 : 2.8;

  void setSize(width) {
    isBigSize = width != null && width > 500;
  }

  Color get primaryColor => const Color(0xFF7e394b);

  Color get secondaryColor => const Color(0xfffeebca);

  Color get theme1 => const Color(0xff4d4b30);

  Color get theme2 => const Color(0xff908660);

  Color get theme3 => const Color(0xfffeebca);

  Color get theme4 => const Color(0xfff4cca6);

  Color get theme5 => const Color(0xffdaa38b);

  Color get theme6 => const Color(0xFF7e394b);

  MaterialColor primaryMaterial = null ??
      MaterialColor(
        0xFF343265,
        // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
        <int, Color>{
          50: Color(0xfffff4f6), //10%
          100: Color(0xffdf7c8b), //20%
          200: Color(0xffa65b64), //30%
          300: Color(0xff8d4d57), //40%
          400: Color(0xff8e4055), //50%
          500: Color(0xFF7e394b), //60%
          600: Color(0xff8b3c47), //70%
          700: Color(0xff823843), //80%
          800: Color(0xff5d272c), //90%
          900: Color(0xff552327), //100%
        },
      );
  MaterialColor greenMaterial = MaterialColor(
    0xFF343265,
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF03F5B1), //10%
      100: Color(0xFF02D79B), //20%
      200: Color(0xFF02B986), //30%
      300: Color(0xFF01AE7D), //40%
      400: Color(0xFF02966C), //50%
      500: Color(0xFF018660), //60%
      600: Color(0xFF017453), //70%
      700: Color(0xFF004E38), //80%
      800: Color(0xFF003224), //90%
      900: Color(0xFF00120D), //100%
    },
  );
  MaterialColor redMaterial = MaterialColor(
    0xFF343265,
    // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe2d8da), //10%
      100: Color(0xffcea5ac), //20%
      200: Color(0xffd47082), //30%
      300: Color(0xff8d4d57), //40%
      400: Color(0xff8e4055), //50%
      500: Color(0xFF7e394b), //60%
      600: Color(0xff8b3c47), //70%
      700: Color(0xff823843), //80%
      800: Color(0xff5d272c), //90%
      900: Color(0xff552327), //100%
    },
  );

  get theme => themeData;

  double get tabHeight => isBigSize ? 48.0 : 48.0;

  double get cardMargin => isBigSize ? 12.0 : 8.0;

  get cardColor => Colors.white.withOpacity(1);

  get iconHeight => 50.0;

  get topOffset => Get.height / 4;

  get cardBorderRadius => 20.0;

  get cardVitrinHeight => 200.0;

  get imageHeight => isBigSize ? 120.0 : 98.0;

  double get gridHeight => isBigSize ? 150.0 : 120.0;

  TextStyle get textBigLightStyle => TextStyle(
      color: secondaryColor, fontSize: 20, fontWeight: FontWeight.bold);

  TextStyle get textBigStyle => TextStyle(
      color: primaryMaterial[500], fontSize: 20, fontWeight: FontWeight.bold);

  TextStyle get textHeaderLightStyle => TextStyle(
      color: secondaryColor, fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle get textTinyLightStyle =>
      TextStyle(color: secondaryColor, fontSize: 10);

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

  TextStyle get textMediumStyle =>
      TextStyle(color: primaryColor, fontSize: 14, height: 1.7);

  TextStyle get textHeaderStyle => TextStyle(
        color: primaryColor,
        fontSize: 16,
      );

  LinearGradient get splashBackground => LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            primaryMaterial[100]!,
            primaryMaterial[700]!,
            primaryMaterial[900]!
          ]);

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
      colors: [theme3, theme4, theme5]);

  double get bottomNavigationBarHeight => 70.0;

  MaterialColor get cardContentColors => Colors.blueGrey;

  MaterialColor get cardLawyerColors => Colors.indigo;

  MaterialColor get cardLocationColors => Colors.teal;

  MaterialColor get cardLegalColors => Colors.brown;

  MaterialColor get cardBookColors => redMaterial;

  MaterialColor get cardVotesColors => Colors.indigo;

  MaterialColor get cardOpinionsColors => Colors.teal;

  MaterialColor get cardConventionsColors => Colors.brown;

  MaterialColor get cardNewsColors => redMaterial;

  MaterialColor get cardContractColors => redMaterial;

  MaterialColor get cardPlayerColors => Colors.blueGrey;

  MaterialColor get cardLinkColors => Colors.pink;

  MaterialColor get cardClubColors => Colors.indigo;

  MaterialColor get cardShopColors => Colors.brown;

  MaterialColor get cardProductColors => Colors.purple;

  MaterialColor get cardTournamentColors => Colors.orange;

  int get gridLength => 1;
}
