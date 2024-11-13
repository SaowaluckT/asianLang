import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/di.dart';
import '../dictionary_page.dart';
import 'home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeViewModel _viewModel = instance<HomeViewModel>();

  _bind() {
    _viewModel.start();
  }

  @override
  void initState() {
    _bind();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
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
              future: _viewModel.loadTranslation(),
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
