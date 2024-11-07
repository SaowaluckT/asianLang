import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_prefs.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  final sharedPres = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPres);
  instance.registerLazySingleton<AppPreferences>(() => AppPreferences(instance()));
}