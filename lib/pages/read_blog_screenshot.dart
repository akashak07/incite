import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class ReadBlogScreenshot extends StatefulWidget {
  final DataModel item;
  const ReadBlogScreenshot(this.item);

  @override
  _ReadBlogScreenshotState createState() => _ReadBlogScreenshotState();
}

class _ReadBlogScreenshotState extends State<ReadBlogScreenshot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Image.network(
            widget.item.bannerImage[0],
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  widget.item.blogCategory != null
                      ? Wrap(
                          children: [
                            ...widget.item.blogCategory!
                                .map((e) => Text(e.category!.name.toString()))
                                .toList()
                          ],
                        )
                      : Text(
                          widget.item.title ?? 'title',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Text(
                      parse(widget.item.description ?? "").body?.text ?? 'disc',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w100),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/google_play.png',
                        height: 50,
                        width: 75,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'assets/img/appstore_icon.png',
                        height: 50,
                        width: 75,
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/img/appicon.png',
                        height: 60,
                        width: 50,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/img/incite.png',
                        height: 50,
                        width: 100,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
