import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeyHolder {
  GlobalKey<ScaffoldState> globalKey = new GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> getGlobalKey() => globalKey;
}

KeyHolder homeKeyHolder = new KeyHolder();
