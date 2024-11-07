import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/data_source/notebook_database.dart';
import '../../../models/notebook_model.dart';
import '../vocabulary/vocabulary_slider_page.dart';


class NotebookDataPage extends StatefulWidget {
  final NotebookModel notebookModel;
  // final List<NotebookModel> listNotebook;
  const NotebookDataPage({super.key, required this.notebookModel,
    // required this.listNotebook,
  });

  @override
  State<NotebookDataPage> createState() => _NotebookDataPageState();
}

class _NotebookDataPageState extends State<NotebookDataPage> {
  Database? _notebookDB;
  List<NotebookModel> _listNotebook = [];
  NotebookModel? _notebookModel;

  @override
  void initState() {
    // _listNotebook = widget.listNotebook;
    _notebookModel = widget.notebookModel;
    _initNotebookDB();
    super.initState();
  }

  Future _initNotebookDB() async {
    _notebookDB = await NotebookDatabase.instance.database;
    final result = await _notebookDB?.query(
      NotebookFields.tableBooks,
    );
    try {
      if (result?.isEmpty ?? true) {
        NotebookModel notebook = NotebookModel(
          id: DateTime.now().millisecondsSinceEpoch,
          name: "Default notepad",
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          isDefault: true,
          listWordTransalte: [],
        );

        await _notebookDB?.insert(
          NotebookFields.tableBooks,
          notebook.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        _listNotebook = result!.map((json) => NotebookModel.fromJson(json)).toList();
        print("NotebooksPage_initNotebookDB =========> _listNotebook: $_listNotebook");

      }
    } catch(e) {
      rethrow;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => VocabularyEditContentPage(
              //       listNotebook: _listNotebook,
              //       vocabulary: _vocabulary ?? widget.vocabulary,
              //       wordContent: _vocabulary.listWordTransalte![_currentPage-1],
              //     ),
              //   ),
              // );
            },
          ),

        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          if(_notebookModel != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VocabularySliderPage(
                  listNotebook: _listNotebook,
                  vocabulary: _notebookModel!,
                ),
              ),
            );
          }

        },
        // style: ElevatedButton.styleFrom(
        //   surfaceTintColor: Colors.green,
        // ),
        child: const Text("Practice",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16, 0, 16),
            child: Text(
              widget.notebookModel.name ?? (_notebookModel?.name ??''),
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.22,
            // color: Colors.tealAccent,
            child: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < (_notebookModel?.listWordTransalte?.length??0); i++)
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: InkWell(
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => VocabularySliderPage(
                            //         listNotebook: _listNotebook,
                            //         vocabulary: _listNotebook[i],
                            //       ),
                            //     ),
                            //   );
                            // },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.33,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        _notebookModel?.listWordTransalte?[i]?.word ?? 'word',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12,),
                                  Text(
                                    '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
