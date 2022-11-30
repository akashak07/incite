import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blog_app/helpers/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  BuildContext? context;
  DateTime? currentBackPressTime;

  Helper.of(BuildContext _context) {
    this.context = _context;
  }
  static const List<String> rightHandLang = [ //TODO: add more Right to Left languages
    'ar-eg', // Arabic
    'fa', // Farsi
    'he', // Hebrew
    'ps', // Pashto
    'ur', // Urdu
  ];

  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data']) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data']) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Uri getUri(String path) {
    //String _path = Uri.parse(GlobalConfiguration().getValue('base_url')).path;
    String _path = Uri.parse('${Urls.baseServer}').path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    //Uri uri = Uri(
    //scheme: Uri.parse(GlobalConfiguration().getValue('base_url')).scheme,
    //host: Uri.parse(GlobalConfiguration().getValue('base_url')).host,
    //port: Uri.parse(GlobalConfiguration().getValue('base_url')).port,
    //path: _path + path);
    Uri uri = Uri(
        scheme: Uri.parse('${Urls.baseServer}').scheme,
        host: Uri.parse('${Urls.baseServer}').host,
        port: Uri.parse('${Urls.baseServer}').port,
        path: _path + path);
    return uri;
  }

  static Future launchURL(String url) async {
    print('url is $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
