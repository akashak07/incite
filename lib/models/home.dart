import '../models/media.dart';

class Home {
  String? id;
  String? title;
  String? short_description;
  String? description;
  String? author_name;
  String? category_name;
  Media? thumb_image;

  Home(
      {required String title,
      required String author_name,
      required String image,
      required String description,
      required int index,
      required String time});

  Home.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      title = jsonMap['title'];
      short_description = jsonMap['short_description'];
      description = jsonMap['description'];
      author_name = jsonMap['author_name'];
      category_name = jsonMap['category_name'];
      thumb_image =
          jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
              ? Media.fromJSON(jsonMap['media'][0])
              : new Media();
    } catch (e) {
      id = '';
      title = '';
      short_description = '';
      description = '';
      author_name = '';
      category_name = '';
      thumb_image = new Media();
    }
  }
}
