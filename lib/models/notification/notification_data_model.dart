import 'package:flutter/material.dart';

class NotificationDataModel {
  String title;
  String body;
  Color color;
  NotificationDataModel.fromJsonMap(Map<dynamic, dynamic> map)
      : title = map["title"],
        body = map["body"],
        color = Color(0xff203E78);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['body'] = body;
    data['color'] = color;
    return data;
  }
}
