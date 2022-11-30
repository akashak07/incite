import 'dart:convert';

import 'package:blog_app/models/user.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  SharedPreferences? _prefs;
  static SharedPreferencesUtils? _instance;
  static final String kCurrentUser = 'current_user';
  SharedPreferencesUtils._(this._prefs);

  static Future<SharedPreferencesUtils?> getInstance() async {
    if (_instance == null)
      _instance =
          SharedPreferencesUtils._(await SharedPreferences.getInstance());
    return _instance;
  }

  SharedPreferences? get prefs => _prefs;

  getSavedUser() {
    currentUser.value = Users.fromJSON(json.decode(_prefs?.get('current_user').toString() ?? ''));
    currentUser.value.isNewUser = false;
  }
}
