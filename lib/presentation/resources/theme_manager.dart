import 'package:flutter/material.dart';
import 'package:my_app/presentation/resources/styles_manager.dart';
import 'package:my_app/presentation/resources/values_manager.dart';

import 'color_manager.dart';
import 'font_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    //// main colors of the app
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.primaryOpacity70,
    primaryColorDark: ColorManager.darkPrimary,
    disabledColor: ColorManager.grey1, // will be used in case of disabled button for example
    colorScheme: ColorScheme.fromSwatch(
      accentColor: ColorManager.grey,
      backgroundColor: ColorManager.background,
    ),
    splashColor: ColorManager.primary.withOpacity(0.2),
    //// card view theme
    cardTheme: CardTheme(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4,
    ),
    //// App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: AppSize.s4,
      // shadowColor: ColorManager.primaryOpacity70,
      titleTextStyle: getRegularStyle(
        color: ColorManager.white,
        fontSize: FontSize.s18,
      ),
      iconTheme: const IconThemeData().copyWith(
        color: ColorManager.white,
      ),
      backgroundColor: ColorManager.appBarBackground,
    ),
    //// Button theme
    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.grey1,
      buttonColor: ColorManager.primary,
      splashColor: ColorManager.primaryOpacity70,
    ),
    //// Elevated theme
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      textStyle: getRegularStyle(color: ColorManager.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s12)),
    )),
    //// Text theme
    textTheme: TextTheme(
      displayLarge: getSemiBoldStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s16,
      ),
      titleMedium: getMediumStyle(color: ColorManager.lightGrey, fontSize: FontSize.s14),
      bodySmall: getRegularStyle(
        color: ColorManager.grey1,
      ),
      bodyLarge: getRegularStyle(
        color: ColorManager.grey,
      ),
    ),
    //// input theme
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        hintStyle: getRegularStyle(color: ColorManager.grey1),
        labelStyle: getMediumStyle(color: ColorManager.darkGrey),
        errorStyle: getRegularStyle(color: ColorManager.error),
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
      ),
    // enabledBorder: OutlineInputBorder(
    //   borderSide: BorderSide(color: ColorManager.grey, width: AppSize.s1_5),
    //   borderRadius: const BorderRadius.all(Radius.circular(AppSize.s1_5)),
    // ),
    // focusedBorder: OutlineInputBorder(
    //   borderSide: BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
    //   borderRadius: const BorderRadius.all(Radius.circular(AppSize.s1_5)),
    // ),
    // errorBorder: OutlineInputBorder(
    //   borderSide: BorderSide(color: ColorManager.error, width: AppSize.s1_5),
    //   borderRadius: const BorderRadius.all(Radius.circular(AppSize.s1_5)),
    // ),
    // focusedErrorBorder: OutlineInputBorder(
    //   borderSide: BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
    //   borderRadius: const BorderRadius.all(Radius.circular(AppSize.s1_5)),
    // ),
    //// font theme
    //// bottom navigation theme
    //// input decoration theme (0|
  );
}
