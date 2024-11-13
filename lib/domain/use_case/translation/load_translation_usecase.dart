

import '../../../data/repository/translate_repository.dart';

class LoadTranslationUseCase {
  TranslateRepository _repository;

  LoadTranslationUseCase(this._repository);

  Future<Map<String, String>> execute() async {
    return await _repository.loadTranslations();
  }
}