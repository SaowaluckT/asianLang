

import '../../../data/repository/translate_repository.dart';

class TranslationToPinyinUseCase {
  TranslateRepository _repository;

  TranslationToPinyinUseCase(this._repository);

  Future<String> execute(String text,
      [String? targetLanguage]) async {
    return await _repository.translateToPinyin(text, targetLanguage);
  }
}