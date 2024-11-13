

import '../../../data/repository/translate_repository.dart';

class TranslationUseCase {
  TranslateRepository _repository;

  TranslationUseCase(this._repository);

  Future<dynamic> execute(String text, String targetLanguage) {
    return _repository.translate(text, targetLanguage);
  }
}