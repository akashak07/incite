import 'dart:convert';

import 'package:blog_app/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appColors.dart';
import 'helpers/shared_pref_utils.dart';

//* <------------- App Theme [Theme Manager] ------------->

ValueNotifier<AppModel> appThemeModel = ValueNotifier(AppModel());

toggleDarkMode(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': value,
    'isUserLoggedIn': model.isUserLoggedIn.value
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

toggleSignInOut(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': model.isDarkModeEnabled.value,
    'isUserLoggedIn': value
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

saveDataToSharedPrefs(AppModel model) async {
  SharedPreferences? preferences =
      GetIt.instance<SharedPreferencesUtils>().prefs;
  try {
    preferences?.setString('app_data', json.encode(model.toMap()));
  } catch (e) {}
}

getDataFromSharedPrefs() async {
  SharedPreferences? sharedPreferences =
      GetIt.instance<SharedPreferencesUtils>().prefs;
  print(
      "sharedPreferences.containsKey('app_data') ${sharedPreferences!.containsKey('app_data')}");
  if (sharedPreferences.containsKey('app_data')) {
    AppModel model = AppModel.fromMap(
        json.decode(sharedPreferences.getString('app_data').toString()));
    appThemeModel.value = model;
  } else {
    // initializing app_data in sharedPreferences with default values
    saveDataToSharedPrefs(AppModel());
  }
}

//* ThemeData according to brightness i.e Dark or Light mode

ThemeData getLightThemeData() {
  return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      primaryColor: appMainColor,
      brightness: Brightness.light,
      primaryIconTheme: const IconThemeData(color: Colors.black),
      textTheme: getLightTextTheme(),
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: appMainColor, brightness: Brightness.light));
}

ThemeData getDarkThemeData() {
  return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      primaryColor: appMainColor,
      brightness: Brightness.dark,
      primaryIconTheme: const IconThemeData(color: Colors.white),
      textTheme: getDarkTextTheme(),
      colorScheme: ColorScheme.fromSwatch()
          .copyWith(secondary: appMainColor, brightness: Brightness.dark));
}

//* Text Themes according to brightness i.e Dark or Light mode

TextTheme getLightTextTheme() {
  return TextTheme(
    headline1: GoogleFonts.notoSans(fontSize: 30, color: Colors.grey),
    headline2: GoogleFonts.openSans(
        fontSize: 28, color: Colors.black, fontWeight: FontWeight.w700),
    headline3: GoogleFonts.ubuntu(color: Colors.white, fontSize: 17),
    headline4: GoogleFonts.ubuntu(fontSize: 12, color: Colors.white),
    headline6: GoogleFonts.ubuntu(fontSize: 14, color: Colors.black),
    subtitle1: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 12),
    bodyText1: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 15),
    bodyText2: GoogleFonts.ubuntu(fontSize: 25, color: Colors.white),
  );
}

TextTheme getDarkTextTheme() {
  return TextTheme(
      headline1: GoogleFonts.notoSans(fontSize: 30, color: Colors.grey),
      headline2: GoogleFonts.openSans(
          fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700),
      headline3: GoogleFonts.ubuntu(color: Colors.white, fontSize: 17),
      headline4: GoogleFonts.ubuntu(fontSize: 12, color: Colors.white),
      headline6: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white),
      subtitle1: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 12),
      bodyText1: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 15),
      bodyText2: GoogleFonts.ubuntu(fontSize: 25, color: Colors.white));
}
