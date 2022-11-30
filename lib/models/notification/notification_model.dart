class NotificationModel {
  String title;
  String body;
  NotificationModel.fromJsonMap(Map<dynamic, dynamic> map)
      : title = map["title"],
        body = map["body"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}
