import 'dart:convert';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:blog_app/elements/bottom_card_item_saved.dart';
import '../app_theme.dart';
import 'category_post.dart';

//* <----------- Search Blog Page -------------->

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  TextEditingController? searchController;
  List<DataModel> blogList = [];
  bool _isLoading = false;
  var width;
  String? localLanguage;

  @override
  initState() {
    currentUser.value.isPageHome = false;
    localLanguage = languageCode.value.language.toString();

    getLatestBlog();
    super.initState();
    searchController = TextEditingController();
  }

  Future getLatestBlog({bool load = true}) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      setState(() {
        _isLoading = load;
      });
      final msg = jsonEncode({"user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}AllBookmarkPost';
      final client = http.Client();
      final header = {
        "Content-Type": "application/json",
        "lang-code": languageCode.value.language ?? ''
      };
      print("languageCode.value?.language $header");
      final response = await client.post(
        Uri.parse(url),
        headers: header,
        body: msg,
      );
      Map data = json.decode(response.body);
      final list =
          (data['data'] as List).map((i) => DataModel.fromMap(i)).toList();
      setState(() {
        blogList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            print(
                "drawer $value ${localLanguage != languageCode.value.language}");
            if (localLanguage != languageCode.value.language) {
              getLatestBlog();
              setState(() {
                localLanguage = languageCode.value.language.toString();
              });
            }
          },
          appBar: commonAppBar(context, width: width),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Helper.rightHandLang
                                .contains(languageCode.value.language)
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 25.0, left: 25.0, top: 20.0),
                          child: Text(
                            allMessages.value.mySavedStories.toString(),
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Montserrat',
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w800),
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: blogList.isNotEmpty
                            ? Column(
                                key: Key(blogList.length.toString()),
                                children: blogList
                                    .map((e) => BottomCardSaved(
                                          e,
                                          (value) {
                                            setState(() {
                                              getLatestBlog(load: false);
                                              // _isLoading = false;
                                            });
                                          },
                                          isTrending: false,
                                        ))
                                    .toList(),
                              )
                            : Column(
                                children: [
                                  Text(
                                    allMessages.value.noSavedPostFound
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
