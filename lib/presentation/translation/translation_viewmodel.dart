import 'dart:async';

import 'package:my_app/presentation/base/base_viewmodel.dart';

import '../../domain/use_case/translation/load_translation_usecase.dart';
import '../../domain/use_case/translation/translation_pinyin_usecase.dart';
import '../../domain/use_case/translation/translation_usecase.dart';

class TranslationViewModel extends BaseViewModel {
  TranslationUseCase _translationUseCase;
  LoadTranslationUseCase _loadTranslationUseCase;
  TranslationToPinyinUseCase _translationToPinyinUseCase;

  String _text = "";
  String _languageCode = "";

  final StreamController _textStreamController =
      StreamController<String>.broadcast();
  final StreamController _languageCodeStreamController =
      StreamController<String>.broadcast();

  TranslationViewModel(
    this._translationUseCase,
    this._loadTranslationUseCase,
    this._translationToPinyinUseCase,
  );

  Sink get getText => _textStreamController.sink;
  Sink get getLanguageCode => _languageCodeStreamController.sink;

  @override
  void start() {
    // TODO: implement start
  }

  setText(String text) {
    _textStreamController.add(text);
  }

  setLanguageCode(String languageCode) {
    _textStreamController.add(languageCode);
  }

  Future<String> translateText() async {
    return await _translationUseCase.execute(_text, _languageCode);
  }

  Future<Map<String, String>> loadTranslation() async {
    return await _loadTranslationUseCase.execute();
  }

  Future<String> translationToPinyin(String text,
      [String? targetLanguage]) async {
    return await _translationToPinyinUseCase.execute(text, targetLanguage);
  }

  @override
  void dispose() {
    _textStreamController.close();
    _languageCodeStreamController.close();
  }
}
