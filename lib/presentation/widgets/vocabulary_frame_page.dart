import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_app/presentation/widgets/player_widget.dart';
import 'package:record/record.dart';
import '../../../data/data_source/notebook_database.dart';
import '../../../models/keyword_model.dart';
import '../../../models/notebook_model.dart';
import '../../../utils/dialig_utils.dart';
import 'voice_recoder_widget.dart';

class VocabularyFramePage extends StatefulWidget {
  final KeywordModel vocabulary;
  const VocabularyFramePage({super.key, required this.vocabulary});

  @override
  State<VocabularyFramePage> createState() => _VocabularyFramePageState();
}

class _VocabularyFramePageState extends State<VocabularyFramePage> {
  late KeywordModel _vocabulary;
  final record = AudioRecorder();
  // final TextToSpeech tts = TextToSpeech();
  String? audioPath;
  bool showPlayer = false;
  // flutter_tts
  FlutterTts flutterTts = FlutterTts();
  // TtsState ttsState = TtsState.stopped;

  // player
  // PlayerState? _playerState;
  // Duration? _duration;
  // Duration? _position;

  @override
  void initState() {
    _vocabulary = widget.vocabulary;
    audioPath = widget.vocabulary.voiceRecordPath;
    showPlayer = (widget.vocabulary.voiceRecordPath != null);
    setState(() {});
    getVoiceByLang();
    // player.getCurrentPosition().then(
    //       (value) => setState(() {
    //     _position = value;
    //   }),
    // );

    super.initState();
  }

  Future _updateVoiceRecordDB(String? path) async {
    if (path != null) {
      /* ต้องอัพเดท Notebook DB where หา word ที่ตีงกัน เพิ่มเพิ่ม path */
      KeywordModel data = widget.vocabulary;
      data.voiceRecordPath = path;
      data.notebookName ?? (data.notebookName = NotebookDatabase.defaultNotebookName);
      print("update voice to WordHistoryModel >> $data");

      final notebookDB = await NotebookDatabase.instance.database;
      final resultNotebookDB = await notebookDB.query(
        NotebookFields.tableBooks,
        columns: NotebookFields.values,
        where: '${NotebookFields.name} = ?',
        whereArgs: [data.notebookName],
      ).catchError((onError) {
        print("_insertNotebookDB db.query catchError >> $onError");
      });

      notebookDB.transaction((txn) {
        print("_insertNotebookDB =========> call update!");
        List<NotebookModel> listNotebook = resultNotebookDB.map((json) => NotebookModel.fromJson(json)).toList();
        for (var element in listNotebook) {
          if(element.name == data.notebookName) {
            List<KeywordModel?> newList = element.listWordTransalte?.where((e) => e?.word != data.word).toList() ?? [];
            NotebookModel newNotebook = NotebookModel(
              id: element.id,
              name: element.name,
              createdAt: element.createdAt,
              isDefault: element.isDefault,
              listWordTransalte: [...newList, data],
            );
            print("=========> newNotebook: ${newNotebook.toMap()}");

            txn.update(
              NotebookFields.tableBooks,
              newNotebook.toMap(),
              where: '${NotebookFields.name} = ?',
              whereArgs: [newNotebook.name],
            ).then((value) => print("$value =========> txn.update!!"));

            break;
          }
        }
        // if (resultNotebookDB.isEmpty) {
        //   print("_updateVoiceRecordDB =========> resultNotebookDB not found!");
        //   throw("_updateVoiceRecordDB =========> resultNotebookDB not found!");
        // } else {
        //
        // }

        notebookDB.batch();
        return DialogUtils.showDoneAlertDialog(context, message: "Already updated voice record!");
      });


      /*// Translation DB*/
      // final db = await TranslationDatabase.instance.database;
      // final maps = await db.query(
      //   WordHistoryFields.tableBooks,
      //   columns: WordHistoryFields.values,
      //   where: '${WordHistoryFields.id} = ?',
      //   whereArgs: [data.id],
      // ).catchError((onError) {
      //   print("_updateVoiceRecordDB DBdb.query catchError >> $onError");
      // });
      //
      // print("_updateVoiceRecordDB =========> (isEmpty: ${maps.isEmpty})");
      //
      // if (maps.isEmpty) {
      //   print("_updateVoiceRecordDB =========> data not found!");
      // } else {
      //   print("_updateVoiceRecordDB =========> update!");
      //   try {
      //     await db.update(
      //       WordHistoryFields.tableBooks,
      //       data.toMap(),
      //       where: '${WordHistoryFields.id} = ?',
      //       whereArgs: [data.id],
      //     );
      //   } catch(e) {
      //     print("_updateVoiceRecordDB update catch >> $e");
      //     return;
      //   }
      // }
    }
  }

  Future<String?> getVoiceByLang() async {
    // var languages = await tts.getLanguages();
    // print("getLanguages: $languages");
    // var displayLanguages = await tts.getDisplayLanguages();
    // print("getDisplayLanguages: $displayLanguages");

    // flutter_tts
    await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, [IosTextToSpeechAudioCategoryOptions.allowBluetooth, IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP, IosTextToSpeechAudioCategoryOptions.mixWithOthers], IosTextToSpeechAudioMode.voicePrompt);

    var languages = await flutterTts.getLanguages;
    print("languages: $languages");
    return null;
  }

  Future _speakText(String text) async {
    // final bool? voices = await tts.speak(text);
    // print("Speaker: $voices");

    // flutter_tts
    var result = await flutterTts.speak("Hello World");
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _openRecordVoice() async {
    print('_openRecordVoice!!');

    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.28,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
              ),
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return VoiceRecorderWidget(
                  onStop: (String path) {
                    print('Recorded file path: $path');
                    _updateVoiceRecordDB(path).then((value) {
                      setState(() {
                        audioPath = path;
                        showPlayer = true;
                      });
                    });
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Future _openVoicePlayer() async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.28,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
              ),
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return PlayerWidget(
                  voicePath: audioPath,
                );
              }),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    record.dispose(); // As always, don't forget this one.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _vocabulary.word ?? "widget.vocabulary.name",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _vocabulary.translated ?? "widget.vocabulary.description",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Visibility(
                  visible: audioPath != null,
                  replacement: const Stack(
                    children: [
                      Icon(Icons.mic),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.add_circle_outlined,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic),
                ),
                iconSize: 40,
                onPressed: () async {
                  bool hasPermission = await record.hasPermission();
                  print("record has permission >> $hasPermission");
                  if (showPlayer) {
                    _openVoicePlayer();
                  } else {
                    _openRecordVoice();
                  }

                  // if(await record.isRecording()) {
                  //   await _stopRecordVoice();
                  // } else if(await record.isPaused()) {
                  //   await record.resume();
                  // } else {
                  //   _openRecordVoice();
                  // }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.speaker),
                iconSize: 40,
                onPressed: () {
                  _speakText(_vocabulary.word ?? "");
                },
              ),
              // const SizedBox(width: 16),
              // IconButton(
              //   icon: const Icon(Icons.delete),
              //   onPressed: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
