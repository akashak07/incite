import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as convert;

class CustomVideoPlayer extends StatefulWidget {
  final DataModel? blog;
  const CustomVideoPlayer({Key? key, this.blog}) : super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {
  convert.YoutubePlayerController? controller;
  @override
  void initState() {
    super.initState();
    final videoId = convert.YoutubePlayer.convertUrlToId(
      widget.blog!.videoUrl.toString(),
    );
    controller = convert.YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: const convert.YoutubePlayerFlags(
        autoPlay: true,
      ),
      // params: YoutubePlayerParams(
      //   mute: false,
      //   autoPlay: true,
      //   origin: videoId.toString(),
      //   enableJavaScript: false,
      //   enableCaption: false,
      //   showControls: true,
      // ),
    );
    controller?.load(videoId.toString());
  }

  vidoPlayPauseTogal(bool isPause) {
    if (isPause) {
      setState(() {
        print("object stop");
        controller?.pause();
      });
    } else {
      controller?.play();
      print("object play");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // key: Key("${widget.blog!.videoUrl}"),
      onTap: () async {
        if (controller != null) {
          controller!.play();
        } else {
          if (controller != null) {
            controller!.pause();
          }
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: convert.YoutubePlayer(
          controller: controller!,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller?.pause();
  }

  @override
  void deactivate() {
    super.deactivate();
    controller?.pause();
  }

  @override
  void dispose() {
    super.dispose();

    if (controller != null) controller?.pause();
  }
}
