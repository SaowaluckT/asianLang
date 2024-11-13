import 'dart:async';

import 'package:my_app/presentation/base/base_viewmodel.dart';

import '../../domain/use_case/translation/load_translation_usecase.dart';

class HomeViewModel extends BaseViewModel {
  LoadTranslationUseCase _loadTranslationUseCase;

  HomeViewModel(
    this._loadTranslationUseCase,
  );

  @override
  void start() {
    // TODO: implement start
  }

  Future<Map<String, String>> loadTranslation() async {
    return await _loadTranslationUseCase.execute();
  }

  @override
  void dispose() {
  }
}
