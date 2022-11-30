import 'dart:async';
import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/e_news.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../app_theme.dart';

class ShowNewsPaper extends StatefulWidget {
  final ENews? enews;

  ShowNewsPaper({this.enews});

  @override
  _ShowNewsPaperState createState() => _ShowNewsPaperState();
}

class _ShowNewsPaperState extends State<ShowNewsPaper> {
  bool _isLoading = true;
  late PDFDocument document;
  String remotePDFpath = "";
  int? curPage, totalPage;

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        remotePDFpath = f.path;
        _isLoading = false;
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url = "${Urls.baseServer}upload/e-paper/pdf/" +
          widget.enews!.pdf.toString();
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");
      print(widget.enews!.pdf);
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  // loadDocument() async {
  //   print(
  //       "${Urls.baseServer}upload/e-paper/pdf/" + widget.enews!.pdf.toString());
  //   try {
  //     document = await PDFDocument.fromURL(
  //       "${Urls.baseServer}upload/e-paper/pdf/" + widget.enews!.pdf.toString(),
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  //   setState(() => _isLoading = false);
  // }

  @override
  Widget build(BuildContext context) {
    print("romotepath:$remotePDFpath");
    final Completer<PDFViewController> _controller =
        Completer<PDFViewController>();
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).canvasColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
            )),
        title: Text(widget.enews!.paperName.toString(),
            style: TextStyle(
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
            )),
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  PDFView(
                    filePath: remotePDFpath,
                    enableSwipe: true,
                    fitEachPage: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: false,
                    defaultPage: 0,
                    onPageChanged: (page, total) {
                      setState(() {
                        print('test onPageChanged $page');
                        curPage = page;
                        totalPage = total;
                      });
                    },

                    onRender: (_pages) {
                      print('test onRender');
                      setState(() {
                        // pages = _pages;
                        // isReady = true;
                      });
                    },
                    onError: (error) {
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    // onPageChanged: (int page, int total) {
                    //   print('page change: $page/$total');
                    // },
                  ),
                  if(totalPage != null)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            ' ${((curPage ?? 0) + 1)} / ${totalPage ?? 0} ',
                            style: TextStyle(color: Colors.black),
                          ))),
                ],
              ),
        // PDFViewer(
        //         document: document,
        //         zoomSteps: 1,
        //         scrollDirection: Axis.vertical,
        //
        //         //uncomment below code to replace bottom navigation with your own
        //         /* navigationBuilder:
        //               (context, page, totalPages, jumpToPage, animateToPage) {
        //             return ButtonBar(
        //               alignment: MainAxisAlignment.spaceEvenly,
        //               children: <Widget>[
        //                 IconButton(
        //                   icon: Icon(Icons.first_page),
        //                   onPressed: () {
        //                     jumpToPage()(page: 0);
        //                   },
        //                 ),
        //                 IconButton(
        //                   icon: Icon(Icons.arrow_back),
        //                   onPressed: () {
        //                     animateToPage(page: page - 2);
        //                   },
        //                 ),
        //                 IconButton(
        //                   icon: Icon(Icons.arrow_forward),
        //                   onPressed: () {
        //                     animateToPage(page: page);
        //                   },
        //                 ),
        //                 IconButton(
        //                   icon: Icon(Icons.last_page),
        //                   onPressed: () {
        //                     jumpToPage(page: totalPages - 1);
        //                   },
        //                 ),
        //               ],
        //             );
        //           }, */
        //       ),
      ),
    );
  }
}
