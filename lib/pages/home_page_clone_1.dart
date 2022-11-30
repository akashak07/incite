import 'dart:convert';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:blog_app/app_theme.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import 'package:hexcolor/hexcolor.dart';
import 'auth.dart';
import 'e_news.dart';
import 'live_news.dart';
//import 'package:http/http.dart' as http;

//* <--------- Main Screen of the app ------------->

class HomeClonePage extends StatefulWidget {
  @override
  _HomeClonePageState createState() => _HomeClonePageState();
}

class _HomeClonePageState extends StateMVC<HomeClonePage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeController? homeController;
  List category = [];
  List list = [];
  bool _isLoading = false;
  String? localLanguage;

  ScrollController? scrollController;
  TabController? tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;

  BlogCategory? blogCategory;
  Blog blogList = Blog();

  @override
  void initState() {
    localLanguage = languageCode.value.language.toString();

    homeController = HomeController();
    getCurrentUser();
    getBlogData();
    getCategory();
    super.initState();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController?.addListener(scrollControllerListener);
  }

  Future getCategory() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _isLoading = true;
      print(
          "languageCode.value ${languageCode.value} ${languageCode.value.language ?? "null"}");
      var url = "${Urls.baseUrl}blog-category-list";
      print("fetching $url");
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id.toString(),
          "lang-code": languageCode.value.language ?? ''
        },
      );
      Map<String, dynamic> data =
          json.decode(result.body) as Map<String, dynamic>;
      BlogCategory category = BlogCategory.fromMap(data);
      setState(() {
        blogCategory = category;
        // tabController =
        //     TabController(length: blogCategory.data.length, vsync: this);
        _isLoading = false;
      });
    }
  }

  Future getBlogData() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _isLoading = true;
      var url = "${Urls.baseUrl}blog-list";
      //var result = await http
      //.get("${GlobalConfiguration().getValue('api_base_url')}blog-list");
      var result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id.toString(),
          "lang-code": languageCode.value.language ?? ''
        },
      );
      Map data = json.decode(result.body);
      print(data);
      final list = Blog.fromJson(data['data']);
      setState(() {
        blogList = list;
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
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
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
        body: ListView(
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
              //color: Colors.amberAccent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      allMessages.value.stayBlessedAndConnected.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
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
          ],
        ));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      bottom: showTopTabBar
          ? _buildTabBar()
          : PreferredSize(
              preferredSize: const Size(0, 0),
              child: Container(),
            ),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,

      //backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
      title: LayoutBuilder(builder: (contextname, constraints) {
        return GestureDetector(
          onTap: () {
            Scaffold.of(contextname).openDrawer();
          },
          child: Row(
            children: [
              Image.asset(
                "assets/img/incite.png",
                width: 0.25 * width,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Image.asset(
                  "assets/img/menu.png",
                  //width: 0.01 * width,
                  fit: BoxFit.none,
                  color: appThemeModel.value.isDarkModeEnabled.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 0.08 * constraints.maxWidth,
                height: 0.08 * constraints.maxWidth,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
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
        child: blogList.data!.isEmpty
            ? ListView.builder(
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
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
                  return CardItem(blogList.data![index], index, blogList);
                },
                itemCount: blogList.data!.length,
              ),
      ),
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

  enewsPaper() {
    return SizedBox(
      height: 500,
      child: GestureDetector(
        onTap: () async {},
        child: SizedBox(
          height: 500,
          child: Card(
            semanticContainer: true,
            child: Stack(
              children: [
                Positioned(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ClipRRect(
                          child: Container(
                              child: Image.asset(
                            'assets/img/app_icon.png',
                            fit: BoxFit.cover,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildTabView() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 1.6),
          controller: ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: blogCategory == null
              ? List.generate(9, (index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[100]!,
                    highlightColor: Colors.grey[200]!,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.red,
                      ),
                    ),
                  );
                })
              : List.generate(blogCategory!.data!.length + 2, (index) {
                  if (index == blogCategory!.data!.length) {
                    return eLiveKey == "0"
                        ? Container()
                        : newCategories(
                            title: allMessages.value.eNews.toString(),
                            image: eNewsImage ?? "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Enews()));
                            });
                  } else if (index == blogCategory!.data!.length + 1) {
                    return eNewsKey == "0"
                        ? Container()
                        : newCategories(
                            title: allMessages.value.liveNews.toString(),
                            image: eLiveImage ?? "assets/img/app_icon.png",
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LiveNews()));
                            });
                  }
                  return SizedBox(
                    height: 500,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/CategoryPostPage',
                            arguments: blogCategory!.data![index].id);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
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
                                imageUrl: blogCategory!.data![index].image,
                                fit: BoxFit.cover,
                                cacheKey: blogCategory!.data![index].image,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(blogCategory!.data![index].name.toString(),
                              style:
                                  Theme.of(context).textTheme.bodyText1?.merge(
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
                }),
        ),
      ),
    );
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
                      height: MediaQuery.of(context).size.height * 0.149,
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 20),
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
