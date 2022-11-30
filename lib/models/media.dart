import 'package:global_configuration/global_configuration.dart';

class Media {
  String? id;
  String? name;
  String? url;
  String? thumb;
  String? icon;
  String? size;

  Media() {
    url =
        "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
    thumb =
        "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
    icon =
        "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
  }

  Media.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      url = jsonMap['url'];
      thumb = jsonMap['thumb'];
      icon = jsonMap['icon'];
      size = jsonMap['formated_size'];
    } catch (e) {
      url =
          "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
      thumb =
          "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
      icon =
          "${GlobalConfiguration().get('base_url')}dist/images/default.jpg";
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
