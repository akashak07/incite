import 'package:blog_app/controllers/e_live_new_controller.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;

import '../app_theme.dart';

class LiveNews extends StatefulWidget {
  @override
  _LiveNewsState createState() => _LiveNewsState();
}

class _LiveNewsState extends StateMVC {
  ELiveNewsController? eLiveNewsController;

  _LiveNewsState() : super(ELiveNewsController()) {
    eLiveNewsController = ELiveNewsController();
  }
  int? selectedVideo;
  convert.YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    print("LiveNews");
    eLiveNewsController!.getLiveNews().then((_) {
      setState(() {});
    });
  }

  setVideo() {
    final videoId = convert.YoutubePlayer.convertUrlToId(
      eLiveNewsController!.liveNewsModel![selectedVideo!.toInt()].url
          .toString(),
    );
    _controller = convert.YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const convert.YoutubePlayerFlags(autoPlay: true),
    );
    _controller!.load(videoId.toString());

    // _controller.addListener((event) {
    //   if (event.isReady) {
    //     _controller.play();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).canvasColor,
        leading: GestureDetector(
            onTap: () {
              if (selectedVideo == null) {
                Navigator.pop(context);
              } else {
                selectedVideo = null;
              }
              setState(() {});
            },
            child: Icon(
              Icons.arrow_back,
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
            )),
        title: Text(
          allMessages.value.liveNews.toString(),
          style: TextStyle(
            color: appThemeModel.value.isDarkModeEnabled.value
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      body: eLiveNewsController!.liveNewsModel == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                //video player

                selectedVideo == null
                    ? Container()
                    : VisibilityDetector(
                        key: Key(
                            "${eLiveNewsController!.liveNewsModel![selectedVideo!.toInt()].image}"),
                        onVisibilityChanged: (visibilityInfo) async {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100.0;
                          print(
                              'Widget ${visibilityInfo.key} is $visiblePercentage% visible');
                          if (visiblePercentage == 100.0) {
                            await Future.delayed(const Duration(seconds: 1));
                            if (_controller != null) {
                              _controller!.play();
                            }
                          } else {
                            if (_controller != null) {
                              _controller!.pause();
                            }
                          }
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          child: convert.YoutubePlayer(
                            controller: _controller!,
                            aspectRatio: 16 / 9,
                          ),
                        ),
                      ),
                selectedVideo == null
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              '${Urls.baseServer}upload/company-logo/original/${eLiveNewsController!.liveNewsModel![selectedVideo!.toInt()].image}',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              eLiveNewsController!
                                  .liveNewsModel![selectedVideo!.toInt()]
                                  .companyName
                                  .toString(),
                              style: TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                Expanded(
                  child: ListView.separated(
                    itemCount: eLiveNewsController!.liveNewsModel!.length,
                    separatorBuilder: (context, _) {
                      return const Divider(
                        indent: 2,
                        thickness: 2,
                      );
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVideo = index;
                            setVideo();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Image.network(
                                '${Urls.baseServer}upload/company-logo/original/${eLiveNewsController!.liveNewsModel![index].image}',
                                height: 75,
                                width: 75,
                                fit: BoxFit.cover,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    eLiveNewsController!
                                        .liveNewsModel![index].companyName
                                        .toString(),
                                    style: TextStyle(
                                        color: appThemeModel
                                                .value.isDarkModeEnabled.value
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
    setState(() {
      _controller = null;
    });
  }
}
