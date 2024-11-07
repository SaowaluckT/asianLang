import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/keyword_model.dart';
import '../../../models/notebook_model.dart';
import '../widgets/vocabulary_frame_page.dart';

class VocabulariesPage extends StatefulWidget {
  final NotebookModel? notebookData;
  const VocabulariesPage({super.key, this.notebookData});

  @override
  State<VocabulariesPage> createState() => _VocabulariesPageState();
}

class _VocabulariesPageState extends State<VocabulariesPage> {
  List<KeywordModel?> _listVocabularies = [];

  @override
  void initState() {
    // _listVocabularies = List.generate(10, (index) => index);
    print("VocabulariesPage initState ==> notebookData: ${widget.notebookData}");
    if(widget.notebookData?.listWordTransalte?.isNotEmpty ?? false) {
      _listVocabularies = widget.notebookData?.listWordTransalte ?? [];
      // setState(() {});
    }
    super.initState();
  }

  // _insertToNotebookDB(BuildContext modalBuildContext, {required String notebookName}) async {
  //   print("_insertNotebookDB =========> started >> _wordTranslated: $_wordTranslated");
  //   if(_wordTranslated == null) {
  //     return showAlertDialog("No have translation");
  //   } else {
  //     WordHistoryModel data = _wordTranslated!;
  //     data.notebookName = notebookName;
  //
  //     NotebookModel notebook = NotebookModel(
  //       id: DateTime.now().millisecondsSinceEpoch,
  //       name: notebookName,
  //       createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
  //       isDefault: false,
  //       listWordTransalte: [data],
  //     );
  //     print("notebook.toMap() =========> ${notebook.toMap()}");
  //
  //     final maps = await _notebookDB?.query(
  //       NotebookFields.tableBooks,
  //       columns: NotebookFields.values,
  //       where: '${NotebookFields.name} = ?',
  //       whereArgs: [notebookName],
  //     ).catchError((onError) {
  //       print("_insertNotebookDB db.query catchError >> $onError");
  //     });
  //     print("_insertNotebookDB db.query >> $maps");
  //
  //     try {
  //       _notebookDB?.transaction((txn) {
  //         if (maps?.isEmpty ??true) {
  //           // Insert new notebook
  //           print("_insertNotebookDB =========> insert!");
  //           txn.insert(
  //               NotebookFields.tableBooks,
  //               notebook.toMap(),
  //               conflictAlgorithm: ConflictAlgorithm.replace
  //           );
  //           // Optionally show a success message
  //           return showAlertDialog("Already update your '$notebookName' notebook");
  //         } else {
  //           print("_insertNotebookDB =========> update!");
  //           List<NotebookModel> listNotebook = maps!.map((json) => NotebookModel.fromJson(json)).toList();
  //           for (var element in listNotebook) {
  //             if(element.name == notebook.name) {
  //               notebook.listWordTransalte = [...?element.listWordTransalte, data];
  //               txn.update(
  //                 NotebookFields.tableBooks,
  //                 notebook.toMap(),
  //                 where: '${NotebookFields.name} = ?',
  //                 whereArgs: [notebook.name],
  //               );
  //               break;
  //             }
  //           }
  //
  //           // txn.update(
  //           //   NotebookFields.tableBooks,
  //           //   notebook.toMap(),
  //           //   where: '${NotebookFields.name} = ?',
  //           //   whereArgs: [notebook.name],
  //           // );
  //           return showAlertDialog("Already update your '$notebookName' notebook");
  //         }
  //       });
  //     } catch(e) {
  //       return showAlertDialog("catch(e): $e");
  //     }
  //
  //
  //
  //     // if (maps?.isEmpty ?? true) {
  //     //   print("_insertNotebookDB =========> insert!");
  //     //   await _notebookDB?.insert(
  //     //     NotebookFields.tableBooks,
  //     //     notebook.toMap(),
  //     //     conflictAlgorithm: ConflictAlgorithm.replace,);
  //     // } else {
  //     //   print("_insertNotebookDB =========> update!");
  //     //   await _notebookDB!.update(
  //     //     NotebookFields.tableBooks,
  //     //     notebook.toMap(),
  //     //     where: '${NotebookFields.name} = ?',
  //     //     whereArgs: [notebookName],
  //     //   );
  //     //   return showAlertDialog("Already update your '$notebookName' notebook");
  //     // }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Intl.message(
            widget.notebookData?.name ?? 'Vocabularies',
            name: 'vocabularies',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _listVocabularies.isEmpty ? const Text("No Data",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ) : GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,// Number of columns
          mainAxisSpacing: 12,
          childAspectRatio: 3/4,
          children: [
            // Your grid items here
            for (var i = 0; i < _listVocabularies.length; i++)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VocabularyFramePage(
                        vocabulary: _listVocabularies[i]!,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 0,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.topLeft,
                          child: Text(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(int.parse(_listVocabularies[i]!.createdAt!))),
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text('${_listVocabularies[i]?.word}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }
}
