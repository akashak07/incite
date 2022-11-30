import 'dart:convert';
import 'dart:io';

import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../appColors.dart';
import '../app_theme.dart';
import 'category_post.dart';
import 'change_password.dart';

SharedPreferences? prefs;
Dio dio = new Dio();

//* <--------- User Profile [Personal details of current user] ------------>

class UserProfile extends StatefulWidget {
  final bool useHeroWidget;

  UserProfile(this.useHeroWidget);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File? _image;
  FormData formdata = new FormData();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController? userController;
  var height, width;

  final picker = ImagePicker();

  bool _isLoading = false;
  bool _isFound = true;

  @override
  void initState() {
    currentUser.value.isPageHome = false;
    intializeshared();
    userController = UserController();
    getCurrentUser();
    super.initState();
  }

  Future getImage() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _isLoading = true;
        } else {}
      });
      var stream = http.ByteStream(_image!.openRead());
      stream.cast();
      var length = await _image!.length();
      var uri = Uri.parse("${Urls.baseUrl}updateProfilePicture");
      var request = http.MultipartRequest("POST", uri);
      request.fields["id"] = currentUser.value.id.toString();
      // ignore: unnecessary_new
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: _image!.path.split('/').last);
      request.files.add(multipartFile);
      await request.send().then((response) async {
        print(response);
        response.stream.transform(utf8.decoder).listen((value) async {
          getCurrentUser();
          await getProfile();
          setState(() {
            currentUser.value.isPageHome = false;
            _isLoading = false;
          });
          Fluttertoast.showToast(
              msg: json.decode(value)['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 5,
              backgroundColor: appMainColor,
              textColor: Colors.white);
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return LoadingOverlay(
      isLoading: _isLoading,
      color: Colors.grey,
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        drawer: DrawerBuilder(),
        onDrawerChanged: (value) {
          if (!value) {
            setState(() {});
          }
        },
        appBar: commonAppBar(context, width: width, isProfile: true),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 20.0),
                  child: Text(
                    currentUser.value.name.toString(),
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 22.0,
                              fontWeight: FontWeight.normal),
                        ),
                  ),
                ),
              ),
              Stack(alignment: Alignment.center, children: <Widget>[
                Container(
                  height: 0.09 * height,
                  color: const Color(0xffff914d),
                ),
                Container(
                  height: 0.18 * height,
                  width: 0.18 * height,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: (currentUser.value.photo != null &&
                          currentUser.value.photo != '')
                      ? FullScreenWidget(
                          backgroundColor: Colors.transparent,
                          child: Hero(
                            tag: widget.useHeroWidget ? 'photo' : "",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                currentUser.value.photo,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/img/user.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                ),
              ]),
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      allMessages.value.eDIT.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 0.04 * height,
              ),
              _buildTextFields(),
              SizedBox(
                height: 0.015 * height,
              ),
              _buildEndButton(),
              const SizedBox(
                height: 10,
              ),
              if (currentUser.value.loginFrom == 'email')
                _buildChangeButton(context),
              SizedBox(
                height: 0.03 * height,
              ),
              // if (currentUser.value.loginFrom == 'email')
              Center(
                child: GestureDetector(
                  onTap: () {
                    _exitApp(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: Text(
                      allMessages.value.deleteAccount.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color: Colors.red[300],
                                decoration: TextDecoration.underline,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController!.updateFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: appMainColor, primaryColorDark: appMainColor),
              child: TextFormField(
                initialValue: currentUser.value.name != null
                    ? currentUser.value.name
                    : '',
                onSaved: (input) {
                  setState(() {
                    userController!.user!.name = input;
                  });
                },
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 30.0),
                    child: Text(
                      allMessages.value.name.toString(),
                      style: Theme.of(this.context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.name,
                  contentPadding:
                      const EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1?.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: Colors.green, primaryColorDark: appMainColor),
              child: TextFormField(
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
                initialValue: currentUser.value.email != null
                    ? currentUser.value.email
                    : '',
                onSaved: (input) {
                  print(input);
                  if (input != null) {
                    userController!.user!.email = input;
                  } else {
                    userController!.user!.email = currentUser.value.email;
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 30.0),
                    child: Text(
                      allMessages.value.email.toString(),
                      style: Theme.of(this.context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.email,
                  contentPadding:
                      const EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1?.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: Theme.of(this.context).copyWith(
                  primaryColor: appMainColor, primaryColorDark: appMainColor),
              child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: currentUser.value.phone != null
                    ? currentUser.value.phone
                    : '',
                onSaved: (input) {
                  if (input != null) {
                    userController!.user!.phone = input;
                  } else {
                    userController!.user!.phone = currentUser.value.phone;
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 30.0),
                    child: Text(
                      allMessages.value.mobile.toString(),
                      style: Theme.of(this.context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                  hintText: allMessages.value.mobile,
                  contentPadding:
                      const EdgeInsets.only(left: 15.0, right: 20.0),
                  hintStyle: Theme.of(this.context).textTheme.bodyText1?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                style: Theme.of(this.context).textTheme.bodyText1?.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ),
          if (currentUser.value.password != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Theme(
                data: Theme.of(this.context).copyWith(
                    primaryColor: appMainColor, primaryColorDark: appMainColor),
                child: TextFormField(
                  initialValue: currentUser.value.password != null
                      ? currentUser.value.password
                      : '',
                  obscureText: userController!.hidePassword ?? false,
                  onSaved: (input) {
                    setState(() {
                      userController!.user!.password = input;
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14.0, right: 30.0),
                      child: Text(
                        allMessages.value.password.toString(),
                        style:
                            Theme.of(this.context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Montserrat',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal),
                                ),
                      ),
                    ),
                    hintText: allMessages.value.password,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController!.hidePassword =
                              !(userController!.hidePassword ?? false);
                        });
                      },
                      color: Theme.of(this.context).focusColor,
                      icon: Icon(userController!.hidePassword ?? false
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 15.0, right: 20.0),
                    hintStyle: Theme.of(this.context)
                        .textTheme
                        .bodyText1
                        ?.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'Montserrat',
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal),
                        ),
                  ),
                  style: Theme.of(this.context).textTheme.bodyText1?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Object _exitApp(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          allMessages.value.deleteAccount.toString(),
          style: const TextStyle(color: Colors.black),
        ),
        content: Text(allMessages.value.confirmDeleteAccount.toString()),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              print("you choose no");
              Navigator.of(context).pop(false);
            },
            child: Text(allMessages.value.no.toString()),
          ),
          TextButton(
            onPressed: () {
              deleteAccount();
            },
            child: Text(allMessages.value.yes.toString()),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _isLoading = true;
      final msg = jsonEncode({"id": currentUser.value.id});
      final String url = '${Urls.baseUrl}deleteAccount';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map data = json.decode(response.body);
      _isLoading = false;
      if (data['status'] == true) {
        _isFound = true;
        SharedPreferences? prefs =
            GetIt.instance<SharedPreferencesUtils>().prefs;
        await prefs!.remove('current_user');
        await prefs.setBool("isUserLoggedIn", false);
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(this.context)
            .pushNamedAndRemoveUntil('/AuthPage', (route) => false);
      } else {
        _isFound = false;
      }
    }
  }

  void intializeshared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
  }

  _buildEndButton() {
    return ButtonTheme(
      minWidth: 0.5 * width,
      height: 0.057 * height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffff914d),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onPressed: () {
          setState(() {
            userController!.profile(context);
          });
        },
        child: Text(
          allMessages.value.updateProfile.toString(),
          style: Theme.of(this.context).textTheme.bodyText1?.merge(
                const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
      ),
    );
  }

  _buildChangeButton(BuildContext context) {
    return ButtonTheme(
      minWidth: 0.5 * width,
      height: 0.057 * height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffff914d),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const ChangePassword();
            },
          ));
        },
        child: Text(
          "Change Password",
          style: Theme.of(this.context).textTheme.bodyText1?.merge(
                const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
      ),
    );
  }
}
