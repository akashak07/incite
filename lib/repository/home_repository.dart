import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home.dart';
import '../models/blog_category.dart';
import '../helpers/helper.dart';

Future<Stream<Home>> getBlog() async {
  Uri uri = Helper.getUri('api/blog-list');

  Map<String, dynamic> _queryParams = {};
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(
      http.Request(
        'get',
        uri,
      ),
    );
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String,dynamic>))
        .expand((data) => (data as List))
        .map((data) => Home.fromJSON(data));
  } catch (e) {
    return new Stream.value(new Home.fromJSON({}));
  }
}

Future<Stream<BlogCategory>> getCategory() async {
  Uri uri = Helper.getUri('api/blog-category-list');
  Map<String, dynamic> _queryParams = {};
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .expand((data) => (data as List))
        .map((data) => BlogCategory.fromMap(json.decode(data)));
  } catch (e) {
    return new Stream.value(new BlogCategory());
  }
}
