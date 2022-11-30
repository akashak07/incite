import 'dart:convert';
import 'dart:io';

import 'package:blog_app/elements/bottom_card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:hexcolor/hexcolor.dart';

import '../appColors.dart';
import '../app_theme.dart';

//* <----------- Search Blog Page -------------->

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GetStorage localList = GetStorage();
  TextEditingController? searchController;
  FocusNode focusNod = FocusNode();
  Blog blogList = Blog();
  bool _isLoading = false;
  bool _isFound = true;
  var width;

  @override
  initState() {
    List local = localList.read('searchList') ?? [];
    print(local);
    for (int i = 0; i < local.length; i++) {
      mainDataList.add(local[i]);
    }
    currentUser.value.isPageHome = false;
    super.initState();
    searchController = TextEditingController();
  }

  void getSearchedBlog() async {
    _isLoading = true;
    if (searchController != null) {
      final msg = jsonEncode(
          {"title": searchController!.text, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}searchBlog';
      final client = new http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == true) {
        _isFound = true;
      } else {
        _isFound = false;
      }
      final list = Blog.fromJson(data);
      setState(() {
        blogList = list;
        _isLoading = false;
      });
    } else {
      Fluttertoast.showToast(
          msg: allMessages.value.noResultFound.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIos: 5,
          backgroundColor: appMainColor,
          textColor: Colors.white);
    }
  }

  bool searchListShor = true;
  List<String> mainDataList = [];

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
          },
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).canvasColor,
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
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Image.asset(
                        "assets/img/menu.png",
                        fit: BoxFit.none,
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Spacer(),
                    /*    currentUser.value.name != null
                        ? GestureDetector(
                            child: Image.asset(
                              "assets/img/search.png",
                              width: 0.06 * width,
                            ),
                            onTap: () {
                              //    Navigator.pushNamed(context, '/SearchPage');
                            },
                          )
                        : Container(),*/
                    SizedBox(
                      width: 0.044 * constraints.maxWidth,
                    ),
                    Container(
                      width: 0.08 * constraints.maxWidth,
                      height: 0.08 * constraints.maxWidth,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/UserProfile', arguments: true);
                        },
                        child: Hero(
                          tag: 'photo',
                          child: CircleAvatar(
                            backgroundImage: currentUser.value.photo != null &&
                                    currentUser.value.photo != ''
                                ? NetworkImage(currentUser.value.photo)
                                : AssetImage('assets/img/user.png')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Center(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 30.0),
                    child: Column(
                      children: [
                        Container(
                          alignment: Helper.rightHandLang
                                  .contains(languageCode.value.language)
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 25.0),
                            child: Text(
                              allMessages.value.searchStories.toString(),
                              style:
                                  Theme.of(context).textTheme.bodyText1?.merge(
                                        TextStyle(
                                            color: appThemeModel.value
                                                    .isDarkModeEnabled.value
                                                ? Colors.white
                                                : Colors.black,
                                            fontFamily: 'Montserrat',
                                            fontSize: 26.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            width: 0.9 * width,
                            child: TextFormField(
                              focusNode: focusNod,
                              style: TextStyle(
                                fontSize: 20.0,
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : HexColor("#000000"),
                              ),
                              controller: searchController,
                              textInputAction: TextInputAction.search,
                              onSaved: (value) {},
                              onFieldSubmitted: (value) {
                                getSearchedBlog();
                                if (searchListShor) {
                                  if (!mainDataList
                                      .contains(searchController!.text)) {
                                    if (mainDataList.length >= 4) {
                                      localList.remove('searchList');
                                      mainDataList
                                          .removeAt(mainDataList.length - 1);
                                      mainDataList.add(searchController!.text);
                                      localList.write(
                                          'searchList', mainDataList);
                                    } else {
                                      localList.remove('searchList');
                                      mainDataList.add(searchController!.text);
                                      localList.write(
                                          'searchList', mainDataList);
                                    }
                                  } else {
                                    localList.remove('searchList');
                                    mainDataList.removeWhere((item) =>
                                        item == searchController!.text);
                                    mainDataList.add(searchController!.text);
                                    localList.write('searchList', mainDataList);
                                  }
                                  searchListShor = false;
                                } else {
                                  searchListShor = true;
                                  searchController!.text = '';
                                }
                                setState(() {
                                  searchListShor = false;
                                });
                              },
                              onChanged: (text) {
                                setState(() {});
                                // if (text.length >= 3) {
                                //   setState(() {
                                //     getSearchedBlog();
                                //   });
                                // }
                              },
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.red),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : HexColor("#000000"),
                                      width: 1.0),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    getSearchedBlog();
                                    setState(() {
                                      if (searchListShor) {
                                        if (!mainDataList
                                            .contains(searchController!.text)) {
                                          if (mainDataList.length >= 4) {
                                            localList.remove('searchList');
                                            mainDataList.removeAt(
                                                mainDataList.length - 1);
                                            mainDataList
                                                .add(searchController!.text);
                                            localList.write(
                                                'searchList', mainDataList);
                                          } else {
                                            localList.remove('searchList');
                                            mainDataList
                                                .add(searchController!.text);
                                            localList.write(
                                                'searchList', mainDataList);
                                          }
                                        } else {
                                          localList.remove('searchList');
                                          mainDataList.removeWhere((item) =>
                                              item == searchController!.text);
                                          mainDataList
                                              .add(searchController!.text);
                                          localList.write(
                                              'searchList', mainDataList);
                                        }
                                        searchListShor = false;
                                      } else {
                                        searchListShor = true;
                                        searchController!.text = '';
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        searchListShor ? 12.0 : 15.0),
                                    child: Image.asset(
                                      searchListShor
                                          ? "assets/img/search_small.png"
                                          : "assets/img/cancel.png",
                                      width: 5,
                                      fit: BoxFit.fitWidth,
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              autofocus: false,
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            if(blogList.data != null)
                              _isFound
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Column(
                                      children: blogList.data!
                                          .map(
                                            (e) => BottomCard(
                                              e,
                                              blogList.data!.indexOf(e),
                                              blogList,
                                              isTrending: false,
                                              ontap: () {
                                                focusNod.unfocus();
                                              },
                                            ),
                                          )
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
                                                    color: appThemeModel
                                                            .value
                                                            .isDarkModeEnabled
                                                            .value
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                            Visibility(
                              visible: searchListShor ||
                                  searchController!.text.length == 0,
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                child: ListView(
                                  shrinkWrap: true,
                                  reverse: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: mainDataList.map((data) {
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      color: !appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Theme.of(context).cardColor,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              searchController!.text = data;
                                              setState(() {});
                                            },
                                            child: Container(
                                              color: !appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : Theme.of(context).cardColor,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.refresh_outlined),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    data,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.merge(
                                                          TextStyle(
                                                              color: appThemeModel
                                                                      .value
                                                                      .isDarkModeEnabled
                                                                      .value
                                                                  ? Colors.white
                                                                  : HexColor(
                                                                      "#000000"),
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 17.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                      onTap: () {
                                                        localList.remove(
                                                            'searchList');
                                                        mainDataList
                                                            .removeWhere(
                                                                (item) =>
                                                                    item ==
                                                                    data);
                                                        localList.write(
                                                            'searchList',
                                                            mainDataList);
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                          width: width * 0.10,
                                                          child: Icon(Icons
                                                              .clear_outlined))),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            thickness: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
