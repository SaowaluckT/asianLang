import 'package:flutter/material.dart';
import 'package:my_app/models/keyword_model.dart';
import 'package:my_app/presentation/vocabulary/vocabulary_edit_content_page.dart';


class EditMomoPgae extends StatefulWidget {
  final KeywordModel? keyword;
  final String? wordResultPinyin;
  final int keyOfEditingMemoTypel;

  const EditMomoPgae({super.key, this.keyword, this.wordResultPinyin, required this.keyOfEditingMemoTypel});

  @override
  State<EditMomoPgae> createState() => _EditMomoPgaeState();
}

class _EditMomoPgaeState extends State<EditMomoPgae> {
  final TextEditingController _memoTextController = TextEditingController();

  @override
  void initState() {
    _memoTextController.text = (widget.keyOfEditingMemoTypel == 0) ? (widget.keyword?.memoForWord ?? '') : (widget.keyword?.sharingCommentForWord ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Edit ${VocabularyEditContentPage.editingMemoType[widget.keyOfEditingMemoTypel]} Memo"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Done"),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body:  Column(
        children: [
          /* _memoTextController */
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
              controller: _memoTextController,
              autofocus: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
