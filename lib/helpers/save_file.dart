import 'dart:async';
import 'dart:io' as Io;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SaveFile {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<Io.File> getImageFromNetwork(String url) async {
    Io.File file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  Future<String> saveImage(String url) async {
    final file = await getImageFromNetwork(url);
    //retrieve local path for device
    var path = await _localPath;
    Image? image = decodeImage(file.readAsBytesSync());

    Image thumbnail = copyResize(
      image!,
    );
    String location = "$path/${DateTime.now().toUtc().toIso8601String()}.png";
    // Save the thumbnail as a PNG.
    new Io.File(location)..writeAsBytesSync(encodePng(thumbnail));
    return location;
  }
}
