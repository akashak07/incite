// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/language.dart';
import 'package:blog_app/models/messages.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/app_provider.dart';
import 'SwipeablePage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _userLog = false;
  UserController userController = UserController();

  @override
  void initState() {
    // prefs!.remove("defalut_language");
    super.initState();
    sharedValues();
  }

  void sharedValues() async {
    try {
      SharedPreferences? prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
      if (prefs!.containsKey('isUserLoggedIn')) {
        _userLog = true;
      } else {
        _userLog = false;
      }
      await userController.getAllAvialbleLanguages(context);
      print("prefs.containsKey() ${prefs.containsKey("defalut_language")}");
      if (prefs.containsKey("defalut_language")) {
        print("defalut_language ${prefs.containsKey("defalut_language")}");
        String lng = prefs.getString("defalut_language").toString();
        String localData = prefs.getString("local_data").toString();
        print("lng $lng");
        print("allMessages $localData");
        allMessages.value = Messages.fromJson(json.decode(localData));
        languageCode.value = Language.fromJson(json.decode(lng));
        await userController.getCMS(context,
            lng: languageCode.value.language.toString());
        // Provider.of<AppProvider>(context, listen: false)
        //   ..getBlogData()
        //   ..getCategory();
      } else {
        if (currentUser.value.name != null) {
          for (var element in allLanguages) {
            if (element.name == currentUser.value.langCode) {
              languageCode.value = Language(
                language: element.language,
                name: element.name,
              );
            }
          }
        }
        await userController.getLanguageFromServer(context);
      }
      await getLatestBlog();
      print("is user login $_userLog ${currentUser.value.name}");
      if (_userLog) {
        Provider.of<AppProvider>(context, listen: false)
          ..getBlogData()
          ..getCategory();
        print("user is login");
        Navigator.pushNamedAndRemoveUntil(
            context, '/MainPage', (Route<dynamic> route) => false);
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const SwipeablePage(
                0,
                isFromFeed: true,
              );
            }),
          );
        });
      } else {
        if (!prefs.containsKey("defalut_language")) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/LanguageSelection',
              arguments: false);
        } else {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/AuthPage');
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      blogListHolder.clearList();
      var url = "${Urls.baseUrl}getFeed/${currentUser.value.id}";
      print(url);
      var result = await http.get(
        Uri.parse(url),
      );
      try {
        Map data = json.decode(result.body);
        final list = Blog.fromJson(data['data']);
        blogListHolder.setList(list);
        blogListHolder.setIndex(0);
        BotToast.showText(
            text: "getLatestBlog",
            textStyle: const TextStyle(color: Colors.transparent),
            backgroundColor: Colors.transparent,
            contentColor: Colors.transparent);
        // await Future.delayed(const Duration(microseconds: 500));
      } catch (e) {
        BotToast.showText(text: "getLatestBlog set data --->>> $e");
        print(e);
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(
            'assets/img/user.png',
            height: 90,
            width: 90,
          ),
        ),
      ),
    );
  }
}
