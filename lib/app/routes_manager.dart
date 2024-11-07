import 'package:flutter/material.dart';
import 'package:my_app/presentation/main/main_page.dart';

import '../presentation/splash/splash.dart';

class Routes {
  static const String splashRoute = "/";
  static const String mainRoute = "/main";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case Routes.mainRoute:
        return MaterialPageRoute(builder: (_) => const MainPage());
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
