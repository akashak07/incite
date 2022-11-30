import 'dart:convert';

import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:http/http.dart' as http;

class ExampleHomePage extends StatefulWidget {
  final DataModel item;
  ExampleHomePage(this.item);
  @override
  _ExampleHomePageState createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with TickerProviderStateMixin {
  List<DataModel> blogList = [];
  List<String> welcomeImages = [
    "assets/img/budget.png",
    "assets/img/cost.png",
    "assets/img/money.png",
    "assets/img/no.png",
  ];
  @override
  void initState() {
    getLatestBlog();
    super.initState();
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      final msg = jsonEncode({"blog_id": widget.item.id});
      final String url = '${Urls.baseUrl}blogSwipe';
      final client = new http.Client();
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
      print(data);
      final list =
          (data['data'] as List).map((i) => new DataModel.fromMap(i)).toList();
      setState(() {
        print(list);
        blogList = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CardController controller; //Use this to trigger swap.

    return new Scaffold(
      body: new Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: new TinderSwapCard(
            allowVerticalMovement: false,
            swipeUp: false,
            swipeDown: false,
            orientation: AmassOrientation.bottom,
            totalNum: blogList.length,
            stackNum: 3,
            swipeEdge: 4.0,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.width * 2,
            minWidth: MediaQuery.of(context).size.width * 0.8,
            minHeight: MediaQuery.of(context).size.width * 0.8,
            cardBuilder: (context, index) => Card(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: blogList.length != 0
                        ? Image.network(
                            blogList[index].bannerImage[0],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                              .toInt()
                                      : null,
                                ),
                              );
                            },
                          )
                        : Container(),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.6),
                    alignment: Alignment.center,
                    child: Text(
                      blogList[index].title.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ReadBlog',
                            arguments: blogList[index]);
                      },
                      child: Text(allMessages.value.view.toString()),
                    ),
                  ),
                  Positioned(
                    top: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              //child: Image.asset('${welcomeImages[index]}'),
            ),
            cardController: controller = CardController(),
            swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
              /// Get swiping card's alignment
              if (align.x < 0) {
                //Card is LEFT swiping
              } else if (align.x > 0) {
                //Card is RIGHT swiping
              }
            },
            swipeCompleteCallback:
                (CardSwipeOrientation orientation, int index) {
              /// Get orientation & index of swiped card!
            },
          ),
        ),
      ),
    );
  }
}
