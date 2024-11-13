import 'package:get_it/get_it.dart';
import 'package:my_app/domain/use_case/translation/load_translation_usecase.dart';
import 'package:my_app/domain/use_case/translation/translation_pinyin_usecase.dart';
import 'package:my_app/domain/use_case/translation/translation_usecase.dart';
import 'package:my_app/presentation/home/home_viewmodel.dart';
import 'package:my_app/presentation/translation/translation_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_prefs.dart';

final instance = GetIt.instance;

Future<void> initAppModule() async {
  final sharedPres = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPres);
  instance.registerLazySingleton<AppPreferences>(() => AppPreferences(instance()));
}

initHomeModule() {
  instance.registerFactory<HomeViewModel>(() => HomeViewModel(instance()));
}

initTranslationModule() {
  if (!GetIt.I.isRegistered<TranslationUseCase>()) {
    instance.registerFactory<TranslationUseCase>(() => TranslationUseCase(instance()));
  }

  if (!GetIt.I.isRegistered<LoadTranslationUseCase>()) {
    instance.registerFactory<LoadTranslationUseCase>(() => LoadTranslationUseCase(instance()));
  }

  if (!GetIt.I.isRegistered<TranslationToPinyinUseCase>()) {
    instance.registerFactory<TranslationToPinyinUseCase>(() => TranslationToPinyinUseCase(instance()));
  }

  instance.registerFactory<TranslationViewModel>(() => TranslationViewModel(
    instance(),
    instance(),
    instance(),
  ));
}

