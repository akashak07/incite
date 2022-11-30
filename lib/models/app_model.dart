import 'package:blog_app/models/user.dart';
import 'package:flutter/material.dart';

class AppModel {
  ValueNotifier<bool> isDarkModeEnabled = ValueNotifier(false);
  ValueNotifier<bool> isUserLoggedIn = ValueNotifier(false);
  AppModel();

  AppModel.fromMap(Map data) {
    print(data);
    isDarkModeEnabled.value = data['isDarkModeEnabled'] as bool;

    isUserLoggedIn.value = data['isUserLoggedIn'] as bool;
  }

  Map toMap() {
    return {
      'isDarkModeEnabled': isDarkModeEnabled.value,
      'isUserLoggedIn': isUserLoggedIn.value,
    };
  }
}
