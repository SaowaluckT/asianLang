import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../../data/data_source/notebook_database.dart';
import '../../../data/services/translate_service.dart';
import '../../../models/keyword_model.dart';
import '../../../models/notebook_model.dart';
import '../../../utils/debouncer.dart';
import '../../../utils/dialig_utils.dart';
import 'edit_memo_page.dart';

class VocabularyEditContentPage extends StatefulWidget {
  static const Map<int, String> editingMemoType = <int, String>{0: "Front", 1: "Share"};

  final List<NotebookModel> listNotebook;
  final NotebookModel notebookVocabulary;
  final KeywordModel? keywordContent;

  const VocabularyEditContentPage({super.key, required this.listNotebook, required this.notebookVocabulary, required this.keywordContent});

  @override
  State<VocabularyEditContentPage> createState() => _VocabularyEditContentPageState();
}

class _VocabularyEditContentPageState extends State<VocabularyEditContentPage> with SingleTickerProviderStateMixin {
  final _debounce = Debouncer<String>(const Duration(milliseconds: 450));
  final TextEditingController _resultTextController = TextEditingController();
  final TextEditingController _memoTextController = TextEditingController();
  NotebookModel? _notebookVocabulary;
  String? _wordResultPinyin;
  int _keyOfEditingMemoType = 0;
  /* keyword */
  final TextEditingController _keywordTextController = TextEditingController();
  final FocusNode _keywordFocusNode = FocusNode();
  KeywordModel? _keyword;

  _onChangeTranslation() {
    _keywordTextController.addListener(() {
      _debounce.call((searchText) {
        print('Searching for: $searchText');
        if (searchText.isNotEmpty) {
          // _fetchData().then((value) => _insertToHistoryDB());
        }
      }, _keywordTextController.text);
    });
  }

  @override
  void initState() {
    _resultTextController.text = widget.keywordContent?.translated ?? '';
    _keywordTextController.text = widget.keywordContent?.word ?? (widget.notebookVocabulary.name ?? '');
    _notebookVocabulary = widget.notebookVocabulary;
    _keyword = widget.keywordContent;
    _memoTextController.text = _keyword?.memoForWord ?? '';
    _keyOfEditingMemoType = 0;
    _fetchData();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    super.initState();
  }

  Future _fetchData() async {
    print("_initNotebookDB =========> start!!");
    final notebookDB = await NotebookDatabase.instance.database;

    final result = await notebookDB.query(
      NotebookFields.tableBooks,
    );
    print("_initNotebookDB =========> table notebook result: $result");
    if (result.isNotEmpty) {
      List<NotebookModel> listNotebook = result.map((json) => NotebookModel.fromJson(json)).toList();
      _notebookVocabulary = listNotebook.firstWhereOrNull((e) => e.id == widget.notebookVocabulary.id);
      _keyword = _notebookVocabulary?.listWordTransalte?.firstWhereOrNull((e) => e?.id == widget.keywordContent?.id);
      _memoTextController.text = _keyword?.memoForWord ?? '';
      setState(() {});
    }
  }

  Future<KeywordModel> _transalator() async {
    KeywordModel data = _keyword!;
    data.notebookName = _keyword?.notebookName ?? "Default notepad";
    String searchWord = _resultTextController.text;
    try {
      // Fetch translation
      final String translatedText = await TranslateService.translate(searchWord, widget.keywordContent!.translatedLanguageCode!);
      final translationsWithPronunciation = await TranslateService.loadTranslations();
      _wordResultPinyin = await TranslateService.translateToPinyin(
        searchWord,
      );

      print("translatePinyin: $_wordResultPinyin");
      data.translated = translatedText;
      data.word = searchWord;
    } catch (e) {
      // Handle errors
      print("_transalator catch (e) >> $e");
    }
    return data;
  }

  Future _updateWordContentDB() async {
    if (_keyword != null) {
      /* ต้องอัพเดท Notebook DB where หา word ที่ตีงกัน เพิ่มเพิ่ม path */
      KeywordModel data = await _transalator();
      // data.word = _textEditingController.text;
      // data.notebookName = widget.wordContent?.notebookName ?? "Default notepad";

      print("_updateWordContentDB >> $data");
      print("_updateVoiceRecordDB =========> data.notebookName >> ${data.notebookName}");

      final notebookDB = await NotebookDatabase.instance.database;

      final resultNotebookDB = await notebookDB.query(
        NotebookFields.tableBooks,
        columns: NotebookFields.values,
        where: '${NotebookFields.name} = ?',
        whereArgs: [data.notebookName],
      ).catchError((onError) {
        print("_updateWordContentDB db.query catchError >> $onError");
      });

      print("_updateVoiceRecordDB =========> resultNotebookDB >> $resultNotebookDB");

      if (resultNotebookDB.isEmpty) {
        print("_updateVoiceRecordDB =========> resultNotebookDB not found!");
        throw ("_updateVoiceRecordDB =========> resultNotebookDB not found!");
      }

      await notebookDB.transaction((txn) {
        List<NotebookModel> listNotebook = resultNotebookDB.map((json) => NotebookModel.fromJson(json)).toList();
        NotebookModel? newNotebook;

        for (NotebookModel element in listNotebook) {
          print("=========> ${element.name} == ${data.notebookName}");

          if (element.name == data.notebookName) {
            newNotebook = element;

            List<KeywordModel?> tempList = element.listWordTransalte ?? [];
            print("=========> tempList: $tempList}");

            List<KeywordModel?> newList = tempList.map((e) => e?.id == widget.keywordContent?.id ? data : e).toList();
            print("=========> newList: $newList}");

            newNotebook.listWordTransalte = newList;
            print("=========> newNotebook: ${newNotebook.toMap()}");

            // for (var w in tempList) {
            //   if(w?.word == widget.wordContent?.word) {
            //
            //     txn.update(
            //       WordHistoryFields.tableBooks,
            //       data.toMap(),
            //       where: '${WordHistoryFields.id} = ?',
            //       whereArgs: [widget.wordContent?.id],
            //     ).then((value) => print("$value =========> _updateWordContentDB.update!!"));
            //     break;
            //   }
            // }
            print("_updateWordContentDB =========> call update!");

            txn.update(
              NotebookFields.tableBooks,
              newNotebook.toMap(),
              where: '${NotebookFields.name} = ?',
              whereArgs: [newNotebook.name],
            ).then((value) => print("$value =========> newNotebook.update!!"));

            break;
          }
        }

        notebookDB.batch();
        print("=========> showDoneAlertDialog}");

        return DialogUtils.showDoneAlertDialog(context, message: "Already updated!");
      });

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  Future _addFrontContentDB(int keyEditingMemo) async {
    if (_keyword != null) {
      print("_addFrontContentDB >> keyEditingMemo: $keyEditingMemo >> ${VocabularyEditContentPage.editingMemoType[keyEditingMemo]}");

      /* ต้องอัพเดท Notebook DB where หา word ที่ตีงกัน เพิ่มเพิ่ม path */
      KeywordModel data = _keyword!;
      if (keyEditingMemo == 0) {
        data.memoForWord = _memoTextController.text;
      } else if (keyEditingMemo == 1) {
        data.sharingCommentForWord = _memoTextController.text;
      }

      print("_addFrontContentDB >> $data");

      final notebookDB = await NotebookDatabase.instance.database;

      final resultNotebookDB = await notebookDB.query(
        NotebookFields.tableBooks,
        columns: NotebookFields.values,
        where: '${NotebookFields.name} = ?',
        whereArgs: [data.notebookName],
      ).catchError((onError) {
        print("_addFrontContentDB db.query catchError >> $onError");
      });

      if (resultNotebookDB.isEmpty) {
        print("_addFrontContentDB =========> resultNotebookDB not found!");
        throw ("_addFrontContentDB =========> resultNotebookDB not found!");
      }

      await notebookDB.transaction((txn) {
        List<NotebookModel> listNotebook = resultNotebookDB.map((json) => NotebookModel.fromJson(json)).toList();
        NotebookModel? newNotebook;
        for (NotebookModel element in listNotebook) {
          print("_addFrontContentDB =========> ${element.name} == ${data.notebookName}");

          if (element.name == data.notebookName) {
            newNotebook = element;

            List<KeywordModel?> tempList = element.listWordTransalte ?? [];
            print("=========> tempList: $tempList}");

            int index = tempList.indexWhere((e) => e?.id == widget.keywordContent?.id);
            print("=========> index: $index}");

            tempList[index] = data;
            print("=========> tempList[index]: ${tempList[index]}}");

            newNotebook.listWordTransalte = tempList;
            print("=========> newNotebook: ${newNotebook.toMap()}");

            print("_addFrontContentDB =========> call update!");

            txn.update(
              NotebookFields.tableBooks,
              newNotebook.toMap(),
              where: '${NotebookFields.name} = ?',
              whereArgs: [newNotebook.name],
            ).then((value) => print("$value =========> newNotebook.update!!"));

            break;
          }
        }

        notebookDB.batch();
        print("=========> showDoneAlertDialog}");

        return DialogUtils.showDoneAlertDialog(context, message: "Already updated!");
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _updateWordContentDB();
            },
            child: const Text("Done"),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /* Input Keyword */
            Container(
              // padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.fromLTRB(16.0, 16, 0, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _keywordTextController,
                        focusNode: _keywordFocusNode,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        decoration: InputDecoration(
                          hintText: _keywordTextController.text ?? '',
                        ),
                        onChanged: (txt) {
                          _onChangeTranslation();
                        },
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _keywordTextController.clear();
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
            ),
            /* Search Result Keyword */
            Container(
              padding: const EdgeInsets.all(
                16.0,
              ),
              margin: const EdgeInsets.all(
                16.0,
              ),
              height: MediaQuery.of(context).size.height * 0.35,
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
                controller: _resultTextController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: _keyword?.word ?? '...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            /* Front Memo and Sharing Memo */
            Container(
              margin: const EdgeInsets.only(left: 16, bottom: 16),
              alignment: Alignment.centerLeft,
              child: const Text("Edit"),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16.0, top: 8, left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: const Icon(Icons.arrow_back_ios_new),
                        //   iconSize: 14,
                        // ),
                        ElevatedButton(
                          onPressed: () {
                            _keyOfEditingMemoType = 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMomoPgae(
                                  keyword: _keyword,
                                  wordResultPinyin: _wordResultPinyin,
                                  keyOfEditingMemoTypel: _keyOfEditingMemoType,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              _keyOfEditingMemoType == 0 ? Colors.blue : Colors.transparent,
                            ),
                            shadowColor: MaterialStateProperty.all<Color>(
                              _keyOfEditingMemoType == 0 ? Colors.blue : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            "Front",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: _keyOfEditingMemoType == 0 ? Colors.white : Colors.black),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _keyOfEditingMemoType = (_keyOfEditingMemoType == 0) ? 1 : 0;
                              _memoTextController.text = (_keyOfEditingMemoType == 0) ? (_keyword?.memoForWord ?? '') : (_keyword?.sharingCommentForWord ?? '');
                            });
                          },
                          icon: const Icon(Icons.swap_horiz),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                        ),
                        // const SizedBox(
                        //   width: 8,
                        // ),
                        ElevatedButton(
                          onPressed: () {
                            _keyOfEditingMemoType = 1;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMomoPgae(
                                  keyword: _keyword,
                                  wordResultPinyin: _wordResultPinyin,
                                  keyOfEditingMemoTypel: _keyOfEditingMemoType,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              _keyOfEditingMemoType == 1 ? Colors.blue : Colors.transparent,
                            ),
                            shadowColor: MaterialStateProperty.all<Color>(
                              _keyOfEditingMemoType == 1 ? Colors.blue : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            "Share",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: _keyOfEditingMemoType == 1 ? Colors.white : Colors.black12),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            _addFrontContentDB(_keyOfEditingMemoType);
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.greenAccent,
                            ),
                          ),
                          child: const Text(
                            "Done",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(color: Colors.greenAccent, width: 1),
                      ),
                      child: TextField(
                        controller: _memoTextController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
