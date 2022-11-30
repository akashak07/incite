import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String url;
  CustomWebView({required this.url});
  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  String? host;
  List<PopupMenuItem>? popupList;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);
    host = uri.host;
    popupList = [
      PopupMenuItem(
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_webViewController != null) {
                  _webViewController!.goBack();
                }
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                if (_webViewController != null) {
                  _webViewController!.goForward();
                }
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {
            Clipboard.setData(
              new ClipboardData(
                text: widget.url,
              ),
            );
            BotToast.showText(
              text: "Url Copied",
            );
          },
          child: Text(
            'Copy Link',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {
            launch(widget.url);
          },
          child: Text(
            'Open in browser',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      body: Container(
        child: Column(
          children: [
            SafeArea(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Spacer(),
                    Text(
                      host!,
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    PopupMenuButton(
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      itemBuilder: (context) {
                        return popupList!.map((e) => e).toList();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.url),
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
              ),
            ),
            /* Expanded(
              child: WebView(
                initialUrl: widget.url,
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
