import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/keyword_model.dart';
import 'package:my_app/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

import '../../app/di.dart';
import '../../data/data_source/notebook_database.dart';
import '../../data/data_source/translation_database.dart';
import '../../models/notebook_model.dart';
import '../../utils/debouncer.dart';
import '../../utils/dialig_utils.dart';
import 'translation_viewmodel.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TranslationViewModel _viewModel = instance<TranslationViewModel>();
  final _debounce = Debouncer<String>(const Duration(milliseconds: 450));
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _searchResult;
  String selectedLanguage = 'en';
  String translateTo = 'zh';
  String translateButtonText = 'Translate';
  String? _searchPronunciation;
  String? _searchResultPinyin;
  List<KeywordModel> _listWordHistory = [];
  List<NotebookModel> _listNotebook = [];
  KeywordModel? _wordTranslated;
  Database? _notebookDB;

  @override
  void initState() {
    bind();
    _initNotebookDB();
    getWordHistoryDB();
    super.initState();
  }

  bind() {
    _viewModel.start();
  }

  _onChangeTranslation() {
    _searchController.addListener(() {
      _debounce.call((searchText) {
        // Your logic to handle search based on searchText
        print('Searching for: $searchText');
        if (searchText.isNotEmpty) {
          _fetchData().then((value) => _insertToHistoryDB());
          // _insertToHistoryDB();
        }
      }, _searchController.text);
    });
  }

  Future<void> _fetchData() async {
    String searchWord = _searchController.text;
    _viewModel.setText(searchWord);
    try {
      // Fetch translation
      _viewModel.setLanguageCode(translateTo);
      final String translatedText = await _viewModel.translateText();
      Map<String, String> translationsWithPronunciation =
          await _viewModel.loadTranslation();
      _searchResultPinyin = await _viewModel.translationToPinyin(
        searchWord,
      );

      print("translatePinyin: $_searchResultPinyin");
      // Get pronunciation for the search word
      final pronunciation = translationsWithPronunciation[searchWord];

      // Check if the pronunciation is available
      if (pronunciation != null) {
        setState(() {
          _searchResult = translatedText;
          _searchPronunciation = pronunciation;
        });
      } else {
        // Translate the search word to English to find its pronunciation
        final String englishTranslation = await _viewModel.translateText();
        final String? englishPronunciation =
            translationsWithPronunciation[englishTranslation];
        if (englishPronunciation != null) {
          setState(() {
            _searchResult = translatedText;
            _searchPronunciation = englishPronunciation;
          });
        } else {
          setState(() {
            _searchResult = translatedText;
            _searchPronunciation = '';
          });
        }
      }
    } catch (e) {
      // Handle errors
      setState(() {
        _searchResult = 'Error: $e';
        _searchPronunciation = '';
      });
    }
  }

  // คำสั่งสำหรับเพิ่มข้อมูลใหม่ คืนค่าเป็น book object ที่เพิ่มไป
  _insertToHistoryDB() async {
    if (_searchController.text.isNotEmpty && _searchResult != null) {
      KeywordModel word = KeywordModel(
          id: DateTime.now().millisecondsSinceEpoch,
          word: _searchController.text,
          translated: _searchResult,
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          wordLanguageCode: selectedLanguage,
          translatedLanguageCode: translateTo,
          voiceRecordPath: null,
          notebookName: null,
          memoForWord: null,
          sharingCommentForWord: null);
      print("_insertToHistory WordHistoryModel >> $word");

      _wordTranslated = word;

      final db =
          await TranslationDatabase.instance.database; // อ้างอิงฐานข้อมูล
      final maps = await db.query(
        KeywordFields.tableBooks,
        columns: KeywordFields.values,
        where: '${KeywordFields.word} = ?',
        whereArgs: [_searchController.text],
      ).catchError((onError) {
        print("_insertToHistory DBdb.query catchError >> $onError");
      });

      print("_insertToHistoryDB =========> (isEmpty: ${maps.isEmpty})");

      if (maps.isEmpty) {
        print("_insertToHistoryDB =========> insert!");
        await db.insert(KeywordFields.tableBooks, word.toMap());
      } else {
        print("_insertToHistoryDB =========> update!");
        await db.update(
          KeywordFields.tableBooks,
          word.toMap(),
          where: '${KeywordFields.word} = ?',
          whereArgs: [_searchController.text],
        );
      }
    }
  }

  getWordHistoryDB() async {
    final db = await TranslationDatabase.instance.database; // อ้างอิงฐานข้อมูล
    // กำหนดเงื่อนไขต่างๆ รองรับเงื่อนไขและรูปแบบของคำสั่ง sql ตัวอย่าง
    // ใช้แค่การจัดเรียงข้อมูล
    const orderBy = '${KeywordFields.id} DESC';
    final result = await db.query(KeywordFields.tableBooks, orderBy: orderBy);

    if (result.isNotEmpty) {
      // ข้อมูลในฐานข้อมูลปกติเป็น json string data เวลาสั่งค่ากลับต้องทำการ
      // แปลงข้อมูล จาก json ไปเป็น object กรณีแสดงหลายรายการก็ทำเป็น List
      _listWordHistory =
          result.map((json) => KeywordModel.fromJson(json)).toList();
      setState(() {});
    }
  }

  Future _initNotebookDB() async {
    print("_initNotebookDB =========> start!!");
    _notebookDB = await NotebookDatabase.instance.database;

    NotebookModel notebook = NotebookModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: NotebookDatabase.defaultNotebookName,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      isDefault: true,
      listWordTransalte: [],
    );
    print("_initNotebookDB =========> notebook.toMap(): ${notebook.toMap()}");

    final result = await _notebookDB?.query(
      NotebookFields.tableBooks,
    );
    print("_initNotebookDB =========> table notebook result: $result");

    if (result?.isEmpty ?? true) {
      await _notebookDB?.insert(
        NotebookFields.tableBooks,
        notebook.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _listNotebook =
          result!.map((json) => NotebookModel.fromJson(json)).toList();
    }
  }

  _insertToNotebookDB(BuildContext modalBuildContext,
      {required String notebookName}) async {
    print(
        "_insertNotebookDB =========> started >> _wordTranslated: $_wordTranslated");
    if (_wordTranslated == null) {
      return showAlertDialog("No have translation");
    } else {
      KeywordModel data = _wordTranslated!;
      data.notebookName = notebookName;

      NotebookModel notebook = NotebookModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: notebookName,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        isDefault: false,
        listWordTransalte: [data],
      );
      print("notebook.toMap() =========> ${notebook.toMap()}");

      final maps = await _notebookDB?.query(
        NotebookFields.tableBooks,
        columns: NotebookFields.values,
        where: '${NotebookFields.name} = ?',
        whereArgs: [notebookName],
      ).catchError((onError) {
        print("_insertNotebookDB db.query catchError >> $onError");
      });
      print("_insertNotebookDB db.query >> $maps");

      try {
        _notebookDB?.transaction((txn) {
          if (maps?.isEmpty ?? true) {
            // Insert new notebook
            print("_insertNotebookDB =========> insert!");
            txn.insert(NotebookFields.tableBooks, notebook.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
            // Optionally show a success message
            return showAlertDialog(
                "Already update your '$notebookName' notebook");
          } else {
            print("_insertNotebookDB =========> update!");
            List<NotebookModel> listNotebook =
                maps!.map((json) => NotebookModel.fromJson(json)).toList();
            for (var element in listNotebook) {
              if (element.name == notebook.name) {
                notebook.listWordTransalte = [
                  ...?element.listWordTransalte,
                  data
                ];
                txn.update(
                  NotebookFields.tableBooks,
                  notebook.toMap(),
                  where: '${NotebookFields.name} = ?',
                  whereArgs: [notebook.name],
                );
                break;
              }
            }

            // txn.update(
            //   NotebookFields.tableBooks,
            //   notebook.toMap(),
            //   where: '${NotebookFields.name} = ?',
            //   whereArgs: [notebook.name],
            // );
            return showAlertDialog(
                "Already update your '$notebookName' notebook");
          }
        });
      } catch (e) {
        return showAlertDialog("catch(e): $e");
      }

      // if (maps?.isEmpty ?? true) {
      //   print("_insertNotebookDB =========> insert!");
      //   await _notebookDB?.insert(
      //     NotebookFields.tableBooks,
      //     notebook.toMap(),
      //     conflictAlgorithm: ConflictAlgorithm.replace,);
      // } else {
      //   print("_insertNotebookDB =========> update!");
      //   await _notebookDB!.update(
      //     NotebookFields.tableBooks,
      //     notebook.toMap(),
      //     where: '${NotebookFields.name} = ?',
      //     whereArgs: [notebookName],
      //   );
      //   return showAlertDialog("Already update your '$notebookName' notebook");
      // }
    }
  }

  showAlertDialog(String message) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: const Text("Alert"),
            ),
            content: Text(
              message,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                textStyle: const TextStyle(
                  color: Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("close"),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _openListNotebooks() {
    return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return LayoutBuilder(builder:
              (BuildContext contextLayout, BoxConstraints constraints) {
            // print("actionList: ${actionList.length}");
            // print(SizeDevice.getHeight(context));
            // print(constraints.maxHeight);
            double maxHeightBox = constraints.maxHeight;
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14.0),
                topLeft: Radius.circular(14.0),
              ),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: maxHeightBox,
                  minHeight: 164.0,
                ),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /* Label */
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Please choose a notebook",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCreateNotepadDialog();
                            },
                            child: const Text(
                              "New",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* Content Item */
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _listNotebook.length,
                        physics: (_listNotebook.length < 4)
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        itemBuilder: (ct, i) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.only(bottom: 8),
                              onPressed: () {
                                _insertToNotebookDB(context,
                                    notebookName: _listNotebook[i].name!);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "${_listNotebook[i].name}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),

                                  // const Spacer(),
                                  // Visibility(
                                  //   visible: e.haveIconCheck ?? false,
                                  //   child: const Icon(
                                  //     Icons.check,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    /* cancel */
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0, top: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              onPressed: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(8.0),
                              minSize: 48.0,
                              child: const Text(
                                "cancel",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  _showCreateNotepadDialog() {
    DialogUtils.showCreateNotepadDialog(context);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(
              double.infinity,
              kToolbarHeight,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    size: 22,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 28),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _selectionLanguageWidget(
                            onSelectedFunction: (String value) {
                              setState(() {
                                selectedLanguage = value;
                              });
                              _fetchData();
                            },
                            label:
                                AppConstants.languages[selectedLanguage] ?? ''),
                        IconButton(
                          padding: const EdgeInsets.only(left: 8, right: 12),
                          icon: const Icon(
                            CupertinoIcons.arrow_right_arrow_left,
                            size: 14,
                            color: Colors.black,
                          ),
                          iconSize: 14,
                          onPressed: () {
                            var selected = selectedLanguage;
                            var to = translateTo;
                            translateTo = selected;
                            selectedLanguage = to;
                            _fetchData();
                            setState(() {});
                          },
                        ),
                        _selectionLanguageWidget(
                          onSelectedFunction: (String value) {
                            setState(() {
                              translateTo = value;
                            });
                            _fetchData();
                          },
                          label: AppConstants.languages[translateTo] ?? '',
                        ),
                      ],
                    ),
                  ),
                ),

                // IconButton(
                //   icon: Icon(Icons.search),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* Star Menu */
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.star_border),
                      onPressed: () {
                        _openListNotebooks();
                      },
                    ),
                  ),
                  /* Input */
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Enter your words or sentences here',
                        ),
                        onChanged: (txt) {
                          _onChangeTranslation();
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (_searchResult?.isNotEmpty ?? false) &&
                        _searchFocusNode.hasFocus,
                    /* History */
                    replacement: Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          left: 16,
                          right: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "History",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 8),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _listWordHistory.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                _listWordHistory[index].word ??
                                                    "$index",
                                          ),
                                          const TextSpan(text: "    "),
                                          TextSpan(
                                            text: _listWordHistory[index]
                                                    .translated ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        FlutterClipboard.copy(
                                                '${_listWordHistory[index].word} (${_listWordHistory[index].translated})')
                                            .then((value) {
                                          // Optional: Show a snackbar or other feedback to the user
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Copied to clipboard')),
                                          );
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /* searchResult */
                    child: Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 32.0,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _searchResult ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _searchPronunciation ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      (_searchResultPinyin?.isNotEmpty ?? false)
                                          ? '($_searchResultPinyin)'
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  FlutterClipboard.copy('$_searchResult')
                                      .then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Copied "$_searchResult" to clipboard')),
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectionLanguageWidget(
      {required Function(String value) onSelectedFunction,
      required String label}) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'zh',
          child: Text('Chinese'),
        ),
        const PopupMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        const PopupMenuItem(
          value: 'th',
          child: Text('Thai'),
        ),
        const PopupMenuItem(
          value: 'ja',
          child: Text('Japanese'),
        ),
      ],
      onSelected: onSelectedFunction,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}
