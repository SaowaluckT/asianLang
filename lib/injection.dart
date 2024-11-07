import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_prefs.dart';
import 'data/network/app_api.dart';
import 'data/network/dio_factory.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async => $initGetIt(getIt);

// class $initGetIt {
//   $initGetIt(getIt) {
//   }
// }

$initGetIt(getIt) async {
  print("injection initGetIt");
  final sharedPres = await SharedPreferences.getInstance();
  // getIt.registerLazySingleton<SharedPreferences>(() => sharedPres);
  // getIt.registerLazySingleton<AppPreferences>(() => AppPreferences(getIt));
  //
  // getIt.registerLazySingleton<DioFactory>(() => DioFactory(getIt));
  // getIt.registerLazySingleton<AppServiceClient>(() => AppServiceClient(getIt));
  //
  // final di = getIt<DioFactory>().getDio();
}

