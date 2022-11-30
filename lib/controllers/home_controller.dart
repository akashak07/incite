import 'package:blog_app/repository/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../models/blog_category.dart';

class HomeController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  List<BlogCategory>? category = [];

  HomeController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future listenForCategory() async {
    final Stream<BlogCategory> stream = await getCategory();
    stream.listen((BlogCategory _category) {
      print(_category.data.toString());

      category?.add(_category);
    });
  }
}
