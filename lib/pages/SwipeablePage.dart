import 'dart:convert';
import 'dart:io';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/auth.dart';
import 'package:blog_app/pages/read_blog.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../appColors.dart';
import '../helpers/network_helper.dart';
import '../helpers/urls.dart';
import 'blog_ad_page.dart';

const int maxFailedLoadAttempts = 3;

class SwipeablePage extends StatefulWidget {
  final int index;
  final bool isFromFeed, isFromFeatured;
  const SwipeablePage(this.index,
      {this.isFromFeed = false, this.isFromFeatured = false});

  @override
  _SwipeablePageState createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage> {
//  PageController pageController;
  PreloadPageController? pageController;
  double? height, width;
  int currentPage = 0;
  // InterstitialAd? _interstitialAd;
  // static final AdRequest request = AdRequest(
  //   testDevices: testDevice != null ? <String>[testDevice] : null,
  //   keywords: <String>['foo', 'bar'],
  //   contentUrl: 'http://foo.com/bar.html',
  //   nonPersonalizedAds: true,
  // );
  bool _interstitialReady = false;
  bool isLoading = false;
  bool isLastPage = false, isLoadingFeed = false;

  @override
  void initState() {
    print("-00-0-00-090-0-09-090-90-9-090-90-9");
    if ((blogListHolder.getList().data?.length ?? 0) == 0) {
      Fluttertoast.showToast(
          msg: "Blog not available",
          backgroundColor: appMainColor,
          gravity: ToastGravity.TOP);
      Navigator.pop(context);
    }

    // pageController = PageController(initialPage: widget.index);
    pageController = PreloadPageController(initialPage: widget.index);
    currentPage = widget.index;
    pageController?.addListener(listener);
    if (currentPage == blogListHolder.getList().data!.length - 1 &&
        widget.isFromFeatured == true) {
      isLoading = true;

      isLastPage = true;
      setState(() {});
      if (!blogListHolder
              .getList()
              .data!
              .contains(DataModel(categoryName: 'Great', title: 'You ')) &&
          widget.isFromFeatured == true) {
        blogListHolder.getList().data!.insert(
            currentPage + 1, DataModel(categoryName: 'Great', title: 'You '));
        setState(() {});
      }
    }
    // if (blogListHolder.getList().length == 1) {
    //   Fluttertoast.showToast(msg: "Last News",backgroundColor: appMainColor,);
    // }
    // MobileAds.instance.initialize().then((InitializationStatus status) {
    //   print('Initialization done: ${status.adapterStatuses}');
    //   MobileAds.instance
    //       .updateRequestConfiguration(RequestConfiguration(
    //       tagForChildDirectedTreatment:
    //       TagForChildDirectedTreatment.unspecified))
    //       .then((value) {
    //     createInterstitialAd();
    //   });
    // });
  }

  // void createInterstitialAd() {
  //   _interstitialAd ??= InterstitialAd(
  //     adUnitId: InterstitialAd.testAdUnitId,
  //     request: request,
  //     listener: AdListener(
  //       onAdLoaded: (Ad ad) {
  //         print('${ad.runtimeType} loaded.');
  //         _interstitialReady = true;
  //       },
  //       onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //         print('${ad.runtimeType} failed to load: $error.');
  //         ad.dispose();
  //         _interstitialAd = null;
  //         createInterstitialAd();
  //       },
  //       onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
  //       onAdClosed: (Ad ad) {
  //         print('${ad.runtimeType} closed.');
  //         ad.dispose();
  //         createInterstitialAd();
  //       },
  //       onApplicationExit: (Ad ad) =>
  //           print('${ad.runtimeType} onApplicationExit.'),
  //     ),
  //   )..load();
  // }

  listener() {
    if (pageController!.position.atEdge) {
      if (pageController!.position.minScrollExtent < -2) {
        setState(() {
          isLastBlog = true;
        });
      }
      if (pageController!.position.pixels == 0) {
        setState(() {
          isLoading = false;
        });
        // Fluttertoast.showToast(msg: "T",backgroundColor: appMainColor,);
      } else {
        if (blogListHolder.getList().nextPageUrl != 'Notification') {
          setState(() {
            isLoading = true;
          });
          getLatestBlog(blogListHolder.getList().nextPageUrl);
        } else if (blogListHolder.getList().nextPageUrl != null) {
          setState(() {
            isLoading = true;
          });
          getLatestBlog(blogListHolder.getList().nextPageUrl);
        } else {
          Fluttertoast.showToast(
            msg: "Last News",
            backgroundColor: appMainColor,
          );
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future getLatestBlog(String? nextPageUrl) async {
    var url = nextPageUrl.toString();
    http.Response? result;
    print(url);
    try {
      result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "lang-code": languageCode.value.language ?? ''
        },
      );
    } on Exception catch (e) {
      print(e);
    }
    if (widget.isFromFeed == false && result!.statusCode == 200) {
      print('------');
      Map<String, dynamic> data = json.decode(result.body);
      BlogCategory category = BlogCategory.fromMap(data);
      setState(() {
        Blog? setList = blogListHolder.getList();
        for (int k = 0; k < (category.data?.length ?? 0); k++) {
          for (int i = 0;
              i < (category.data?[k].blog?.data?.length ?? 0);
              i++) {
            setList.data!.add(category.data![k].blog!.data![i]);
          }
        }

        Blog finalData = Blog();
        finalData = category.data![currentPage].blog!;
        finalData.data = setList.data!;
        blogListHolder.clearList();
        blogListHolder.setList(finalData);
        print('--------');
        isLoading = false;
      });
    } else if (widget.isFromFeed == true && result!.statusCode == 200) {
      print('------');
      Map<String, dynamic> data = json.decode(result.body);
      Blog category = Blog.fromJson(data['data']);
      setState(() {
        Blog? setList = blogListHolder.getList();
        for (int i = 0; i < (category.data?.length ?? 0); i++) {
          setList.data!.add(category.data![i]);
        }
        Blog finalData = Blog();
        finalData = category;
        finalData.data = setList.data!;
        blogListHolder.clearList();
        blogListHolder.setList(finalData);
        print('--------');
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Last News",
        backgroundColor: appMainColor,
      );
    }
  }

  bool isInterstialLoaded = false;

  //REMOVED FOR WEB BUILD
  // InterstitialAd? _interstitialAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    createInterstitialAd();
  }

  void createInterstitialAd() {
    enableAds != '1'
        ? null
        //REMOVED FOR WEB BUILD
        // : InterstitialAd.load(
        //     adUnitId: Platform.isAndroid
        //         ? androidInterstitialId ??
        //             'ca-app-pub-3940256099942544/1033173712'
        //         : iosInterstitialId ?? 'ca-app-pub-3940256099942544/4411468910',
        //     request: const AdRequest(),
        //     adLoadCallback: InterstitialAdLoadCallback(
        //       onAdLoaded: (InterstitialAd ad) {
        //         // Keep a reference to the ad so you can show it later.
        //         isInterstialLoaded = true;
        //         _interstitialAd = ad;
        //         setState(() {});
        //       },
        //       onAdFailedToLoad: (LoadAdError error) {
        //         print('InterstitialAd failed to load: $error');
        //       },
        //     ));
        : const SizedBox();
  }

  bool isLastBlog = false;
  Future getAllFeed() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      setState(() {
        isLoadingFeed = true;
      });

      var url = "${Urls.baseUrl}getAllFeed/";
      print(url);
      var result = await http.get(
        Uri.parse(url),
      );
      try {
        blogListHolder.clearList();
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
        setState(() {
          isLoadingFeed = false;
        });
      } catch (e) {
        setState(() {
          isLoadingFeed = false;
        });
        BotToast.showText(text: "All News--->>> $e");
        print(e);
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return LoadingOverlay(
      isLoading: isLoadingFeed,
      child: Stack(
        children: [
          Container(
            color: HexColor("#323232"),
            child: PreloadPageView.builder(
              itemBuilder: (ctx, index) {
                if (isLastPage == true &&
                    blogListHolder.getList().data![index].categoryName ==
                        'Great' &&
                    widget.isFromFeatured == true) {
                  return LastNewsWidget(
                    onTap: () async {
                      await getAllFeed();
                      SchedulerBinding.instance.addPostFrameCallback(
                        (timeStamp) {
                          // Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SwipeablePage(0,
                                      isFromFeed: true)));
                        },
                      );
                    },
                  );
                } else if (blogListHolder.getList().data![index].title !=
                        null &&
                    (blogListHolder.getList().data![index].section?.length ??
                            0) ==
                        0) {
                  return ReadBlog(blogListHolder.getList().data![index],
                      isFromFeatured: widget.isFromFeatured,
                      onUpSwip: (DragUpdateDetails value) {
                    if (value.delta.dy < 0) {
                      if (blogListHolder.getList().data!.length == 1) {
                        Fluttertoast.showToast(
                          msg: "Last News",
                          backgroundColor: appMainColor,
                        );
                        // isLastBlog = true;
                        // setState(() {});
                        // print(isLastBlog);
                      } else {
                        pageController?.animateToPage(
                          index + 1,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.linear,
                        );
                      }
                    } else if (value.delta.dy > 0) {
                      pageController?.animateToPage(
                        index - 1,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                      );
                      if (blogListHolder.getList().data!.contains(
                          DataModel(categoryName: 'Great', title: 'You '))) {
                        blogListHolder.getList().data!.remove(
                            DataModel(categoryName: 'Great', title: 'You '));
                        setState(() {});
                      }
                    }
                  });
                } else {
                  return BlogAd(
                      section: blogListHolder.getList().data![index].section);
                }
              },
              itemCount: blogListHolder.getList().data!.length,
              scrollDirection: Axis.vertical,
              preloadPagesCount: 0,
              // reverse: true,
              //allowImplicitScrolling: false,
              physics: const CustomPageViewScrollPhysics(parent: null),
              controller: pageController,
              pageSnapping: true,
              onPageChanged: (value) {
                if (value % defaultAdsFrequency.value == 0) {
                  int adIndex = 0;
                  if ((blogListHolder.getList().data![value].section?.length ??
                          0) ==
                      0) {
                    if (value > defaultAdsFrequency.value) {
                      for (int i = 0; i < adList.value.length; i++) {
                        if (blogListHolder
                                .getList()
                                .data![value - defaultAdsFrequency.value]
                                .id ==
                            adList.value[i].id) {
                          if ((i + 1) < adList.value.length) {
                            adIndex = i + 1;
                          } else {
                            adIndex = 0;
                          }
                          break;
                        }
                      }
                    }
                    blogListHolder
                        .getList()
                        .data!
                        .insert(value, adList.value[adIndex]);
                    setState(() {});
                  }
                }
                // if((value+1) % 5 == 0){
                //   print('-----------');
                //   int leftBlog = blogListHolder.getList().total! - (value + 1);
                //   Fluttertoast.showToast(msg: "${leftBlog.toString()} unread stories below",backgroundColor: appMainColor,);
                // }
                if (_interstitialReady) {
                  // _interstitialAd?.show();
                  _interstitialReady = false;
                } else {
                  // _interstitialAd = null;
                  // createInterstitialAd();
                }

                // REMOVED FOR WEB BUILD
                // if (isInterstialLoaded) {
                //   _interstitialAd!.show();
                // } else {
                //   _interstitialAd = null;
                //   createInterstitialAd();
                // }
                print("---------------");
                print("page change");
                currentUser.value.isNewUser = false;
                blogListHolder.setIndex(value);
                // currentUser.value =
                //     Users.fromJSON(json.decode(prefs.get('current_user')));
                print(pageController!.offset);
                currentPage = value;
                if (value == (blogListHolder.getList().data!.length - 1)) {
                  isLastPage = true;
                  if (!blogListHolder.getList().data!.contains(
                          DataModel(categoryName: 'Great', title: 'You ')) &&
                      widget.isFromFeatured == true) {
                    blogListHolder.getList().data!.insert(value + 1,
                        DataModel(categoryName: 'Great', title: 'You '));
                    setState(() {});
                  }
                } else {
                  isLastPage = false;
                }
                setState(() {});
              },
            ),
          ),
          if (isLoading && isLastPage && widget.isFromFeatured == false)
            const Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    //REMOVED FOR WEB BUILD
    // _interstitialAd?.dispose();
    pageController?.removeListener(listener);
    pageController?.dispose();
  }
}

class LastNewsWidget extends StatelessWidget {
  const LastNewsWidget({Key? key, this.onTap}) : super(key: key);
  final VoidCallback? onTap;

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

  @override
  Widget build(BuildContext context) {
    var themeDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 4.5,
                    height: MediaQuery.of(context).size.width / 4.5,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: themeDark ? Colors.white : Colors.black,
                        ),
                        shape: BoxShape.circle),
                    child: Icon(
                      Icons.done,
                      size: 40,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Great',
                    style: TextStyle(
                      fontSize: 32,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'You have viewed all Featured stories',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                  TweenAnimationBuilder<Offset>(
                      duration: const Duration(milliseconds: 100),
                      tween: Tween<Offset>(
                          begin: const Offset(0, -20),
                          end: const Offset(1, 20)),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(
                              0,
                              (MediaQuery.of(context).size.height / 3.45) +
                                  value.dy.toDouble()),
                          // duration: const Duration(milliseconds: 200),
                          // curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            opacity: value.dx.toDouble(),
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              child: TextButton.icon(
                                  label: const Text(
                                    'All News',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(13))),
                                      backgroundColor: appMainColor,
                                      elevation: 10),
                                  onPressed: onTap ??
                                      () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SwipeablePage(
                                                      0,
                                                      isFromFeed: true,
                                                    )));
                                      },
                                  icon: const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 14,
                                  )),
                            ),
                          ),
                        );
                      })
                ],
              ),
              // TweenAnimationBuilder<Offset>(
              //     duration: const Duration(milliseconds: 100),
              //     tween: Tween<Offset>(
              //         begin: const Offset(0, -20), end: const Offset(1, 20)),
              //     builder: (context, value, child) {
              //       return AnimatedPositioned(
              //         bottom: value.dy.toDouble(),
              //         right: MediaQuery.of(context).size.width / 5,
              //         duration: const Duration(milliseconds: 200),
              //         curve: Curves.easeInOut,
              //         child: AnimatedOpacity(
              //           opacity: value.dx.toDouble(),
              //           duration: const Duration(milliseconds: 400),
              //           child: Container(
              //             width: MediaQuery.of(context).size.width / 3,
              //             padding: const EdgeInsets.symmetric(
              //                 vertical: 16, horizontal: 8),
              //             child: TextButton.icon(
              //                 label: const Text(
              //                   'All News',
              //                   style: TextStyle(color: Colors.white),
              //                 ),
              //                 style: TextButton.styleFrom(
              //                     shape: const RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.all(
              //                             Radius.circular(13))),
              //                     backgroundColor: appMainColor,
              //                     elevation: 10),
              //                 onPressed: onTap ??
              //                     () {
              //                       Navigator.pop(context);
              //                       Navigator.push(
              //                           context,
              //                           MaterialPageRoute(
              //                               builder: (context) =>
              //                                   const SwipeablePage(
              //                                     0,
              //                                     isFromFeed: true,
              //                                   )));
              //                     },
              //                 icon: const Icon(
              //                   Icons.arrow_downward,
              //                   color: Colors.white,
              //                   size: 14,
              //                 )),
              //           ),
              //         ),
              //       );
              //     })
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
