
import 'package:flutter/material.dart';

class ColorManager {
  //// light
  static Color primary = const Color(0xff5E75A1);
  static Color darkGrey = HexColor.fromHex("#525252");
  static Color grey = HexColor.fromHex("#737477");
  static Color lightGrey = HexColor.fromHex("#9E9E9E");
  static Color primaryOpacity70 = const Color(0xff5E75A1).withOpacity(0.70);

  //// dark
  static Color darkPrimary = HexColor.fromHex("#d17d11");
  static Color grey1 = HexColor.fromHex("#707070" );
  static Color grey2 = HexColor.fromHex("#797979" );
  static Color white = HexColor. fromHex("#FFFFFF");
  static Color black = HexColor. fromHex("#000000");
  static Color error = HexColor. fromHex("#e61f34");

  static Color background = const Color(0xfff6f6f6);
  static Color appBarBackground = const Color(0xff5E75A1);
  static Color card = const Color(0xff5FC8D9);
}

extension HexColor on Color {
  static Color fromHex(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.replaceAll('#', '');
    }
    if (hex.length == 6) {
      hex = "FF$hex"; // 8 char with opacity 100%
    }
    return Color(int.parse(hex, radix: 16));
  }
}