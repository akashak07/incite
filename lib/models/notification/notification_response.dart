import 'package:blog_app/models/notification/notification.dart';

class NotificationResponse {
  NotificationModel? notification;
  NotificationDataModel? notificationDataModel;
  NotificationResponse.fromJsonMap(Map<String, dynamic> map) {
    notification = map["data"] != null
        ? NotificationModel.fromJsonMap(map["data"])
        : map != null
            ? NotificationModel.fromJsonMap(map['aps']['alert'])
            : null;
    notificationDataModel = (map["data"] != null
        ? NotificationDataModel.fromJsonMap(map["data"])
        : map != null
            ? NotificationDataModel.fromJsonMap(map)
            : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['data'] = notification == null ? null : notification?.toJson();

    return data;
  }
}
