import 'package:abg_utils/abg_utils.dart';
import 'package:flutter/material.dart';

AppTheme theme = AppTheme(false);

Color mainColorGray = Color(0xfffafafa);

late Decoration decor;
late Decoration decorMainColor;

class AppTheme implements DefaultTheme{

  @override
  Color blackColorTitleBkg = Color(0xff202020);

  @override
  bool darkMode = false;

  @override
  Color mainColor = Colors.orange;

  @override
  double radius = 8;

  Color providerStarColor = Color(0xFFFFA726);
  Color serviceStarColor = Color(0xFFFFA726);
  Color categoryStarColor = const Color(0xFFFFA726);

  AppTheme(bool _dartMode,){
    darkMode = _dartMode;
    mainColor = localSettings.mainColor;
    double _fontSizePlus = 0;
    if (localSettings.fontSizePlus != 0)
      _fontSizePlus = localSettings.fontSizePlus-14;

    style10W400 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 10+_fontSizePlus, fontWeight: FontWeight.w400, color: (darkMode) ? Colors.white : Colors.black);
    style10W400White = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 10+_fontSizePlus, fontWeight: FontWeight.w400, color: Colors.white);
    style10W800White = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 10+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);
    style10W600Grey = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 10+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.grey);
    style11W600Grey = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.grey);
    style11W600 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w600, color: (darkMode) ? Colors.white : Colors.black);
    style11W800 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w800, color: (darkMode) ? Colors.white : Colors.black);
    style11W800MainColor = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w800, color: mainColor);
    style11W400MainColor = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w400, color: mainColor);
    style11W800W = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 11+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);
    style12W600Red = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w400, color: Colors.red);
    style12W400D = TextStyle(fontFamily: _font, letterSpacing: 0.4, decoration: TextDecoration.lineThrough,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w400, color: Colors.grey);
    style12W400 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w400, color: (darkMode) ? Colors.white : Colors.black);
    style12W600Stars = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: providerStarColor);
    style12W800MainColor = TextStyle(fontFamily: _font, letterSpacing: 0.6,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w800, color: mainColor);
    style12W800 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w800, color: (darkMode) ? Colors.white : Colors.black);
    style12W600StarsService = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: serviceStarColor);
    style12W600StarsCategory = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: categoryStarColor);
    style12W600Grey = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.grey);
    style12W600Orange = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.orange);
    style12W600White = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.white);
    style12W800W = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 12+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);
    style13W800Red = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 13+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.red);
    style13W800Blue = TextStyle(fontFamily: _font, letterSpacing: 0.6,
        fontSize: 13+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.blue);
    style13W400 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 13+_fontSizePlus, fontWeight: FontWeight.w400, color: (darkMode) ? Colors.white : Colors.black);
    style13W800 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 13+_fontSizePlus, fontWeight: FontWeight.w800, color: (darkMode) ? Colors.white : Colors.black);
    style14W800MainColor = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w800, color: mainColor);
    style14W400Grey = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w400, color: Colors.grey);
    style14W400 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w400, color: (darkMode) ? Colors.white : Colors.black);
    style14W800 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w800, color: (darkMode) ? Colors.white : Colors.black);
    style14W600Grey = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.grey);
    style14W800W = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 14+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);
    style14W600White = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w600, color: Colors.white);
    style16W800Orange = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.orange);
    style16W800White = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);
    style16W800 = TextStyle(fontFamily: _font, letterSpacing: 0.5,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w800, color: (darkMode) ? Colors.white : Colors.black);
    style16W800Green = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.green);
    style16W400U = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 16+_fontSizePlus, fontWeight: FontWeight.w400,
        decoration: TextDecoration.lineThrough,
        color: (darkMode) ? Colors.white : Colors.black);
    style20W800Red = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 20+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.red);
    style20W800Green = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 20+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.green);
    style25W400 = TextStyle(fontFamily: _font, letterSpacing: 0.4,
        fontSize: 25+_fontSizePlus, fontWeight: FontWeight.w400, color: (darkMode) ? Colors.white : Colors.black);
    style30W800White = TextStyle(fontFamily: _font, letterSpacing: 0.6,
        fontSize: 30+_fontSizePlus, fontWeight: FontWeight.w800, color: Colors.white);

    decor = BoxDecoration(
      color: (darkMode) ? blackColorTitleBkg: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.grey.withAlpha(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(1, 1),
        ),
      ],
    );

    decorMainColor = BoxDecoration(
      color: mainColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.grey.withAlpha(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(1, 1),
        ),
      ],
    );

    lightScheme = ColorScheme.fromSeed(seedColor: mainColor);
    darkScheme = ColorScheme.fromSeed(seedColor: mainColor, brightness: Brightness.dark);

    aTheme = this;
  }

  static final String _font = "Montserrat";

  @override
  late TextStyle style10W400White;
  late TextStyle style10W600Grey;
  @override
  late TextStyle style10W800White;
  @override
  late TextStyle style10W400;
  @override
  late TextStyle style11W600;
  late TextStyle style11W600Grey;
  late TextStyle style11W800;
  late TextStyle style11W400MainColor;
  late TextStyle style11W800MainColor;
  @override
  late TextStyle style11W800W;
  late TextStyle style12W600Red;
  @override
  late TextStyle style12W600Grey;
  @override
  late TextStyle style12W600Orange;
  @override
  late TextStyle style12W800MainColor;
  late TextStyle style12W600Stars;
  late TextStyle style12W600StarsService;
  late TextStyle style12W600StarsCategory;
  @override
  late TextStyle style12W400;
  @override
  late TextStyle style12W400D;
  @override
  late TextStyle style12W600White;
  @override
  late TextStyle style12W800;
  @override
  late TextStyle style12W800W;
  @override
  late TextStyle style13W400;
  @override
  late TextStyle style13W800;
  @override
  late TextStyle style13W800Red;
  @override
  late TextStyle style13W800Blue;
  @override
  late TextStyle style14W800MainColor;
  late TextStyle style14W800W;
  @override
  late TextStyle style14W600White;
  @override
  late TextStyle style14W400;
  @override
  late TextStyle style14W400Grey;
  @override
  late TextStyle style14W800;
  late TextStyle style14W600Grey;
  @override
  late TextStyle style16W800;
  @override
  late TextStyle style16W400U;
  @override
  late TextStyle style16W800White;
  @override
  late TextStyle style16W800Green;
  @override
  late TextStyle style16W800Orange;
  late TextStyle style20W800Red;
  late TextStyle style20W800Green;
  late TextStyle style25W400;

  @override
  late TextStyle style30W800White;

  late ColorScheme lightScheme;
  late ColorScheme darkScheme;

  @override
  late Color backgroundColor;

  @override
  late Color secondColor;

  @override
  late TextStyle style13W400U;
}
