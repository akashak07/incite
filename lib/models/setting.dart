import '../models/media.dart';
import 'package:flutter/material.dart';

class Setting {
  String? appName;
  String? appImage;
  String? appSubtitle;

  Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = jsonMap['app_name'] != null ? jsonMap['app_name'] : '';
      appImage = jsonMap['app_image'] != null ? jsonMap['app_image'] : '';
      appSubtitle =
          jsonMap['app_subtitle'] != null ? jsonMap['app_subtitle'] : '';
    } catch (e) {
      appName = '';
      appImage = '';
      appSubtitle = '';
    }
  }

}
