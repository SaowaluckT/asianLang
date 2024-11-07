
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/data_source/notebook_database.dart';
import '../../../models/notebook_model.dart';

class FormCreateNotebook extends StatefulWidget {
  final BoxConstraints constraints;
  const FormCreateNotebook({super.key, required this.constraints});

  @override
  State<FormCreateNotebook> createState() => _FormCreateNotebookState();
}

class _FormCreateNotebookState extends State<FormCreateNotebook> {
  final TextEditingController _textEditingController = TextEditingController();

  String? validateNotepadName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    if (value.length > 12) {
      return 'Name must be 12 characters or less';
    }
    return null; // Validation successful
  }

  Future _createNotebook() async {
    print("_createNotebook =========> start!!");

    try {
      String? errorMessage = validateNotepadName(_textEditingController.text);
      if(errorMessage != null) {
        throw errorMessage;
      }
      Database notebookDB = await NotebookDatabase.instance.database;
      NotebookModel notebook = NotebookModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _textEditingController.text,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        isDefault: true,
        listWordTransalte: [],
      );
      print("_createNotebook =========> notebook.toMap(): ${notebook.toMap()}");

      final result = await notebookDB.query(NotebookFields.tableBooks,
      where: "${NotebookFields.name} =?",
      whereArgs: [_textEditingController.text],
      );
      print("_createNotebook =========> table notebook result: $result");

      if(result.isNotEmpty) {
        throw 'This name uesed already.';
      }
      await notebookDB.insert(NotebookFields.tableBooks, notebook.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    } catch(e) {
      print("_createNotebook =========> catch(e): $e");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString())),
      );

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.constraints.maxHeight,
      width: widget.constraints.maxWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          /* Input */
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: TextFormField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Name of notepad',
                ),
                onChanged: (txt) {
                },
                validator: validateNotepadName,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "cancel",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _createNotebook().then((value) => Navigator.of(context).pop());

                },
                child: const Text(
                  "save",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

  }
}