import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blog_app/elements/banner_ad.dart';
import 'package:blog_app/elements/video_player.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../appColors.dart';
import '../app_theme.dart';
import '../data/blog_list_holder.dart';
import 'SwipeablePage.dart';
import 'auth.dart';
import 'read_blog_screenshot.dart';
import 'web_view.dart';

class ReadBlog extends StatefulWidget {
  final DataModel item;
  Function? onUpSwip;
  final bool isFromFeatured;

  ReadBlog(this.item, {this.onUpSwip, this.isFromFeatured = false});

  @override
  _ReadBlogState createState() => _ReadBlogState();
}

enum TtsState { playing, stopped, paused, continued }

class _ReadBlogState extends State<ReadBlog> {
  bool _isLoading = false;
  var height, width;
  int _current = 0;
  bool isVolume = false;
  bool isWebOpened = false;
  bool isVolumeOn = false;
  bool isOpeningWebPage = false;
  bool isBookmark = false;
  bool isNew = false;
  // VoiceController? _voiceController;
  bool linkOpen = false;
  List<DataModel> blogList = [];

  // text to speech
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  GlobalKey<CustomVideoPlayerState> videoPlayeState =
      GlobalKey<CustomVideoPlayerState>();

  Future<void> init(String text) async {
    bool isLanguageFound = false;
    flutterTts.getLanguages.then((value) {
      Iterable it = value;

      for (var element in it) {
        if (element
            .toString()
            .contains(getCurrentItem().blogAccentCode.toString())) {
          flutterTts.setLanguage(element);
          initTTS(text);
          isLanguageFound = true;
        }
      }
    });

    if (!isLanguageFound) initTTS(text);
  }

  Future getAllFeed() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      setState(() {
        _isLoading = true;
      });
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
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        BotToast.showText(text: "All News--->>> $e");
        print(e);
      }
      return true;
    }
  }

  Future<void> initTTS(String text) async {
    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      stop();
      setState(() {
        print("Complete");
        isVolume = false;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

    await Future.delayed(const Duration(milliseconds: 300));
    speak(text);
  }

  void _deleteSavedPost(int id) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      final msg = jsonEncode({"blog_id": id, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}deleteBookmarkPost';
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
      if (response.statusCode == 200) {
        isBookmark = false;
        setState(() {});
        // Fluttertoast.showToast(
        //     msg: data['message'],
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.TOP,
        //     timeInSecForIos: 5,
        //     backgroundColor: appMainColor,
        //     textColor: Colors.white);
      } else {
        showToast('Something went wrong');
      }
    }
  }

  Future speak(String text) async {
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  DataModel getCurrentItem() {
    return widget.item;
  }

  var scr = GlobalKey();
  double fontSize = 16;

  @override
  void initState() {
    super.initState();
    //initializeLoggedInUser();

    print("Current Data ${currentUser.value.isNewUser}");
    if (currentUser.value.isNewUser == null) {
      currentUser.value.isNewUser = false;
      isNew = false;
    } else {
      isNew = currentUser.value.isNewUser ?? false;
    }

    //getProfile();
    // _voiceController = FlutterTextToSpeech.instance.voiceController();
    if (getCurrentItem().isBookmarked == 1) {
      isBookmark = true;
    } else {
      isBookmark = false;
    }
    _viewPost();
  }

  bool isReadBlogAvailable = true;

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    // if (_voiceController != null) {
    //   _voiceController!.stop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {});
    height = MediaQuery.of(context).size.height;
    print(
        "top MediaQuery.of(context).size. ${MediaQuery.of(context).padding.top} $kToolbarHeight}");
    width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: currentUser,
        builder: (context, value, child) {
          return LoadingOverlay(
            isLoading: _isLoading,
            color: Colors.grey,
            child: Theme(
              data: Theme.of(context).copyWith(
                  textTheme: TextTheme(
                headline1: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                headline2: Theme.of(context)
                    .textTheme
                    .headline2
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                headline3: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                headline4: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                headline5: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                headline6: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                subtitle1: Theme.of(context)
                    .textTheme
                    .subtitle1
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                subtitle2: Theme.of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                bodyText1: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
                bodyText2: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontFamily: "Hindi Vadodara SemiBold"),
              )),
              child: Scaffold(
                backgroundColor: Theme.of(context).cardColor,
                body: GestureDetector(
                  onHorizontalDragEnd: (DragEndDetails dragDetail) {
                    isReadBlogAvailable = true;
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) async {
                    print("details.delta.xd ${details.delta.dx}");
                    if (details.delta.dx < -6.5) {
                      print("left isReadBlogAvailable $isReadBlogAvailable");

                      if (widget.item.url != null && isReadBlogAvailable) {
                        isReadBlogAvailable = false;
                        // await Helper.launchURL(widget.item.url);
                        print("getCurrentItem().url, ${getCurrentItem().url}");
                        /* try {
                          videoPlayeState.currentState.vidoPlayPauseTogal(true);
                        } catch (e) {
                          print("error while pause $e");
                        }*/
                        setState(() {
                          linkOpen = true;
                        });
                        /*    await Get.to(CustomWebView(
                          url: getCurrentItem().url,
                        ));*/
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomWebView(
                              url: getCurrentItem().url.toString(),
                            ),
                          ),
                        );

                        setState(() {
                          linkOpen = false;
                        });
                        print(
                            " MediaQuery.of(context).padding.top ${MediaQuery.of(context).padding.top}");
                        /*  try {
                          videoPlayeState.currentState.vidoPlayPauseTogal(true);
                        } catch (e) {}
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext ctn) {
                            return SafeArea(
                              child: Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(30.0),
                                          topRight: const Radius.circular(30.0),
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15, top: 5),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: WebView(
                                        initialUrl: widget.item.url,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        try {
                          videoPlayeState.currentState.vidoPlayPauseTogal(false);
                        } catch (e) {}
*/
                        // await launch(widget.item.url).then((value) {});
                      }
                    } else if (details.delta.dx > 10) {
                      print("right");
                      Navigator.pop(context);
                    }
                  },
                  child: getCurrentItem().categoryName == 'Great' &&
                          widget.isFromFeatured == true
                      ? LastNewsWidget(
                          onTap: () async {
                            await getAllFeed();

                            WidgetsBinding.instance.addPostFrameCallback(
                              (timeStamp) {
                                // Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SwipeablePage(0,
                                                isFromFeed: true)));
                              },
                            );
                          },
                        )
                      : Stack(
                          children: <Widget>[
                            SizedBox(
                              height: height,
                              child: _buildPage(),
                            ),
                            !(currentUser.value.isNewUser ?? false)
                                ? Container()
                                : Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          // intializeshared();
                                          isNew = false;
                                          // currentUser.value = Users.fromJSON(
                                          //     json.decode(prefs.get('current_user')));
                                          currentUser.value.isNewUser = false;
                                          //intializeshared();
                                          print(
                                              "Current Data ontap ${currentUser.value.isNewUser}");
                                          print("isNew ontap $isNew");
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/img/screen.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                ),
              ),
            ),
          );
        });
  }

  _buildPage() {
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          key: scr,
          child: ReadBlogScreenshot(
            getCurrentItem(),
          ),
        ),
        Positioned.fill(
          child: _buildBlog(
            context,
          ),
        ),
        _buildTopBackButton(context),
        Positioned(
          left: Helper.rightHandLang.contains(languageCode.value.language)
              ? 15.0
              : null,
          right: !Helper.rightHandLang.contains(languageCode.value.language)
              ? 15.0
              : null,
          top: 35.0,
          child: Opacity(
            opacity: 0.6,
            child: ButtonTheme(
              minWidth: 0.07 * MediaQuery.of(context).size.width,
              height: 0.04 * MediaQuery.of(context).size.height,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.only(
                    right: 8,
                    left: 8,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  // Navigator.of(context)
                  //     .pushReplacementNamed('/HomeClonePage', arguments: false);
                },
                child: Wrap(
                  children: [
                    const Icon(
                      Mdi.eye,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        "  ${widget.item.viewCount}",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal),
                            ),
                        //style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ],
                  // child: Text(
                  //   "SKIP",
                  //   style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildBlog(BuildContext context) {
    var widthTop = 0.035 * width - 5;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 0.3825 * height,
                width: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: _buildOverlayImage(),
                    ),
                    // _buildBlogNameAndDetails(context),
                  ],
                ),
              ),
              // ?  Container()
              // :
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 0.055 * height,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                          color: HexColor("#F9F9F9"),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 5.0, bottom: 10.0, right: 13.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              widget.item.blogCategory != null
                                  ? Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.6,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              8.04,
                                      alignment: Alignment.bottomLeft,
                                      child: Wrap(spacing: 6, children: [
                                        ...widget.item.blogCategory!
                                            .map((e) => categoryTag(e, context))
                                            .toList()
                                      ]),
                                    )
                                  : Row(children: [
                                      Container(
                                        width: 0.025 * width,
                                        height: 0.025 * width,
                                        decoration: BoxDecoration(
                                          color: widget.item.blogCategory !=
                                                  null
                                              ? HexColor(
                                                  widget.item.color.toString())
                                              : HexColor('#000000'),
                                          // color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        getCurrentItem()
                                            .categoryName
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.merge(
                                              const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13.0,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                      ),
                                    ]),
                              isVolumeOn
                                  ? SizedBox(
                                      width: widthTop,
                                    )
                                  : Container(),
                              // isVolumeOn
                              //     ? Container(
                              //         width: widthTop * 0.04 * width,
                              //         alignment: Alignment.center,
                              //         child: Text(
                              //           allMessages.value.toStopPlayingTapAgain
                              //               .toString(),
                              //           style: Theme.of(context)
                              //               .textTheme
                              //               .bodyText1
                              //               ?.merge(
                              //                 const TextStyle(
                              //                     color: Colors.black,
                              //                     fontSize: 10.0,
                              //                     fontWeight:
                              //                         FontWeight.normal),
                              //               ),
                              //           textAlign: TextAlign.left,
                              //         ),
                              //       )
                              //     : Container(),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  getCurrentItem()
                                      .createDate
                                      .toString()
                                      .split("//")[0],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.merge(
                                        const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildBlogNameAndDetails(context),
                      Container(
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: Stack(
                          alignment: Helper.rightHandLang
                                  .contains(languageCode.value.language)
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              /* height: getCurrentItem().isVotingEnabled ==
                                          1 &&
                                      currentUser.value.id != null
                                  ? 0.34 * height
                                  : height *
                                      (0.425 +
                                          (getCurrentItem().url == null
                                              ? 0.06
                                              : 0)),
                                              */
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  right: 30.0,
                                  top: 5.0,
                                  bottom: 20.0,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    String text = parse(getCurrentItem()
                                                .description
                                                .toString())
                                            .body
                                            ?.text ??
                                        '';
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: AutoSizeText(
                                            text,
                                            maxLines: getCurrentItem()
                                                            .isVotingEnabled ==
                                                        1 &&
                                                    currentUser.value.id != null
                                                ? (height / 67).toInt()
                                                : (height / 48).toInt(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: appThemeModel.value
                                                        .isDarkModeEnabled.value
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.w100),
                                            minFontSize: 12,
                                            maxFontSize:
                                                defaultFontSize.value != null
                                                    ? defaultFontSize.value
                                                        .toDouble()
                                                    : 16,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Positioned(bottom: 0, child: BannerAds())
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              getCurrentItem().url != null
                  ? Column(
                      children: [
                        // enableAds != '0'
                        //     ? BannerAds(
                        //         adUnitId: androidBannerId ??
                        //             'ca-app-pub-3940256099942544/6300978111',
                        //       )
                        //     : const SizedBox(),
                        Container(
                          color: Theme.of(context).cardColor,
                          child: Container(
                            color: Colors.grey.withOpacity(0.2),
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 4, bottom: 4),
                            child: Row(
                              children: [
                                getCurrentItem().url != null
                                    ? Text(
                                        "${allMessages.value.swipeTo} ",
                                        style: TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15,
                                        ),
                                      )
                                    : Container(),
                                getCurrentItem().url != null
                                    ? const Icon(Mdi.arrowLeftBoldBoxOutline)
                                    : Container(),
                                getCurrentItem().url != null
                                    ? Text(
                                        " ${allMessages.value.readFull}",
                                        style: TextStyle(
                                          color: appThemeModel
                                                  .value.isDarkModeEnabled.value
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : enableAds != '0'
                      ? const SizedBox()
                      // ? BannerAds(
                      //     adUnitId: androidBannerId ??
                      //         'ca-app-pub-3940256099942544/6300978111',
                      //   )
                      : const SizedBox(),
              currentUser.value.id != null &&
                      getCurrentItem().isVotingEnabled == 1
                  ? _buildVotingCard()
                  : Container(),
            ],
          ),
          Positioned(
            left: Helper.rightHandLang.contains(languageCode.value.language)
                ? 0.05 * width
                : null,
            right: !Helper.rightHandLang.contains(languageCode.value.language)
                ? 0.05 * width
                : null,
            top: 0.357 * height,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      shareImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.black,
                        ),
                        color: !appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : Theme.of(context).cardColor,
                      ),
                      child: Image.asset(
                        'assets/img/white/share.png',
                        height: 20,
                        width: 20,
                        color: const Color(0xff48D1CC),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  if (currentUser.value.id != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isBookmark == false) {
                            _savePost();
                            isBookmark = true;
                          } else {
                            _deleteSavedPost(getCurrentItem().id ?? 0);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black,
                          ),
                          color: !appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Theme.of(context).cardColor,
                        ),
                        child: isBookmark
                            ? const Icon(
                                Icons.bookmark,
                                color: Color(0xff48D1CC),
                                size: 30,
                              )
                            : const Icon(
                                Icons.bookmark_border,
                                color: Color(0xff48D1CC),
                                size: 30,
                              ),
                      ),
                    )
                  else
                    Container(),
                  SizedBox(
                    width: currentUser.value.id != null ? 15 : 0,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black,
                          ),
                          color: !appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Theme.of(context).cardColor,
                        ),
                        child: VisibilityDetector(
                          key: Key(getCurrentItem().title.toString()),
                          onVisibilityChanged: (visibilityInfo) async {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100.0;
                            if (visiblePercentage != 100.0) {
                              if (isVolume) {
                                stop();
                              }
                              isVolume = false;
                            }
                          },
                          child: GestureDetector(
                            child: Image.asset(
                              isVolume
                                  ? 'assets/img/white/pause.png'
                                  : 'assets/img/white/play.png', //play.png
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                              color: const Color(0xff48D1CC),
                            ),
                            onTap: () {
                              setState(() {
                                if (isVolume == false) {
                                  init(getCurrentItem()
                                      .trimedDescription
                                      .toString());
                                  isVolume = true;
                                  isVolumeOn = true;
                                  Future.delayed(
                                      const Duration(milliseconds: 700), () {
                                    isVolumeOn = false;
                                  });
                                } else {
                                  stop();
                                  isVolume = false;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Narrate",
                          style: Theme.of(context).textTheme.bodyText1.merge(
                                TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal),
                              ),
                        ),
                      ),
                      */
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryTag(BlogSubCategory e, BuildContext context) {
    return SizedBox(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 0.020 * width,
            height: 0.020 * width,
            decoration: BoxDecoration(
              color: widget.item.blogCategory != null
                  ? HexColor(e.category!.color.toString())
                  : HexColor('#000000'),
              // color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            '${e.category!.name} ',
            style: Theme.of(context).textTheme.bodyText1?.merge(
                  const TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal),
                ),
          ),
        ],
      ),
    );
  }

  _buildVotingCard() {
    return Container(
      width: double.infinity,
      height: 0.09 * height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
      ),
      child: getCurrentItem().isVote == 0 &&
              getCurrentItem().votingQuestion != null
          ? _buildVotingMech()
          : _buildIsParticipated(),
    );
  }

  _buildVotingMech() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: AutoSizeText(
                      getCurrentItem().votingQuestion.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w900),
                          ),
                      minFontSize: 8,
                      maxFontSize: 16,
                      maxLines: 4,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 1,
                ),
                Expanded(
                  child: Row(
                    children: [
                      ButtonTheme(
                        minWidth: 0.21 * width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor("#016300"),
                          ),
                          onPressed: () {
                            setState(() {
                              _saveVoting(1);
                            });
                          },
                          child: Text(
                            getCurrentItem().optiontype == 0
                                ? allMessages.value.yes.toString()
                                : 'Agree',
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      ButtonTheme(
                        minWidth: 0.22 * width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor("#C62226"),
                          ),
                          onPressed: () {
                            setState(() {
                              _saveVoting(0);
                            });
                          },
                          child: Text(
                            getCurrentItem().optiontype == 0
                                ? allMessages.value.no.toString()
                                : 'Disagree',
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildIsParticipated() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ShapePainter(),
          child: Column(
            children: [
              const Spacer(),
              Container(
                child: Center(
                  child: Text(
                    allMessages.value.thankYouForParticipating.toString(),
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appThemeModel.value.isDarkModeEnabled.value
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500),
                        ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 0.5 * constraints.maxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    getCurrentItem().yesPercent > 0
                        ? ButtonTheme(
                            minWidth: widget.item.yesPercent /
                                    100 *
                                    constraints.maxWidth -
                                2,
                            height: constraints.maxHeight * 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#016300"),
                              ),
                              onPressed: () {},
                              child: Text(
                                "${getCurrentItem().yesPercent}% ${allMessages.value.yes}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    ?.merge(
                                      const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal),
                                    ),
                              ),
                            ),
                          )
                        : Container(),
                    getCurrentItem().noPercent > 0 &&
                            getCurrentItem().yesPercent > 0
                        ? Container(
                            color: HexColor("#000000"),
                            height: 55,
                            width: 3,
                          )
                        : Container(),
                    getCurrentItem().noPercent > 0
                        ? Center(
                            child: ButtonTheme(
                              minWidth: widget.item.noPercent /
                                      100 *
                                      constraints.maxWidth -
                                  1,
                              height: constraints.maxHeight * 0.5,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor("#C62226"),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "${getCurrentItem().noPercent}% ${allMessages.value.no}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.merge(
                                        const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildBookmark() {
    return currentUser.value.id != null
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
            child: GestureDetector(
              child: !isBookmark
                  ? const Icon(
                      Icons.bookmark_border,
                      color: Colors.black,
                      size: 25,
                    )
                  : const Icon(
                      Icons.bookmark,
                      color: Colors.black,
                      size: 25,
                    ),
              onTap: () {
                setState(() {
                  if (isBookmark == false) {
                    _savePost();
                    isBookmark = true;
                  } else {}
                });
              },
            ),
          )
        : IconButton(
            icon: const Icon(Icons.aspect_ratio, color: Colors.transparent),
            onPressed: () {},
          );
  }

  Path _buildBoatPath() {
    return Path()
      ..moveTo(15, 120)
      ..lineTo(0, 85)
      ..lineTo(50, 85)
      ..lineTo(60, 80)
      ..lineTo(60, 85)
      ..lineTo(120, 85)
      ..lineTo(105, 120) //and back to the origin, could not be necessary #1
      ..close();
  }

  _buildOverlayImage() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.item.contentType == "video"
            ? linkOpen
                ? const SizedBox.shrink()
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                        child: CustomVideoPlayer(
                          blog: getCurrentItem(),
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                            onTap: () async {
                              SystemChrome.setSystemUIOverlayStyle(
                                  const SystemUiOverlayStyle(
                                      statusBarIconBrightness: Brightness.light,
                                      statusBarColor: Colors.black));
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WillPopScope(
                                        onWillPop: () async {
                                          SystemChrome.setSystemUIOverlayStyle(
                                              const SystemUiOverlayStyle(
                                                  statusBarColor:
                                                      Colors.black26));
                                          await SystemChrome
                                              .setPreferredOrientations([
                                            DeviceOrientation.portraitUp,
                                          ]);
                                          Navigator.pop(context);
                                          return false;
                                        },
                                        child: MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: Scaffold(
                                            backgroundColor: Colors.black54,
                                            body: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        SystemChrome.setSystemUIOverlayStyle(
                                                            const SystemUiOverlayStyle(
                                                                statusBarColor:
                                                                    Colors
                                                                        .transparent));
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                      )),
                                                  Center(
                                                    child: CustomVideoPlayer(
                                                      blog: getCurrentItem(),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                        ));
                                  });
                            },
                            child: Container(
                              color: Colors.transparent,
                            )),
                      )
                    ],
                  )
            : getCurrentItem().bannerImage == null
                ? const SizedBox()
                : getCurrentItem().bannerImage.length > 1
                    ? Positioned(
                        child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: height * 0.6,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  autoPlay: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  },
                                ),
                                items: getCurrentItem()
                                    .bannerImage
                                    .map<Widget>((item) => Container(
                                          child: Center(
                                              child: CachedNetworkImage(
                                            imageUrl: item,
                                            fit: BoxFit.cover,
                                            cacheKey: item,
                                          )),
                                        ))
                                    .toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: getCurrentItem()
                                    .bannerImage
                                    .map<Widget>((url) {
                                  int index =
                                      getCurrentItem().bannerImage.indexOf(url);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Container(
                                      width: 10.0,
                                      height: 10.0,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _current == index
                                            ? const Color.fromRGBO(0, 0, 0, 0.9)
                                            : const Color.fromRGBO(
                                                0, 0, 0, 0.4),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          )
                        ],
                      ))
                    : Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: getCurrentItem().bannerImage[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        //   child: Image.network(
                        //   getCurrentItem().bannerImage[0],
                        //   fit: BoxFit.cover,
                        //   loadingBuilder: (BuildContext context, Widget child,
                        //       ImageChunkEvent loadingProgress) {
                        //     if (loadingProgress == null) return child;
                        //     return Center(
                        //       child: CircularProgressIndicator(
                        //         value: loadingProgress.expectedTotalBytes != null
                        //             ? loadingProgress.cumulativeBytesLoaded /
                        //                 loadingProgress.expectedTotalBytes
                        //             : null,
                        //       ),
                        //     );
                        //   },
                        // )
                      ),
      ],
    );
  }

  _buildBlogNameAndDetails(BuildContext context) {
    _viewPost();
    return Align(
      alignment: Helper.rightHandLang.contains(languageCode.value.language)
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      child: Container(
        width: width,
        padding:
            const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 0.0, top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                getCurrentItem().title.toString(),
                style: Theme.of(context).textTheme.bodyText1?.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildVoting(BuildContext context) {
    return Positioned(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: const DecorationImage(
            image: NetworkImage(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Colors.black,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  _buildTopBackButton(BuildContext context) {
    return Positioned(
      left: !Helper.rightHandLang.contains(languageCode.value.language)
          ? 15.0
          : null,
      right: Helper.rightHandLang.contains(languageCode.value.language)
          ? 15.0
          : null,
      top: 40.0,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: appMainColor,
          borderRadius: BorderRadius.circular(200),
          // border: Border.all(color: Theme.of(context).cardColor,),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _viewPost() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      print("getCurrentItem().id ${getCurrentItem().id}");
      print("currentUser.value.id ${currentUser.value.id}");
      final msg = jsonEncode(
          {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}increaseBlogViewCount';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      print("response.body ${response.body}");
      Map dataNew = json.decode(response.body);
    }
  }

  void _savePost() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      final msg = jsonEncode(
          {"blog_id": getCurrentItem().id, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}bookmarkPost';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? '',
        },
        body: msg,
      );
      print("response ${response.statusCode}");

      Map data = json.decode(response.body);
      print("response $data");

      isBookmark = true;
      getCurrentItem().isBookmarked = data['data']['is_bookmark'];
      // Fluttertoast.showToast(
      //     msg: data['message'],
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.TOP,
      //     timeInSecForIos: 5,
      //     backgroundColor: appMainColor,
      //     textColor: Colors.white);
      getBlogVotes();
    }
  }

  void _swipetoBlogs(type, context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      final msg = jsonEncode({"blog_id": getCurrentItem().id, "type": type});
      final String url = '${Urls.baseUrl}nextPreviousBlog';
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
      print("swipe blog data ${response.body}");
      Map data = json.decode(response.body);
      final list =
          (data['data'] as List).map((i) => DataModel.fromMap(i)).toList();
      setState(() {
        blogList = list;
        Navigator.of(context).pushNamed("/ReadBlog", arguments: blogList[0]);
      });
    }
  }

  void _openLink() async {
    try {
      Fluttertoast.showToast(
        msg: "Opening News in Web",
        backgroundColor: appMainColor,
      );
      Helper.launchURL(getCurrentItem().url.toString());
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Invalid Link",
        backgroundColor: appMainColor,
      );
    }

    setState(() {
      isOpeningWebPage = false;
    });
  }

  void _saveVoting(vote) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      _isLoading = true;
      final msg = jsonEncode({
        "vote": vote,
        "user_id": currentUser.value.id,
        'blog_id': getCurrentItem().id
      });
      print("msg $msg");
      final String url = '${Urls.baseUrl}addBlogVote';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: msg,
      );
      print("_saveVoting response $response");
      Map data = json.decode(response.body);
      getBlogVotes();
    }
  }

  void getBlogVotes() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      print(
          "getBlogVotes currentUser.value.id ${currentUser.value.id} ${languageCode.value.language}");
      final msg = jsonEncode({"blog_id": getCurrentItem().id});
      final String url = '${Urls.baseUrl}getBlogVote';
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
      setState(() {
        getCurrentItem().isVote = data['data']['is_vote'];
        getCurrentItem().yesPercent = data['data']['yes_percent'];
        getCurrentItem().noPercent = data['data']['no_percent'];
        getCurrentItem().isBookmarked = data['data']['is_bookmark'];
        _isLoading = false;
      });
    }
  }

  Future<void> _shareText() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      try {
        var request = await HttpClient()
            .getUrl(Uri.parse(getCurrentItem().bannerImage[0]));
        var response = await request.close();
        Uint8List bytes = await consolidateHttpClientResponseBytes(response);
        await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg',
            text: getCurrentItem().title.toString());
      } catch (e) {}
    }
  }

  Future<Uint8List?> _capturePng() async {
    RenderRepaintBoundary? boundary;
    try {
      boundary =
          scr.currentContext!.findRenderObject() as RenderRepaintBoundary;
    } catch (e) {}
    if (boundary == null) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }
    try {
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } catch (e) {}

    return null;
  }

  shareImage() async {
    BotToast.showLoading();
    var pngBytes = await _capturePng();
    print("pngBytes $pngBytes");
    try {
      await Share.file(
        'esys image',
        'esys.png',
        pngBytes!,
        'image/png',
        text: allMessages.value.shareMessage.toString(),
      );
    } catch (e) {
      BotToast.showText(text: "shareImage $e");
    }
    BotToast.cleanAll();
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 0.0;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(radius, 0.0);
    path.arcToPoint(Offset(0.0, radius),
        clockwise: true, radius: Radius.circular(radius));
    path.lineTo(0.0, size.height - radius);
    path.lineTo(size.width - 0.58 * size.width, size.height);
    path.lineTo(size.width - 0.45 * size.width, radius);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path1 = Path();
    path1.moveTo(0, size.height);
    path1.quadraticBezierTo(
        size.width / 2.5, size.height, size.width / 3, size.height);
    path1.lineTo(size.width / 2, 0);
    path1.lineTo(0, 0);
    Path path2 = Path();
    path2.moveTo(size.width / 3, size.height);
    path2.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width / 2, 0);

    Paint paint1 = Paint()..color = HexColor("#FFAF7E");
    Paint paint2 = Paint()..color = HexColor("#AA83F8");

    canvas.drawPath(path1, paint1);

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BlogNameAndDetails extends StatelessWidget {
  final DataModel blog;

  const BlogNameAndDetails(this.blog);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.85 * MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              blog.title.toString(),
              style: Theme.of(context).textTheme.bodyText1?.merge(
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.normal),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayImage extends StatelessWidget {
  final DataModel item;
  final Function onCaresoulChange;
  final int currentIndex;

  const OverlayImage(this.item, this.onCaresoulChange, this.currentIndex);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        item.contentType == "video"
            ? CustomVideoPlayer(
                blog: item,
              )
            : item.bannerImage.length > 1
                ? Positioned(
                    child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: height * 0.6,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                onCaresoulChange(index);
                              },
                            ),
                            items: item.bannerImage
                                .map<Widget>((item) => Container(
                                      child: Center(
                                          child: Image.network(
                                        item,
                                        fit: BoxFit.cover,
                                        height: height,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                          .toInt()
                                                  : null,
                                            ),
                                          );
                                        },
                                      )),
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: item.bannerImage.map<Widget>((url) {
                              int index = item.bannerImage.indexOf(url);
                              return Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Container(
                                  width: 10.0,
                                  height: 10.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentIndex == index
                                        ? const Color.fromRGBO(0, 0, 0, 0.9)
                                        : const Color.fromRGBO(0, 0, 0, 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ))
                : Positioned.fill(
                    child: Image.network(
                    item.bannerImage[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!.toInt()
                              : null,
                        ),
                      );
                    },
                  )),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(top: 33.0, right: 16.0),
          child: Opacity(
            opacity: 0.6,
            child: ButtonTheme(
              minWidth: 0.07 * width,
              height: 0.04 * height,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.only(
                    right: 9,
                    left: 9,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed('/HomeClonePage', arguments: false);
                },
                child: Wrap(
                  children: [
                    const Icon(
                      Mdi.eye,
                      color: Colors.white,
                      size: 18.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Text(
                        " ${item.viewCount}",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
