import '../services/translate_service.dart';

abstract class TranslateRepository {
  Future<String> translate(String text, String targetLanguage);
  Future<Map<String, String>> loadTranslations();
  Future<String> translateToPinyin(String text,
      [String? targetLanguage]);
}

class TranslateImplementer implements TranslateRepository {
  TranslateService _service;
  TranslateImplementer(this._service);

  @override
  Future<String> translate(String text, String targetLanguage) async {
    return await _service.translate(
      text, targetLanguage
    );
  }

  @override
  Future<Map<String, String>> loadTranslations() async {
    return await _service.loadTranslations();
  }

  @override
  Future<String> translateToPinyin(String text, [String? targetLanguage]) async {
    return await _service.translateToPinyin(
      text,
      targetLanguage,
    );
  }
}