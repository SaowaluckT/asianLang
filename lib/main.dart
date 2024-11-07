import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'app/app.dart';
import 'injection.dart';
import 'l10n/appmessages_all_locales.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  await initializeMessages('en', 'lib/l10n'); // Add 'en' locale
  await initializeMessages('th', 'lib/l10n'); // Add 'th' locale
  await initializeMessages('ja', 'lib/l10n'); // Add 'ja' locale
  await initializeMessages('zh', 'lib/l10n');

  Intl.defaultLocale = 'en';

  /* clear database of search history */
  // await TranslationDatabase.instance.deleteAll();
  // await NotebookDatabase.instance.deleteAll();

  runApp(AppDictionary());
}