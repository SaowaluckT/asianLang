import 'package:flutter/widgets.dart';

class ExampleLocalizations {
  ExampleLocalizations(this.locale);

  final Locale locale;

  static ExampleLocalizations of(BuildContext context) {
    return Localizations.of<ExampleLocalizations>(
        context, ExampleLocalizations)!;
  }

  static final Map<String, String> _localizedValues = {};

  Future<void> load() async {
    // Load your ARB files based on the locale and populate _localizedValues
    // ใช้โค้ดที่สะดวกตามวิธีที่คุณอยากให้โหลดข้อมูล
  }

  String translate(String key) {
    return _localizedValues[key] ?? key;
  }
}

class ExampleLocalizationsDelegate
    extends LocalizationsDelegate<ExampleLocalizations> {
  const ExampleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'th', 'zh'].contains(locale.languageCode);

  @override
  Future<ExampleLocalizations> load(Locale locale) async {
    final localizations = ExampleLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<ExampleLocalizations> old) =>
      false;
}
