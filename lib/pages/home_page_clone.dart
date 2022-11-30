import 'dart:convert';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/pages/category_post.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:http/http.dart' as http;
import 'package:blog_app/app_theme.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:provider/provider.dart';
import '../appColors.dart';
import '../controllers/home_controller.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';
import 'auth.dart';
import 'e_news.dart';
import 'live_news.dart';

// ! MAIN PAGE
const String testDevice = 'YOUR_DEVICE_ID';
//* <--------- Main Screen of the app ------------->
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomeClonePage());
}

class HomeClonePage extends StatefulWidget {
  @override
  _HomeClonePageState createState() => _HomeClonePageState();
}

class _HomeClonePageState extends StateMVC<HomeClonePage>
    with TickerProviderStateMixin {
  /* static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {},
    );
  }*/

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeController? homeController;
  List category = [];
  List list = [];
  bool _isLoading = false;

  ScrollController? scrollController;
  TabController? tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;

  BlogCategory? blogCategory;
  Blog blogList = Blog();
  String? localLanguage;

  Future getAllFeed() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      blogListHolder.clearList();
      var url = "${Urls.baseUrl}getAllFeed/";
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
            text: "All News",
            textStyle: const TextStyle(color: Colors.transparent),
            backgroundColor: Colors.transparent,
            contentColor: Colors.transparent);
        await Future.delayed(const Duration(microseconds: 500));
      } catch (e) {
        BotToast.showText(text: "All News--->>> $e");
        print(e);
      }
      return true;
    }
  }

  @override
  void initState() {
    localLanguage = languageCode.value.language.toString();
    getAllFeed();
    homeController = HomeController();
    getCurrentUser();
    getBlogData();
    getCategory();
    super.initState();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController!.addListener(scrollControllerListener);
  }

  Future getCategory() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      print(
          "getCategory languageCode.value ${languageCode.value} ${languageCode.value.language ?? "null"}");
      _isLoading = true;
      var url = "${Urls.baseUrl}blog-category-list";
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          // 'userData': currentUser.value.id
          "lang-code": languageCode.value.language ?? ''
        },
      );
      print("getCategory result.body ${result.body}");
      Map<String, dynamic> data = json.decode(result.body);
      BlogCategory category = BlogCategory.fromMap(data);
      setState(() {
        blogCategory = category;
        print("blogCategory ${blogCategory!.data!.length}");
        _isLoading = false;
      });
    }
  }

  Future getBlogData() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _isLoading = true;
      var url = "${Urls.baseUrl}blog-list";
      print("fetching $url");
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "lang-code": languageCode.value.language ?? ''

          // 'userData': currentUser.value.id
        },
      );
      Map data = json.decode(result.body);
      final list = Blog.fromJson(data['data']);
      print(list);
      setState(() {
        blogList = list;
        blogListHolder.clearList();
        blogListHolder.setList(list);
        _isLoading = false;
      });
    }
  }

  scrollControllerListener() {
    if (scrollController!.offset >= height * 0.58) {
      setState(() {
        showTopTabBar = true;
      });
    } else {
      setState(() {
        showTopTabBar = false;
      });
    }
  }

  @override
  void dispose() {
    //  _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        key: scaffoldKey,
        drawer: DrawerBuilder(),
        onDrawerChanged: (value) {
          print(
              "drawer $value ${localLanguage != languageCode.value.language}");
          if (localLanguage != languageCode.value.language) {
            Provider.of<AppProvider>(context, listen: false)
              ..getBlogData()
              ..getCategory();
            setState(() {
              localLanguage = languageCode.value.language.toString();
            });
          }
        },
        appBar: buildAppBar(context),
        body: SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            children: <Widget>[
              _buildTopText(),
              _buildRecommendationCards(),
              _buildTabText(),
              _buildTabView(),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        allMessages.value.stayBlessedAndConnected.toString(),
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : HexColor("#000000"),
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ));
  }

  buildAppBar(BuildContext context) {
    return commonAppBar(context, width: width);
  }

  _buildTopText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            print(context);
            print(constraints.maxWidth);
            return Row(
              children: [
                SizedBox(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        currentUser.value.name != null
                            ? "${allMessages.value.welcome} ${currentUser.value.name},"
                            : "${allMessages.value.welcomeGuest}",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400),
                            ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        allMessages.value.featuredStories.toString(),
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold),
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Consumer<AppProvider>(builder: (context, snapshot, _) {
                  return ButtonTheme(
                    minWidth: 0.1 * constraints.maxWidth,
                    height: 0.04 * height,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.only(
                            right: 12,
                            left: 12,
                            bottom: 0.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(
                              color: HexColor("#000000"),
                              width: 1.2,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text(
                            allMessages.value.myFeed ?? "",
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: HexColor("#000000"),
                                      fontFamily: 'Montserrat',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                        ),
                        onPressed: () async {
                          bool isInternet =
                              await NetworkHelper.isInternetIsOn();
                          if (isInternet) {
                            if (currentUser.value.photo != null) {
                              snapshot.setLoading(load: true);
                              var url =
                                  "${Urls.baseUrl}getFeed/${currentUser.value.id}";
                              print(url);
                              var result = await http.get(
                                Uri.parse(url),
                              );
                              Map data = json.decode(result.body);
                              print(
                                  "result ${data['data'].length} ${currentUser.value.id} ${languageCode.value.language ?? "null"}");

                              final list = Blog.fromJson(data['data']);

                              for (DataModel item in list.data!) {
                                print(" HOMEPAGE FEED :${item.title}");
                              }

                              snapshot.setLoading(load: false);
                              setState(() {
                                blogListHolder.clearList();
                                blogListHolder.setList(list);
                                blogListHolder.setIndex(0);
                              });
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SwipeablePage(
                                  0,
                                  isFromFeed: true,
                                ),
                              ));
                            } else {
                              Navigator.of(context).pushReplacementNamed(
                                  '/AuthPage',
                                  arguments: true);
                            }
                          }
                        }),
                  );
                })
              ],
            );
          },
        ),
      ),
    );
  }

  //! Top cards . .
  _buildRecommendationCards() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      height: 0.5 * MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Consumer<AppProvider>(builder: (context, snapshot, _) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: snapshot.blogList.data!.isEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[100]!,
                        highlightColor: Colors.grey[200]!,
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 20.0, left: 20.0, right: 10.0),
                          height: 0.4 * MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width * 0.65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                    itemCount: 10,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    addAutomaticKeepAlives: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      print(
                          "-------------${snapshot.blogList.data![index].title}-------------${snapshot.blogList.data!.length}");
                      if (snapshot.blogList.data![index].type == 'Ads') {
                        return Container();
                      }
                      return CardItem(snapshot.blogList.data![index], index,
                          snapshot.blogList);
                    },
                    itemCount: snapshot.blogList.data!.length,
                  ));
      }),
    );
  }

  _buildTabBar() {
    return TabBar(
        indicatorColor: Colors.transparent,
        controller: tabController,
        onTap: setTabIndex,
        isScrollable: true,
        tabs: blogCategory!.data!
            .map((e) => Tab(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    e.name.toString(),
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: e.index == currentTabIndex
                                  ? appThemeModel.value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.grey,
                              fontFamily: GoogleFonts.notoSans().fontFamily,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                )))
            .toList());
  }

  setTabIndex(int value) {
    setState(() {
      currentTabIndex = value;
    });
  }

  _buildTabItem(String text, int index) {
    return Container(
      child: Tab(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1?.merge(
                TextStyle(
                    color: index == currentTabIndex
                        ? appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : Colors.black
                        : Colors.grey,
                    fontFamily: GoogleFonts.notoSans().fontFamily,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600),
              ),
        ),
      )),
    );
  }

  _buildTabText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            allMessages.value.filterByTopics.toString(),
            style: Theme.of(context).textTheme.bodyText1?.merge(
                  TextStyle(
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
    );
  }

  _buildTabView() {
    List list = [];
    return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          return GridView.count(
              crossAxisCount: 3,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 1.45),
              controller: TrackingScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: snapshot.blog == null
                  ? List.generate(9, (index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[100] ?? Colors.black,
                        highlightColor: Colors.grey[200] ?? Colors.black,
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.red,
                          ),
                        ),
                      );
                    })
                  : List.generate(snapshot.blog!.data!.length + 2, (index) {
                      if (index == 0) {
                        return newCategories(
                            title: "All News",
                            image: "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SwipeablePage(
                                            0,
                                            isFromFeed: true,
                                          )));
                            });
                      } else if (index == snapshot.blog!.data!.length) {
                        return eLiveKey == "0"
                            ? Container()
                            : newCategories(
                                title: allMessages.value.eNews ?? "",
                                image: eNewsImage ?? "assets/img/app_icon.png",
                                ontap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Enews()));
                                });
                      } else if (index == snapshot.blog!.data!.length + 1) {
                        return eNewsKey == "0"
                            ? Container()
                            : newCategories(
                                title: allMessages.value.liveNews ?? "",
                                image: eLiveImage ?? "assets/img/app_icon.png",
                                ontap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LiveNews()));
                                });
                      }
                      return GestureDetector(
                        onTap: () async {
                          // snapshot.setLoading(load: true);

                          // final msg = jsonEncode({
                          //   "category_id": snapshot.blog!.data![index].id
                          //   //"user_id": currentUser.value.id
                          // });
                          // print(msg);
                          // print(
                          //     "blogCategory.data[index].id ${snapshot.blog!.data![index].id}");
                          // final String url =
                          //     '${Urls.baseUrl}AllBookmarkPost';
                          // final client = new http.Client();
                          // final response = await client.post(
                          //   Uri.parse(url),
                          //   headers: {
                          //     "Content-Type": "application/json",
                          //     'userData': currentUser.value.id.toString(),
                          //     "lang-code":
                          //         languageCode.value.language ?? ''
                          //   },
                          //   body: msg,
                          // );
                          // print(
                          //     "API in home page response ${response.body}");
                          // Map data = json.decode(response.body);
                          // final list = (data['data'] as List)
                          //     .map((i) => new DataModel.fromMap(i))
                          //     .toList();
                          //
                          // // print("List Size for index $index : " +
                          // //     list.length.toString());
                          // snapshot.setLoading(load: false);
                          //
                          // // for (DataModel item in list) {
                          // //   print("item.title ${item.title}");
                          // // }
                          Blog? setList = Blog();
                          for (int i = 0;
                              i < snapshot.blog!.data!.length;
                              i++) {
                            if (snapshot.blog!.data![index].id ==
                                snapshot.blog!.data![i].id) {
                              setList = snapshot.blog!.data![i].blog;
                            }
                          }
                          if (setList != null) {
                            blogListHolder.clearList();
                            blogListHolder.setList(setList);
                            blogListHolder.setIndex(0);
                            DataModel item = blogListHolder.getList().data![0];
                            print("for FB ${item.title}");
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return const SwipeablePage(0);
                              }),
                            ).then((value) {
                              blogListHolder.clearList();
                              blogListHolder.setList(snapshot.blogList);
                            });
                          } else {
                            Fluttertoast.showToast(
                                backgroundColor: appMainColor,
                                msg: allMessages.value.noNewsAvilable ?? "");
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 5, right: 10, top: 10, left: 10),
                          decoration: const BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(
                              //       color: Colors.black38.withOpacity(0.1),
                              //       blurRadius: 5.0,
                              //       offset: Offset(0.0, 0.0),
                              //       spreadRadius: 1.0)
                              // ],
                              ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black38.withOpacity(0.1),
                                        blurRadius: 5.0,
                                        offset: const Offset(0.0, 0.0),
                                        spreadRadius: 1.0)
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot.blog!.data![index].image,
                                    fit: BoxFit.fitWidth,
                                    cacheKey: snapshot.blog!.data![index].image,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.149,
                                            padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black38
                                                        .withOpacity(0.1),
                                                    blurRadius: 5.0,
                                                    offset:
                                                        const Offset(0.0, 0.0),
                                                    spreadRadius: 1.0)
                                              ],
                                            ),
                                            child: Image.asset(
                                              "assets/img/app_icon.png",
                                            )),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(snapshot.blog!.data![index].name.toString(),
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
                                      )),
                            ],
                          ),
                        ),
                      );
                    }));
        }));
  }

  newCategories({String? title, String? image, VoidCallback? ontap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 10, top: 10, left: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: ontap,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38.withOpacity(0.1),
                      blurRadius: 5.0,
                      offset: const Offset(0.0, 0.0),
                      spreadRadius: 1.0)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: image!,
                  fit: BoxFit.fitWidth,
                  cacheKey: image,
                  errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.114,
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38.withOpacity(0.1),
                              blurRadius: 5.0,
                              offset: const Offset(0.0, 0.0),
                              spreadRadius: 1.0)
                        ],
                      ),
                      child: Image.asset(
                        "assets/img/app_icon.png",
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(title!,
              style: Theme.of(context).textTheme.bodyText1?.merge(
                    TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        fontFamily: 'Montserrat',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600),
                  )),
        ],
      ),
    );
  }
}
