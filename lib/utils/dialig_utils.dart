import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../presentation/widgets/form_create_notebook_widget.dart';


class DialogUtils {
  static Future<void> showCreateNotepadDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
              ),
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return FormCreateNotebook(
                  constraints: constraints,
                );
              }),
            ),
          ),
        );
      },
    );
  }

  static showDoneAlertDialog(BuildContext context, { String? message}) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: const Text("Done"),
            ),
            content: message != null ?Text(
              message,
            ) : null,
            actions: <Widget>[
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
                },
              ),
            ],
          );
        });
  }
}
