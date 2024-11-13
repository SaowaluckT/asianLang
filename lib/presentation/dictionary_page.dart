import 'package:flutter/material.dart';
import 'package:my_app/presentation/translation_page.dart';

import '../app/di.dart';
import '../app/routes_manager.dart';
import 'translation/translation_page.dart';



class DictionaryPage extends StatefulWidget {
  final Map<String, String> translationsWithPronunciation;

  const DictionaryPage(
      {super.key, required this.translationsWithPronunciation});

  @override
  _DictionaryPageState createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  String selectedLanguage = 'zh';
  String translateTo = 'en';
  String translateButtonText = 'Translate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0,),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0), // Match border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4), // Shadow color
                    spreadRadius: 4.0, // Blur radius
                    blurRadius: 8.0, // Offset
                  )
                ],
              ),
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your words or sentences here',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.pushNamed(context, Routes.translationRoute);
                },
              ),
            ),

            // const Padding(
            //   padding: EdgeInsets.only(top: 24.0),
            //   child: RenderCardsListNotebooks(),
            // ),


            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: _fetchData,
            //         child: Text(translateButtonText),
            //       ),
            //     ),
            //     PopupMenuButton<String>(
            //       itemBuilder: (context) => [
            //         const PopupMenuItem(
            //           value: 'zh',
            //           child: Text('Chinese'),
            //         ),
            //         const PopupMenuItem(
            //           value: 'en',
            //           child: Text('English'),
            //         ),
            //         const PopupMenuItem(
            //           value: 'th',
            //           child: Text('Thai'),
            //         ),
            //         const PopupMenuItem(
            //           value: 'ja',
            //           child: Text('Japanese'),
            //         ),
            //       ],
            //       onSelected: (String value) {
            //         setState(() {
            //           translateTo = value;
            //           if (value == 'en') {
            //             translateButtonText = 'English';
            //           } else if (value == 'th') {
            //             translateButtonText = 'Thai';
            //           } else if (value == 'ja') {
            //             translateButtonText = 'Japanese';
            //           } else if (value == 'zh') {
            //             translateButtonText = 'Chinese';
            //           }
            //         });
            //       },
            //     ),
            //   ],
            // ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           _searchResult ?? '',
            //           style: const TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontSize: 20,
            //           ),
            //         ),
            //         SizedBox(height: 10),
            //         Text(
            //           _searchPronunciation ?? '',
            //           style: TextStyle(
            //             fontSize: 16,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}