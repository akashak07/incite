import 'dart:async';
import 'dart:convert';

import 'package:blog_app/app_theme.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../appColors.dart';
import '../controllers/home_controller.dart';
import '../controllers/user_controller.dart';
import '../main.dart';
import '../models/setting.dart';
import 'auth.dart';
import 'category_post.dart';
import 'e_news.dart';
import 'live_news.dart';

const String testDevice = 'YOUR_DEVICE_ID';
//* <--------- Main Screen of the app ------------->
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends StateMVC<HomePage> with TickerProviderStateMixin {
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

  // PublisherBannerAd? _bannerAd;
  // final Completer<PublisherBannerAd> bannerCompleter =
  // Completer<PublisherBannerAd>();

  GlobalKey<ScaffoldState>? scaffoldKey;

  // AdSize? adSize;

  HomeController? homeController;

  ScrollController? scrollController;
  TabController? tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;
  String? localLanguage;

  List list = [];

  @override
  void initState() {
    super.initState();
    print("Home Page");
    chackNoti();
    //Foreground Firebase message notification listener init state.
    // It's navigation manage when you come from kill state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        onSelectNotification(message.data['id'] ?? 'null');
      }
    });
    // list= List.generate(6, (index) => BlogListHolder().da)
    getCurrentUser();
    localLanguage = languageCode.value.language;
    currentUser.value.isPageHome = true;
    homeController = HomeController();
    getCurrentSettings();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController!.addListener(scrollControllerListener);
    // _bannerAd = PublisherBannerAd(
    //   adUnitId: 'ca-app-pub-3940256099942544/6300978111',// todo here change dynamic ad id from backend
    //   request: PublisherAdRequest(nonPersonalizedAds: true),
    //   sizes: [AdSize.fullBanner],
    //   listener: AdListener(
    //     onAdLoaded: (Ad ad) {
    //       print('$PublisherBannerAd loaded.');
    //       bannerCompleter.complete(ad as PublisherBannerAd);
    //     },
    //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
    //       ad.dispose();
    //       print('$PublisherBannerAd failedToLoad: $error');
    //       bannerCompleter.completeError(error);
    //     },
    //     onAdOpened: (Ad ad) => print('$PublisherBannerAd onAdOpened.'),
    //     onAdClosed: (Ad ad) => print('$PublisherBannerAd onAdClosed.'),
    //     onApplicationExit: (Ad ad) =>
    //         print('$PublisherBannerAd onApplicationExit.'),
    //   ),
    // );
    // Future<void>.delayed(Duration(seconds: 1), () => _bannerAd?.load());
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

  Future getAllFeed(snapshot) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      blogListHolder.clearList();
      snapshot.setLoading(load: true);
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
        snapshot.setLoading(load: false);
      } catch (e) {
        snapshot.setLoading(load: false);
        BotToast.showText(text: "All News--->>> $e");
        print(e);
      }
      return true;
    }
  }

  String? appName;
  String? appImage;
  String? appSubtitle;
  Future<void> onRefreshData() async {
    languageCode.value = languageCode.value;
    Provider.of<AppProvider>(context, listen: false)
      ..getBlogData()
      ..getCategory();
    getCurrentSettings();
    setState(() {});
  }

  Future<Setting> getCurrentSettings() async {
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
  void dispose() {
    //  _bannerAd?.dispose();
    //   _bannerAd?.dispose();
    //   _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("In Build home_page.dart");
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return LoadingOverlay(
        isLoading: snapshot.load,
        color: Colors.grey,
        child: Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            key: scaffoldKey,
            drawer: DrawerBuilder(),
            onDrawerChanged: (value) {
              print(
                  "drawer $value ${localLanguage != languageCode.value.language}");
              // if (localLanguage != languageCode.value.language) {
              //   Provider.of<AppProvider>(context, listen: false)
              //     ..getBlogData()
              //     ..getCategory();
              //   setState(() {
              //     localLanguage = languageCode.value.language;
              //   });
              // }
            },
            appBar: buildAppBar(context),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: onRefreshData,
                  child: SingleChildScrollView(
                    child: ListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      children: <Widget>[
                        _buildTopText(),
                        _buildRecommendationCards(),
                        _buildTabText(),
                        Consumer<AppProvider>(builder: (context, snapshot, _) {
                          return snapshot.blog == null
                              ? Container()
                              : _buildTabView2();
                        }),
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
                                  allMessages.value.stayBlessedAndConnected ??
                                      "",
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
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                        // SizedBox(height: double.parse(AdSize.fullBanner.height.toString())),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 0,
                //   child: FutureBuilder<PublisherBannerAd>(
                //     future: bannerCompleter.future,
                //     builder:
                //         (BuildContext context, AsyncSnapshot<PublisherBannerAd> snapshot) {
                //       Widget child;
                //
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.none:
                //         case ConnectionState.waiting:
                //         case ConnectionState.active:
                //           child = Container();
                //           break;
                //         case ConnectionState.done:
                //           if (snapshot.hasData) {
                //             child = AdWidget(ad: _bannerAd);
                //           } else {
                //             child = Text('Error loading $PublisherBannerAd');
                //           }
                //       }
                //
                //       return Container(
                //         width: _bannerAd?.sizes[0].width.toDouble(),
                //         height: _bannerAd?.sizes[0].height.toDouble(),
                //         child: child,
                //         color: Colors.blueGrey,
                //       );
                //     },
                //   ),
                // ),
              ],
            )),
      );
    });
  }

  buildAppBar(BuildContext context) {
    if (scaffoldKey?.currentState?.isDrawerOpen ?? false) {
      scaffoldKey?.currentState?.openEndDrawer();
    }
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
            return Row(
              children: [
                SizedBox(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        currentUser.value.name != null
                            ? "${allMessages.value.welcome ?? ""} ${currentUser.value.name ?? ""},"
                            : allMessages.value.welcomeGuest ?? "",
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
                        allMessages.value.featuredStories ?? "",
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          bool error = false;
          try {
            if ((snapshot.blogList.data?.length ?? 0) == 0) {
              error = true;
            } else {
              error = false;
            }
          } catch (e) {
            error = true;
          }
          if (error) {
            return ListView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[100] ?? Colors.black,
                  highlightColor: Colors.grey[200] ?? Colors.black,
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
            );
          }
          return (snapshot.blogList.data?.length ?? 0) == 0
              ? ListView.builder(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[100] ?? Colors.black,
                      highlightColor: Colors.grey[200] ?? Colors.black,
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
                  itemCount: snapshot.blogList.data!.length > 10
                      ? 10
                      : snapshot.blogList.data!.length,
                );
        }),
      ),
    );
  }

  _buildTabBar() {
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return TabBar(
          indicatorColor: Colors.transparent,
          controller: tabController,
          onTap: setTabIndex,
          isScrollable: true,
          tabs: snapshot.blog!.data!
              .map((e) => Tab(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.name.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color: e.index == currentTabIndex
                                    ? appThemeModel
                                            .value.isDarkModeEnabled.value
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
    });
  }

  setTabIndex(int value) {
    setState(() {
      currentTabIndex = value;
    });
  }

  _buildTabText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            allMessages.value.filterByTopics ?? "",
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

  _buildTabView2() {
    List list = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          int length = 0;
          // eLiveKey != "0" || eNewsKey != "0" ||
          // if (news == 'news') {
          //   length = snapshot.blog!.data!.length + 3;
          // }
          if (eLiveKey != "0" && eNewsKey != "0") {
            length = snapshot.blog!.data!.length + 2;
          } else if (eLiveKey != "0" || eNewsKey != "0") {
            length = snapshot.blog!.data!.length + 1;
          } else {
            length = snapshot.blog!.data!.length;
          }
          print("length :$length");
          return snapshot.blog == null
              ? Wrap(
                  // crossAxisCount: 3,
                  // childAspectRatio: MediaQuery.of(context).size.width /
                  //     (MediaQuery.of(context).size.height / 1.60),
                  // controller: TrackingScrollController(keepScrollOffset: false),
                  // shrinkWrap: true,
                  // reverse: true,
                  // scrollDirection: Axis.vertical,
                  children: [
                      for (var item in list)
                        Shimmer.fromColors(
                          baseColor: Colors.grey[100] ?? Colors.black,
                          highlightColor: Colors.grey[200] ?? Colors.black,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.red,
                            ),
                          ),
                        )
                    ])
              : Wrap(spacing: 20,
                  // crossAxisCount: 3,
                  // childAspectRatio: MediaQuery.of(context).size.width /
                  //     (MediaQuery.of(context).size.height / 1.60),
                  // controller: TrackingScrollController(keepScrollOffset: false),
                  // shrinkWrap: true,
                  // reverse: true,
                  // scrollDirection: Axis.vertical,
                  children: [
                      newCategories(
                          width: MediaQuery.of(context).size.width / 4,
                          title: "All News",
                          image: "assets/img/app_icon.png",
                          ontap: () async {
                            await getAllFeed(snapshot);
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SwipeablePage(
                                          0,
                                          isFromFeed: true)));
                            });
                          }),
                      ...List.generate(length, (index) {
                        if (eLiveKey == "0" && eNewsKey != "0") {
                          if (index == snapshot.blog!.data!.length) {
                            return newCategories(
                                title: allMessages.value.eNews ?? "",
                                image: eNewsImage ?? "assets/img/app_icon.png",
                                ontap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Enews()));
                                });
                          }
                        } else if (eLiveKey != "0" && eNewsKey == "0") {
                          if (index == snapshot.blog!.data!.length) {
                            return newCategories(
                                title: allMessages.value.liveNews ?? "",
                                image: eLiveImage ?? "assets/img/app_icon.png",
                                ontap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LiveNews()));
                                });
                          }
                        } else if (eLiveKey != "0" && eNewsKey != "0") {
                          if (index == snapshot.blog!.data!.length + 2) {
                            return eNewsKey == "0"
                                ? Container()
                                : newCategories(
                                    title: allMessages.value.eNews ?? "",
                                    image:
                                        eNewsImage ?? "assets/img/app_icon.png",
                                    ontap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Enews()));
                                    });
                          } else if (index == snapshot.blog!.data!.length + 1) {
                            return eLiveKey == "0"
                                ? const SizedBox()
                                : newCategories(
                                    title: allMessages.value.liveNews ?? "",
                                    image:
                                        eLiveImage ?? "assets/img/app_icon.png",
                                    ontap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LiveNews()));
                                    });
                          }
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
                              DataModel item =
                                  blogListHolder.getList().data![0];

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
                            width: MediaQuery.of(context).size.width / 4,
                            margin: const EdgeInsets.only(
                                bottom: 5, right: 0, top: 10, left: 0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Colors.black38.withOpacity(0.1),
                                          blurRadius: 5.0,
                                          offset: const Offset(0.0, 0.0),
                                          spreadRadius: 1.0)
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          snapshot.blog!.data![index].image,
                                      fit: BoxFit.fitWidth,
                                      cacheKey:
                                          snapshot.blog!.data![index].image,
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
                                                      offset: const Offset(
                                                          0.0, 0.0),
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
                                Text(
                                    snapshot.blog!.data![index].name.toString(),
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
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600),
                                        )),
                              ],
                            ),
                          ),
                        );
                      })
                    ]);
        }));
  }

  _buildTabView() {
    String news = 'news';
    //  List list = [
    //    [blogListHolder.getList().data]
    // ];
    return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          int length = 0;
          // eLiveKey != "0" || eNewsKey != "0" ||
          // if (news == 'news') {
          //   length = snapshot.blog!.data!.length + 3;
          // }
          if (eLiveKey != "0" && eNewsKey != "0" && news == 'news') {
            length = snapshot.blog!.data!.length + 3;
          } else if (eLiveKey != "0" || eNewsKey != "0" || news == 'news') {
            length = snapshot.blog!.data!.length + 1;
          } else {
            length = snapshot.blog!.data!.length;
          }
          print("length :$length");
          return GridView.count(
              crossAxisCount: 3,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 1.60),
              controller: TrackingScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              reverse: true,
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
                  : List.generate(length, (index) {
                      if (index == snapshot.blog!.data!.length) {
                        return newCategories(
                            title: "All News",
                            image: "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SwipeablePage(
                                            0,
                                          )));
                            });
                      } else if (eLiveKey == "0" && eNewsKey != "0") {
                        if (index == snapshot.blog!.data!.length) {
                          return newCategories(
                              title: allMessages.value.eNews ?? "",
                              image: eNewsImage ?? "assets/img/app_icon.png",
                              ontap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Enews()));
                              });
                        }
                      } else if (eLiveKey != "0" && eNewsKey == "0") {
                        if (index == snapshot.blog!.data!.length) {
                          return newCategories(
                              title: allMessages.value.liveNews ?? "",
                              image: eLiveImage ?? "assets/img/app_icon.png",
                              ontap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LiveNews()));
                              });
                        }
                      } else if (eLiveKey != "0" && eNewsKey != "0") {
                        if (index == snapshot.blog!.data!.length + 2) {
                          return eNewsKey == "0"
                              ? Container()
                              : newCategories(
                                  title: allMessages.value.eNews ?? "",
                                  image:
                                      eNewsImage ?? "assets/img/app_icon.png",
                                  ontap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Enews()));
                                  });
                        } else if (index == snapshot.blog!.data!.length + 1) {
                          return eLiveKey == "0"
                              ? const SizedBox()
                              : newCategories(
                                  title: allMessages.value.liveNews ?? "",
                                  image:
                                      eLiveImage ?? "assets/img/app_icon.png",
                                  ontap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LiveNews()));
                                  });
                        }
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
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w600),
                                      )),
                            ],
                          ),
                        ),
                      );
                    }));
        }));
  }

  newCategories(
      {String? title, String? image, VoidCallback? ontap, double? width}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 0, top: 10, left: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: ontap,
            child: Container(
              width: width ?? MediaQuery.of(context).size.width / 3,
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
                      width: MediaQuery.of(context).size.width / 4,
                      height: MediaQuery.of(context).size.height * 0.1135,
                      padding: const EdgeInsets.only(
                          top: 15, left: 10, right: 10, bottom: 20),
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
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  )),
        ],
      ),
    );
  }
}
