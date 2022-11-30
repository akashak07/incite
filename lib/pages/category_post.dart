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

//* <----------- Search Blog Page -------------->

class CategoryPostPage extends StatefulWidget {
  final int useHeroWidget;

  const CategoryPostPage(this.useHeroWidget);

  @override
  _CategoryPostPageState createState() => _CategoryPostPageState();
}

class _CategoryPostPageState extends State<CategoryPostPage> {
  TextEditingController? searchController;
  Blog blogList = Blog();
  bool _isLoading = false;
  final bool _isFound = true;
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
    if (isInternet) {
      _isLoading = true;
      final msg = jsonEncode({
        "category_id": widget.useHeroWidget,
        "user_id": currentUser.value.id
      });
      final String url = '${Urls.baseUrl}AllBookmarkPost';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id.toString(),
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map data = json.decode(response.body);
      final list = Blog.fromJson(data['data']);
      setState(() {
        print(list);
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
          backgroundColor: Theme.of(context).cardColor,
          drawer: DrawerBuilder(),
          onDrawerChanged: (value) {
            if (!value) {
              setState(() {});
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
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 20.0),
                          child: Text(
                            allMessages.value.categoryPost.toString(),
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
                        child: _isFound
                            ? Column(
                                children: blogList.data!
                                    .map((e) => BottomCard(
                                          e,
                                          blogList.data!.indexOf(e),
                                          blogList,
                                          isTrending: false,
                                          ontap: () {},
                                        ))
                                    .toList(),
                              )
                            : Column(
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
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
AppBar commonAppBar(BuildContext context, {width, bool isProfile = false}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Theme.of(context).canvasColor,
    automaticallyImplyLeading: false,
    title: LayoutBuilder(builder: (contextname, constraints) {
      return GestureDetector(
        onTap: () {
          Scaffold.of(contextname).openDrawer();
        },
        child: Row(
          children: [
            Image.asset(
              "assets/img/loveoman.png",
              width: 0.3 * width,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 23.0),
              child: Image.asset(
                "assets/img/menu.png",
                fit: BoxFit.none,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const Spacer(),
            GestureDetector(
              child: Image.asset(
                "assets/img/search.png",
                width: 0.06 * width,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : Colors.black,
              ),
              onTap: () {
                Navigator.pushNamed(context, '/SearchPage');
              },
            ),
            SizedBox(
              width: 0.044 * constraints.maxWidth,
            ),
            SizedBox(
              width: 0.08 * constraints.maxWidth,
              height: 0.08 * constraints.maxWidth,
              child: GestureDetector(
                onTap: () {
                  currentUser.value.name != null
                      ? Navigator.of(context)
                          .pushNamed('/UserProfile', arguments: true)
                      : Navigator.of(context)
                          .pushNamed('/AuthPage', arguments: true);
                },
                child: Hero(
                  tag: 'photo',
                  child: CircleAvatar(
                    backgroundImage: currentUser.value.photo != null &&
                            currentUser.value.photo != ''
                        ? NetworkImage(currentUser.value.photo)
                        : const AssetImage('assets/img/user.png')
                            as ImageProvider,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}
