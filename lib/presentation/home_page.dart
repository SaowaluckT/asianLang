import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/data/services/translate_service.dart';
import 'package:my_app/presentation/dictionary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Intl.message(
            'Dictionary',
            name: 'dictionaryTitle',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, String>>(
              future: TranslateService.loadTranslations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final translationsWithPronunciation = snapshot.data!;
                  return DictionaryPage(
                      translationsWithPronunciation: translationsWithPronunciation);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
