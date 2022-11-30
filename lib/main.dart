import 'package:blog_app/app_theme.dart';
import 'package:blog_app/models/app_model.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:blog_app/route_generator.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:global_configuration/global_configuration.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/user_controller.dart';
import 'helpers/helper.dart';
import 'helpers/shared_pref_utils.dart';
import 'models/blog_category.dart';
import 'models/language.dart';
import 'models/setting.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  //REMOVED FOR WEB BUILD
  // MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyCQw148jvkCeortzo5oiWM8RSiWPWlbAJY",
    appId: "1:399479013826:web:aa83319a61649efabb165b",
    messagingSenderId: "399479013826",
    projectId: "incite-90ab3",
  ),
  );

  try {
    GetIt.instance.registerSingleton<SharedPreferencesUtils>(
        await SharedPreferencesUtils.getInstance() as SharedPreferencesUtils);
    await GlobalConfiguration().loadFromAsset("app_settings");
    getCurrentFontSize();
    getDataFromSharedPrefs();
    getCurrentUser().then((value) {
      if (currentUser.value.auth != null) {
        currentUser.value.isNewUser = false;
      }
    });
    // await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('error happened $e');
  }

  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AppProvider(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

chackNoti() async {
  final prefs = await SharedPreferences.getInstance();
  String? notiData = prefs.getString('notification');
  //It's manage navigation for active state & sleep state
  WidgetsBinding.instance.addPostFrameCallback((_) {
    onSelectNotification(notiData ?? 'null');
  });
}

class _MyAppState extends State<MyApp> {
  List<Setting> settingList = [];
  List<Blog> blogList = [];

  @override
  void initState() {
    super.initState();
    chackNoti();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: languageCode,
        builder: (context, Language langue, child) {
          print("languageCode ${langue.name ?? ""}");

          return ValueListenableBuilder(
            valueListenable: appThemeModel,
            builder: (context, AppModel value, child) {
              final botToastBuilder = BotToastInit();
              print("appThemeModel $appThemeModel");
              return MaterialApp(
                navigatorKey: navigatorKey,
                initialRoute:
                    '/SplashScreen', //_userLog ? '/LoadSwipePage' : '/AuthPage',
                onGenerateRoute: RouteGenerator.generateRoute,
                // builder: BotToastInit(), //1. call BotToastInit
                builder: (context, child) {
                  child = botToastBuilder(context, child);
                  child = Directionality(
                    textDirection:
                        Helper.rightHandLang.contains(langue.language)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    child: child,
                  ); //do something

                  return child;
                },
                navigatorObservers: [BotToastNavigatorObserver()],
                debugShowCheckedModeBanner: false,
                theme: value.isDarkModeEnabled.value
                    ? getDarkThemeData()
                    : getLightThemeData(),
              );
            },
          );
        });
  }
}
