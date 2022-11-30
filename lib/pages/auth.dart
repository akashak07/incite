import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/forgot_password_sheet.dart';
import 'package:blog_app/elements/sign_up_bottom_sheet.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/models/setting.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    as firebase_messaging;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../appColors.dart';
import '../app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../providers/app_provider.dart';

String? eLiveImage;
String? eNewsImage;
String? eLiveKey;
String? eNewsKey;
String? iosBannerId;
String? androidBannerId;
String? iosInterstitialId;
String? androidInterstitialId;
String? enableAds;
SharedPreferences? prefss;
//* <--------- Authentication page [Login, SignUp , ForgotPassword] ------------>

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserController? userController;
  final FacebookLogin facebookSignIn = FacebookLogin();
  FacebookLogin fbAuthManager = FacebookLogin();
  final _firebaseAuth = FirebaseAuth.instance;
  var width, height;
  bool isLoading = false;
  var email, password;

  bool _isLoading = false;
  Future<Setting>? settingList;
  String? appName;
  String? appImage;
  String? appSubtitle;
  final bool _isFacebookLogin = false;
  Future<Setting>? futureAlbum;
  bool _userLog = false;
  Blog blogList = Blog();
  firebase_messaging.FirebaseMessaging? _firebaseMessaging;
  //Users user = new Users();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: appMainColor,
        textColor: Colors.white);
  }

  Future _login() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          allMessages.value.information.toString(),
          style: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
          //style: TextStyle(color: Colors.black),
        ),
        content: Text(
          allMessages.value.facebookLoginNotAvailable.toString(),
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(allMessages.value.ok.toString()),
          ),
        ],
      ),
    );
  }

  Future<AppleIdCredential?> signInWithApple(
      {List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        /*final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );*/
        /* final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (scopes.contains(Scope.fullName)) {
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';

          await firebaseUser.updateProfile(displayName: displayName);
        }
        return firebaseUser;*/
        return appleIdCredential;

      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      print('getLatestBlog is called');
      _isLoading = true;
      var url = "${Urls.baseUrl}blog-all-list";
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "lang-code": languageCode.value.language ?? ''
        },
      );
      Map data = json.decode(result.body);
      final list = Blog.fromJson(data['data']);
      if (mounted) {
        setState(() {
          blogListHolder.clearList();
          blogListHolder.setList(list);
          blogList = list;
          _isLoading = false;
        });
      }
    }
  }

  Future<Users?> _showMessage(token) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      //var device_token;
      var graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,email,picture&access_token=$token'));
      var profile = json.decode(graphResponse.body);
      print("Facebook Response ${graphResponse.body}");
      final msg = jsonEncode({
        "name": profile['name'],
        "email": profile['email'],
        "picture": profile['picture'],
        "fb_token": token,
        "fb_id": profile['id'],
        //"device_token": device_token
      });
      //repository.fblogin();
      final String url = '${Urls.baseUrl}socialMediaLogin';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map dataNew = json.decode(response.body);
      print("Facebook Response ${response.body}");
      setState(() {
        setCurrentUser(response.body);
        currentUser.value = Users.fromJSON(json.decode(response.body)['data']);

        if (currentUser.value.fbToken != null) {
          _firebaseMessaging = firebase_messaging.FirebaseMessaging.instance;
          _firebaseMessaging!.getToken().then((String? deviceToken) {
            print("Device token $deviceToken");
            userController!.user?.deviceToken = deviceToken;
            userController!.updateToken();
          }).catchError((e) {});
          print(currentUser.value.isNewUser);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const SwipeablePage(
              0,
              isFromFeed: true,
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(allMessages.value.wrongEmailAndPassword.toString()),
          ));
        }
      });
    }
    return null;
  }

  Future<void> _logOut() async {
    await facebookSignIn.logOut();
  }

  @override
  void initState() {
    userController = UserController();
    currentUser.value.isPageHome = false;
    super.initState();
    intializeshared();
    futureAlbum = getCurrentUser();
    Provider.of<AppProvider>(context, listen: false)
      ..getBlogData()
      ..getCategory();
  }

  void intializeshared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs!;
    print("User Logged In ${prefs?.containsKey('isUserLoggedIn')}");
    if (prefs!.containsKey('isUserLoggedIn')) {
      _userLog = prefs?.getBool("isUserLoggedIn") ?? false;
    } else {
      _userLog = false;
    }
    if (prefs!.containsKey('app_image')) {
      appImage = prefs?.getString("app_image")!;
      print("appImage $appImage");
    }
  }

  void _skipLogin() async {
    currentUser.value.name = "Guest";
  }

  Future<Setting> getCurrentUser() async {
    prefss = await SharedPreferences.getInstance();

    String url = '${Urls.baseUrl}setting-list';
    http.Response? response;
    print(url);
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      try {
        response = await http.get(Uri.parse(url), headers: {
          "Accept": "application/json",
          "lang-code": languageCode.value.language ?? ''
        });
      } on Exception catch (e) {
        print('------- >>> $e');
      }
    }
    print(response?.body);
    if (response!.statusCode == 200) {
      appImage = json.decode(response.body)['data']['app_image'];
      eLiveImage = json.decode(response.body)['data']['live_news_logo'];
      eNewsImage = json.decode(response.body)['data']['e_paper_logo'];
      eLiveKey = json.decode(response.body)['data']['live_news_status'];
      eNewsKey = json.decode(response.body)['data']['e_paper_status'];
      androidBannerId =
          json.decode(response.body)['data']['admob_banner_id_android'];
      androidInterstitialId =
          json.decode(response.body)['data']['admob_interstitial_id_android'];
      iosBannerId = json.decode(response.body)['data']['admob_banner_id_ios'];
      iosInterstitialId =
          json.decode(response.body)['data']['admob_interstitial_id_ios'];
      enableAds = json.decode(response.body)['data']['enable_ads'];
      prefss!.setString("app_image", appImage!);
      appName = json.decode(response.body)['data']['app_name'];
      appSubtitle = json.decode(response.body)['data']['app_subtitle'];
      var setList = Setting.fromJSON(json.decode(response.body)['data']);
      print(setList);
      return setList;
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      //key: userController.loginFormKey,
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: height,
        width: width,
        child: buildBody(),
      ),
    );
  }

  buildBody() {
    return FutureBuilder(
      future: getCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Stack(
          children: <Widget>[
            /*
            Positioned.fill(
              child: appImage != null
                  ? CachedNetworkImage(
                      imageUrl: appImage,
                      fit: BoxFit.cover,
                      cacheKey: appImage,
                      useOldImageOnUrlChange: false,
                    )
                  : Container(),
            ),
             Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 55.0),
              child: Text(
                appName ?? "",
                style: Theme.of(context).textTheme.bodyText1.merge(
                      TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
              ),
            ),*/

            Positioned(
              bottom: 0.14 * height,
              left: 0,
              right: 0,
              child: getBottomButtons(),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 40.0, right: 20.0),
              child: Opacity(
                opacity: 0.6,
                child: ButtonTheme(
                  minWidth: 0.02 * width,
                  height: 0.04 * height,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.only(
                        right: 9,
                        left: 9,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/MainPage',
                          (Route<dynamic> route) => false);
                    },
                    child: Text(
                      allMessages.value.skip?.toUpperCase() ?? "",
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  getBottomButtons() {
    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          // ButtonTheme(
          //   minWidth: 0.62 * width,
          //   height: 0.075 * height,
          //   child: RaisedButton(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     onPressed: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => SignInBottomSheet(scaffoldKey),));
          //       // showModalBottomSheet(
          //       //   isScrollControlled: true,
          //       //   backgroundColor: Colors.transparent,
          //       //   context: context,
          //       //   builder: (context) {
          //       //     return SignInBottomSheet(scaffoldKey);
          //       //   },
          //       // );
          //     },
          //     color: Theme.of(context).cardColor,
          //     child: Text(
          //       allMessages.value?.signIn?.toUpperCase() ?? "",
          //       style: Theme.of(context)
          //           .textTheme
          //           .headline6
          //           .copyWith(fontSize: 17),
          //     ),
          //   ),
          // ),
          Container(
            // height: height,
            // width: width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
            ),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  allMessages.value.signIn.toString(),
                  style: Theme.of(context).textTheme.headline3?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : appMainColor,
                            fontFamily: 'Montserrat',
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                _buildTextFields(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ForgotPasswordSheet(scaffoldKey),
                          ));
                      // showModalBottomSheet(
                      //     context: context,
                      //     backgroundColor: Colors.transparent,
                      //     isScrollControlled: true,
                      //     builder: (context) =>
                      //         ForgotPasswordSheet(widget.scaffoldKey));
                    },
                    child: Text(
                      allMessages.value.forgotPassword.toString(),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
                _buildSignInButton(context),
                _buildNewUserRichText(),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInBottomSheet(scaffoldKey),)),
          //   child: Container(
          //     width: (MediaQuery.of(context).size.width * 0.62),
          //     height: (MediaQuery.of(context).size.height * 0.07),
          //     decoration: BoxDecoration(
          //         color: appMainColor,
          //         borderRadius: BorderRadius.circular(10)
          //     ),
          //     child: Center(
          //       child: Text("Sing in",
          //         style: Theme.of(context)
          //             .textTheme
          //             .headline6
          //             .copyWith(fontSize: 24),
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 20.0,
          ),
          !_isFacebookLogin
              ? GestureDetector(
                  onTap: () => userController?.facebookLogin(context),
                  child: Container(
                    width: (MediaQuery.of(context).size.width * 0.62),
                    height: (MediaQuery.of(context).size.height * 0.07),
                    decoration: BoxDecoration(
                      color: const Color(0xFF345995),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38.withOpacity(0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 5.0),
                            spreadRadius: 2.0)
                      ],
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "assets/img/facebook.png",
                            fit: BoxFit.fitHeight,
                            height: (MediaQuery.of(context).size.height * 0.05),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          AutoSizeText(
                            "Sign in with Facebook",
                            style: Theme.of(context).textTheme.headline3,
                            maxLines: 1,
                            minFontSize: 12,
                            maxFontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.6,
                    child: ButtonTheme(
                      height: 0.075 * height,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                              '/HomeClonePage',
                              arguments: false);
                        },
                        child: Text(
                          allMessages.value.updatingFeed.toString(),
                          style: Theme.of(context).textTheme.bodyText1?.merge(
                                const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),

          Platform.isIOS
              ? const SizedBox(
                  height: 20.0,
                )
              : const SizedBox.shrink(),
          Platform.isIOS
              ? GestureDetector(
                  onTap: () => userController?.appleLogin(context),
                  child: Container(
                    width: (MediaQuery.of(context).size.width * 0.62),
                    height: (MediaQuery.of(context).size.height * 0.07),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38.withOpacity(0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 5.0),
                            spreadRadius: 2.0)
                      ],
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            child: Image.asset(
                              "assets/img/apple.png",
                              color: Colors.white,
                              fit: BoxFit.fitHeight,
                              height:
                                  (MediaQuery.of(context).size.height * 0.040),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          AutoSizeText(
                            "Sign up with Apple",
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(color: Colors.white),
                            maxLines: 1,
                            minFontSize: 12,
                            maxFontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),

          const SizedBox(
            height: 20.0,
          ),
          GestureDetector(
            onTap: () => userController?.googleLogin(context),
            child: Container(
              width: (MediaQuery.of(context).size.width * 0.62),
              height: (MediaQuery.of(context).size.height * 0.07),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38.withOpacity(0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 5.0),
                      spreadRadius: 2.0)
                ],
              ),
              child: Center(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                    ),
                    Image.asset(
                      "assets/img/google.png",
                      fit: BoxFit.fitHeight,
                      height: (MediaQuery.of(context).size.height * 0.045),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    AutoSizeText(
                      "Sign in with Google",
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(color: Colors.black),
                      maxLines: 1,
                      minFontSize: 12,
                      maxFontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future signOut() async {
    final facebookLogin = FacebookLogin();

    await firebaseAuth.signOut().then((value) {
      setState(() {
        facebookLogin.logOut();
        //  isLogin = false;
      });
    });
  }

  _buildTextFields() {
    return Form(
      key: userController?.loginFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) {
                    return allMessages.value.enterAValidEmail;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController?.user?.email = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Mdi.account),
                    hintText: allMessages.value.email,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v!.length < 3) {
                    return allMessages
                        .value.passwordShouldBeMoreThanThereeCharacter;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController?.user?.password = v;
                  });
                },
                obscureText: userController?.hidePassword ?? false,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Mdi.key),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController?.hidePassword =
                              !(userController?.hidePassword ?? false);
                        });
                      },
                      color: Theme.of(context).focusColor,
                      icon: Icon(userController?.hidePassword ?? false
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: allMessages.value.password,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
        ],
      ),
    );
  }

  _buildSignInButton(BuildContext context) {
    return Center(
      child: ButtonTheme(
        minWidth: 0.85 * width,
        height: 0.075 * height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appMainColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
          child: Text(
            allMessages.value.signIn.toString(),
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            setState(() {
              FocusScope.of(context).unfocus();
              isLoading = true;
            });
            userController?.login(context);
          },
        ),
      ),
    );
  }

  _buildNewUserRichText() {
    return Center(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUpBottomSheet(scaffoldKey),
                ));
            // showModalBottomSheet(
            //     isScrollControlled: true,
            //     backgroundColor: Colors.transparent,
            //     context: context,
            //     builder: (context) {
            //       return SignUpBottomSheet(widget.scaffoldKey);
            //     });
          },
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: allMessages.value.newUser,
                  style: Theme.of(context).textTheme.headline6),
              TextSpan(
                  text: ' ${allMessages.value.signUp}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: appMainColor))
            ]),
          ),
        ),
      ),
    );
  }
}

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await TheAppleSignIn.isAvailable());
  }
}
