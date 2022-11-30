import 'dart:convert';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/language.dart';
import 'package:blog_app/models/messages.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  bool _load = false;
  BlogCategory? _blog;
  var _blogList;

  AppProvider() {
    //_getCurrentUser();
    getCategory();
    getBlogData();
  }

  BlogCategory? get blog => _blog;

  Blog get blogList => _blogList ?? [];

  bool get load => _load;
  setLoading({bool? load}) {
    _load = load!;
    notifyListeners();
  }

  changeSelectCategories(Datum item) {
    if (item.isMyFeed) {
      item.isMyFeed = false;
    } else {
      item.isMyFeed = true;
    }
    notifyListeners();
  }

  Future getCategory() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      print('getCategory is called');
      try {
        setLoading(load: true);
        var url = "${Urls.baseUrl}blog-category-list";
        var result = await http.get(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            'userData': currentUser.value.id.toString(),
            "lang-code": languageCode.value.language ?? ''
          },
        );
        Map<String, dynamic> data = json.decode(result.body);
        _blog = BlogCategory.fromMap(data);
        setLoading(load: false);
      } catch (e) {
        setLoading(load: false);
      }
    }
  }

  Future getSettingCategory() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      BotToast.showLoading();
      print('getCategory is called');
      try {
        setLoading(load: true);
        var url = "${Urls.baseUrl}blog-category-list";
        var result = await http.get(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            'userData': currentUser.value.id.toString(),
            "lang-code": languageCode.value.language ?? ''
          },
        );
        Map<String, dynamic> data = json.decode(result.body);
        _blog = BlogCategory.fromMap(data);
        setLoading(load: false);
        BotToast.closeAllLoading();
      } catch (e) {
        setLoading(load: false);
        BotToast.closeAllLoading();
      } finally {
        BotToast.closeAllLoading();
      }
    }
  }

  Future getBlogData() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _blogList = [];
      blogListHolder.clearList();
      try {
        print('getBlogData is called');
        var url = "${Urls.baseUrl}blog-list";
        setLoading(load: true);
        var headers = {
          "Content-Type": "application/json",
          'userData': currentUser.value.id ?? '',
        };
        SharedPreferences? prefs =
            GetIt.instance<SharedPreferencesUtils>().prefs;

        if (languageCode.value.language == null) {
          if (prefs!.containsKey("defalut_language")) {
            String lng = prefs.getString("defalut_language").toString();
            String localData = prefs.getString("local_data").toString();
            allMessages.value = Messages.fromJson(json.decode(localData));
            languageCode.value = Language.fromJson(json.decode(lng));
            headers.addAll({"lang-code": languageCode.value.language ?? ''});
          }
        } else {
          headers.addAll({"lang-code": languageCode.value.language ?? ''});
        }

        print("languageCode.value?.language ${languageCode.value.language}");
        var result = await http.get(Uri.parse(url), headers: headers);
        print('headers are ${result.headers}');
        setLoading(load: false);
        Map data = json.decode(result.body);
        print('data is $data');
        final list = Blog.fromJson(data['data']);
        _blogList = list;
        blogListHolder.clearList();
        blogListHolder.setList(list);
        notifyListeners();
        print('blog list is ${blogList.total}');
        return true;
      } catch (e) {
        BotToast.showText(text: "blog list --->>> $e");
        return false;
        //  setLoading(load: false);
      }
    }
  }
}
