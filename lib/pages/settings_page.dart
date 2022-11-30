import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blog_app/appColors.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mdi/mdi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../app_theme.dart';
import '../helpers/network_helper.dart';
import '../helpers/shared_pref_utils.dart';
import '../helpers/urls.dart';
import 'cms_detail.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var notificationValue = true;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            color: !appThemeModel.value.isDarkModeEnabled.value
                ? HexColor("#ffffff")
                : Theme.of(context).cardColor,
            height: height,
            width: width,
            padding: EdgeInsets.only(top: height * 0.05, left: 08, right: 08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appMainColor,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).cardColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      allMessages.value.settingsPage ?? 'Settings page',
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color: appMainColor,
                                fontFamily: 'Montserrat',
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold),
                          ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 5,
                  color: appMainColor,
                ),
                const SizedBox(
                  height: 15,
                ),
                currentUser.value.name != null
                    ? _buildNotificationSwitch(context)
                    : Container(),
                const Divider(
                  thickness: 2,
                ),
                _buildDarkModeSwitch(context),
                const Divider(
                  thickness: 2,
                ),
                // currentUser.value.name != null
                //     ? const Divider(
                //         thickness: 2,
                //       )
                //     : Container(),
                _buildLanguageSelection(context),
                const Divider(
                  thickness: 2,
                ),
                getFontManager(context),
                Divider(
                  thickness: 2,
                  endIndent: width * 0.06,
                  indent: width * 0.06,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 10.0, top: 10, bottom: 10),
                  child: Center(
                    child: Text(
                      allMessages.value.blogFontSize ?? 'Blog font Size',
                      overflow: TextOverflow.ellipsis,
                      maxLines: currentUser.value.id != null
                          ? height ~/ 60
                          : height ~/ 50,
                      style: TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : Colors.black,
                        fontSize: defaultFontSize.value != null
                            ? defaultFontSize.value.toDouble()
                            : 16,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: allCMS.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Row(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                                //   child: Icon(
                                //     Mdi.arrowBottomRight,
                                //     size: 25.0,
                                //     color: appThemeModel.value.isDarkModeEnabled.value
                                //         ? Colors.white
                                //         : HexColor("#000000"),
                                //     //color: Colors.black,
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25.0),
                                  child: Text(
                                    allCMS[index].pageTitle.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.merge(
                                          TextStyle(
                                              color: appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : HexColor("#000000"),
                                              fontFamily: 'Montserrat',
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Cmsdetail(allCMS[index]),
                                ));
                          },
                        ),
                        if (false &&
                            allCMS.length - 1 == index &&
                            currentUser.value.loginFrom == 'email')
                          GestureDetector(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8, top: 8),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: Text(
                                      allMessages.value.deleteAccount
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.merge(
                                            TextStyle(
                                                color: Colors.red[300],
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: 'Montserrat',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              _exitApp(context);
                            },
                          ),
                        if (allCMS.length - 1 == index) const Divider(),
                      ],
                    );
                  },
                ),
              ],
            )));
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

  bool _isLoading = false;
  bool _isFound = true;

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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/AuthPage', (route) => false);
      } else {
        _isFound = false;
      }
    }
  }

  _buildNotificationSwitch(maincontext) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Icon(
                        Mdi.bell,
                        size: 27.0,
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        //color: Colors.black,
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allMessages.value.notifications.toString(),
                            style: Theme.of(maincontext)
                                .textTheme
                                .bodyText1
                                ?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      fontFamily: 'Montserrat',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          AutoSizeText(
                            allMessages.value.enableDisablePushNotification ??
                                'Enable/ disable push notification',
                            style: Theme.of(maincontext)
                                .textTheme
                                .bodyText1
                                ?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white.withOpacity(0.5)
                                          : HexColor("#000000")
                                              .withOpacity(0.5),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600),
                                ),
                            maxLines: 1,
                            minFontSize: 12,
                            maxFontSize: 16,
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 20,
              child: Switch(
                activeColor: appMainColor,
                onChanged: (v) {},
                value: notificationValue,
              ),
            )
          ],
        ),
        //? To add clickable to whole tab
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                notificationValue = !notificationValue;
              });
            },
          ),
        )),
      ],
    );
  }

  getFontManager(BuildContext maincontext) {
    return ValueListenableBuilder<int>(
        valueListenable: defaultFontSize,
        builder: (context, fontSize, child) {
          return GestureDetector(
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                    child: Icon(
                      Mdi.formatSize,
                      size: 27.0,
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : HexColor("#000000"),
                      //color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allMessages.value.fontSize.toString(),
                          style:
                              Theme.of(maincontext).textTheme.bodyText1?.merge(
                                    TextStyle(
                                        color: appThemeModel
                                                .value.isDarkModeEnabled.value
                                            ? Colors.white
                                            : HexColor("#000000"),
                                        fontFamily: 'Montserrat',
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                          //style: Theme.of(context).textTheme.headline6,
                          //style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          allMessages.value.setYourBlogFontSize ??
                              'Set your blog font size',
                          style: Theme.of(maincontext)
                              .textTheme
                              .bodyText1
                              ?.merge(
                                TextStyle(
                                    color: appThemeModel
                                            .value.isDarkModeEnabled.value
                                        ? Colors.white.withOpacity(0.5)
                                        : HexColor("#000000").withOpacity(0.5),
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (defaultFontSize.value <= 21) {
                        defaultFontSize.value++;
                        setCurrentFontSize();
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appMainColor,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(defaultFontSize.value.toString(),
                      style: Theme.of(maincontext).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                                fontFamily: 'Montserrat',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          )),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (defaultFontSize.value >= 15) {
                        defaultFontSize.value--;
                        setCurrentFontSize();
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: appMainColor),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            onTap: () {
              // Navigator.of(maincontext)
              //     .pushNamed('/AuthPage', arguments: false);
            },
          );
        });
  }

  void setCurrentFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('fontSize');
    prefs.setInt('fontSize', defaultFontSize.value);
  }

  _buildLanguageSelection(BuildContext maincontext) {
    print("allLanguages ${allLanguages.length}");
    return GestureDetector(
      onTap: () async {
        final data = await Navigator.of(maincontext)
            .pushNamed('/LanguageSelection', arguments: true);
        print("data $data");
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: !appThemeModel.value.isDarkModeEnabled.value
            ? HexColor("#ffffff")
            : Theme.of(context).cardColor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 10.0),
              child: Icon(
                Mdi.flag,
                size: 27.0,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : HexColor("#000000"),
                //color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allMessages.value.selectLanguage ?? "Select language",
                    style: Theme.of(maincontext).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : HexColor("#000000"),
                              fontFamily: 'Montserrat',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    allMessages.value.chooseYourAppLanguage ??
                        'Choose your app language',
                    style: Theme.of(maincontext).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white.withOpacity(0.5)
                                  : HexColor("#000000").withOpacity(0.5),
                              fontFamily: 'Montserrat',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildDarkModeSwitch(maincontext) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Icon(
                        Mdi.moonWaningCrescent,
                        size: 27.0,
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allMessages.value.darkMode.toString(),
                            style: Theme.of(maincontext)
                                .textTheme
                                .bodyText1
                                ?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      fontFamily: 'Montserrat',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            allMessages.value.enableDisableDarkMode ??
                                'Enable/ disable dark mode',
                            style: Theme.of(maincontext)
                                .textTheme
                                .bodyText1
                                ?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white.withOpacity(0.5)
                                          : HexColor("#000000")
                                              .withOpacity(0.5),
                                      fontFamily: 'Montserrat',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 20,
              child: Switch(
                activeColor: appMainColor,
                onChanged: (v) {},
                value: appThemeModel.value.isDarkModeEnabled.value,
              ),
            )
          ],
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
            },
          ),
        )),
      ],
    );
  }
}
