import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/presentation/resources/color_manager.dart';
import 'package:sqflite/sqflite.dart';
import '../../../data/data_source/notebook_database.dart';
import '../../../models/notebook_model.dart';
import '../../../utils/dialig_utils.dart';
import 'notebook_data_page.dart';

class NotebooksPage extends StatefulWidget {
  const NotebooksPage({super.key});

  @override
  State<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  Database? _notebookDB;
  List<NotebookModel> _listNotebook = [];

  @override
  void initState() {
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
    } catch (e) {
      rethrow;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Intl.message(
            'Notebooks',
            name: 'notebooks',
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                DialogUtils.showCreateNotepadDialog(context);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(
                16,
              ),
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns in the grid
                  crossAxisSpacing: 10.0, // Spacing between columns
                  mainAxisSpacing: 10.0, // Spacing between rows
                ),
                itemCount: _listNotebook.length, // Number of items in your data list
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      print("Notebook name >> ${_listNotebook[i].name}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotebookDataPage(
                            notebookModel: _listNotebook[i],
                            // listNotebook: _listNotebook,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.33,
                      decoration: BoxDecoration(
                        color: ColorManager.card,
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
                                _listNotebook[i].name ?? 'Note',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'vocabulary: ${_listNotebook[i].listWordTransalte?.length}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
