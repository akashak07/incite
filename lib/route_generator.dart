import 'package:blog_app/pages/ads.dart';
import 'package:blog_app/pages/category_post.dart';
import 'package:blog_app/pages/home_page_clone.dart';
import 'package:blog_app/pages/latest_post.dart';
import 'package:blog_app/pages/load_swipeable.dart';
import 'package:blog_app/pages/saved_post.dart';
import 'package:blog_app/pages/tinder_swipe.dart';
import 'package:flutter/material.dart';

import 'package:blog_app/pages/auth.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/read_blog.dart';
import 'package:blog_app/pages/search_page.dart';
import 'package:blog_app/pages/user_profile.dart';
import 'pages/language_selection.dart';
import 'pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    dynamic args = settings.arguments;
    print("screen name ${settings.name}");
    switch (settings.name) {
      case '/SplashScreen':
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case '/LanguageSelection':
        return MaterialPageRoute(
          builder: (context) => LanguageSelection(
            isInHomePage: args,
          ),
        );
      case '/MainPage':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/HomeClonePage':
        return MaterialPageRoute(builder: (context) => HomeClonePage());
      case '/ReadBlog':
        return MaterialPageRoute(builder: (context) => ReadBlog(args));
      case '/AuthPage':
        return MaterialPageRoute(builder: (context) => AuthPage());
      case '/LoadSwipePage':
        return MaterialPageRoute(builder: (context) => LoadSwipePage());
      case '/UserProfile':
        return MaterialPageRoute(builder: (context) => UserProfile(args));
      case '/SearchPage':
        return MaterialPageRoute(builder: (context) => SearchPage());
      case '/LatestPage':
        return MaterialPageRoute(builder: (context) => LatestPage());
      case '/SavedPage':
        return MaterialPageRoute(builder: (context) => SavedPage());
      case '/CategoryPostPage':
        return MaterialPageRoute(builder: (context) => CategoryPostPage(args));
      case '/ReadBlogSwipe':
        return MaterialPageRoute(builder: (context) => ExampleHomePage(args));
      case '/Ads':
        return MaterialPageRoute(builder: (context) => AdsPage());
      default:
        //? in case no route has been specified [for safety]
        return MaterialPageRoute(builder: (context) => AuthPage());
    }
  }
}
