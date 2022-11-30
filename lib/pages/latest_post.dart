import 'dart:convert';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/bottom_card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';

import '../app_theme.dart';
import 'category_post.dart';

//* <----------- Search Blog Page -------------->

class LatestPage extends StatefulWidget {
  @override
  _LatestPageState createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage> {
  TextEditingController? searchController;
  Blog? blogList;
  bool _isLoading = false;
  bool _isFound = true;
  var height, width;

  @override
  initState() {
    currentUser.value.isPageHome = false;
    getLatestBlog();
    super.initState();
    searchController = TextEditingController();
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if(isInternet){
      _isLoading = true;
      var url = "${Urls.baseUrl}blog-all-list";
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id.toString(),
          "lang-code": languageCode.value.language ?? ''
        },
      );
      Map data = json.decode(result.body);
      final list = Blog.fromJson(data['data']);
      setState(() {
        blogListHolder.clearList();
        blogListHolder.setList(list);
        blogList = list;
        _isLoading = false;
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
          drawer: DrawerBuilder(),
          onDrawerChanged: (value) {
            if (!value) {
              setState(() {});
            }
          },
          appBar: commonAppBar(context,width:width),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0, top: 20.0),
                        child: Text(
                          allMessages.value.latestPost.toString(),
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
                    Container(
                      child: _isFound
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                children: blogList!.data!
                                    .map((e) => BottomCard(
                                          e,
                                          blogList?.data?.indexOf(e),
                                          blogList!,
                                          isTrending: false,
                                        ))
                                    .toList(),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                children: [
                                  Text(
                                    allMessages.value
                                        .noResultsFoundMatchingWithYourKeyword
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.merge(
                                          TextStyle(
                                              color: appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: 'Montserrat',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
