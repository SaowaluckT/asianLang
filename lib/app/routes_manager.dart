import 'package:flutter/material.dart';
import 'package:my_app/presentation/main/main_page.dart';

import '../presentation/home/home_page.dart';
import '../presentation/splash/splash.dart';
import '../presentation/translation/translation_page.dart';
import 'di.dart';

class Routes {
  static const String splashRoute = "/";
  static const String mainRoute = "/main";
  static const String homeRoute = "/home";
  static const String translationRoute = "/translation";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case Routes.mainRoute:
        initHomeModule();
        return MaterialPageRoute(builder: (_) => const MainPage());
        case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
        case Routes.translationRoute:
          initTranslationModule();
          return MaterialPageRoute(builder: (_) => const TranslationPage());
      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text("No route found"),
              ),
              body: const Center(
                child: Text("No route found"),
              ),
            ));
  }
}
