import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:my_app/app/routes_manager.dart';

import '../presentation/resources/theme_manager.dart';

//todo
class AppDictionary extends StatefulWidget {
  // const MyApp({super.key}); // default constructor
  int appState = 0;
  AppDictionary._internal(); // private named constructor

  static final AppDictionary instance = AppDictionary._internal(); // single instance -- singleton

  factory AppDictionary() => instance; // factory for this  class instance

  @override
  State<AppDictionary> createState() => _AppDictionaryState();
}

class _AppDictionaryState extends State<AppDictionary> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Intl.message('My App', name: 'myAppTitle'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('th', ''),
        Locale('ja', ''),
        Locale('zh', ''),
      ],
      theme: getApplicationTheme(),
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: Routes.splashRoute,
      // home: const MainPage(),
      // home: FutureBuilder<Map<String, String>>(
      //   future: loadTranslations(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const CircularProgressIndicator();
      //     } else if (snapshot.hasError) {
      //       return Text('Error: ${snapshot.error}');
      //     } else {
      //       final translationsWithPronunciation = snapshot.data!;
      //       return DictionaryPage(
      //           translationsWithPronunciation: translationsWithPronunciation);
      //     }
      //   },
      // ),
    );
  }
}
