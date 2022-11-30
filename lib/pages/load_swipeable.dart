import 'dart:convert';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;
import 'package:blog_app/models/setting.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/controllers/user_controller.dart';

import '../appColors.dart';

SharedPreferences? prefs;
//* <--------- Authentication page [Login, SignUp , ForgotPassword] ------------>

class LoadSwipePage extends StatefulWidget {
  bool isFromCategories;
  LoadSwipePage({this.isFromCategories=false});

  @override
  _LoadSwipePageState createState() => _LoadSwipePageState();
}

class _LoadSwipePageState extends State<LoadSwipePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController? userController;
  final FacebookLogin facebookSignIn = FacebookLogin();
  var height, width;
  bool _isLoading = false;
  Future<Setting>? settingList;
  String? appName;
  String? appImage;
  String? appSubtitle;
  Future<Setting>? futureAlbum;
  Blog? blogList;
  Users user = new Users();

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: appMainColor,
        textColor: Colors.white);
  }

  Future getLatestBlog() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return SwipeablePage(0);
        }),
      ).then((value) {
        blogListHolder.clearList();
        blogListHolder.setList(blogList!);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getLatestBlog();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      body: LoadingOverlay(
        isLoading: true,
        child: Container(
          height: height,
          width: width,
          color: Colors.transparent,

        ),
      ),
    );
  }
}
