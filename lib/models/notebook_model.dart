// กำหนดฟิลด์ข้อมูลของตาราง
import 'dart:convert';

import 'keyword_model.dart';



class NotebookFields {
  static String databaseName = "notebooks";
  static String tableBooks = "notebook";

  // สร้างเป็นลิสรายการสำหรับคอลัมน์ฟิลด์
  static final List<String> values = [
    id, name, createdAt, isDefault, listWordTransalte,
  ];

  // กำหนดแต่ละฟิลด์ของตาราง ต้องเป็น String ทั้งหมด
  static const String id = '_id'; // ตัวแรกต้องเป็น _id ส่วนอื่นใช้ชื่อะไรก็ได้
  static const String name = 'name';
  static const String createdAt = 'created_at';
  static const String isDefault = 'is_default';
  static const String listWordTransalte = 'list_words_translate';
}

class NotebookModel {
  int? id;
  String? name;
  String? createdAt;
  bool? isDefault;
  List<KeywordModel?>? listWordTransalte;

  NotebookModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isDefault,
    required this.listWordTransalte,
  });

  NotebookModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    createdAt = json['created_at'];
    isDefault = json['is_default'] != null ? json['is_default'] == 1 ? true : false : false;
    listWordTransalte = [];
    print("NotebookModel.fromJson list_words_translate ==> ${json['list_words_translate']}");

    if(json['list_words_translate'] != null) {
      final decode = jsonDecode(json['list_words_translate']);
      print("decode: ${decode.runtimeType}");
      decode.forEach((element) {
        listWordTransalte?.add(KeywordModel.fromJson(element));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_default'] = (isDefault??false) ? 1 : 0;
    data['list_words_translate'] = <Map<String, dynamic>>[];
    if(listWordTransalte?.isNotEmpty ?? false) {
      data['list_words_translate'] = listWordTransalte?.map((e) => e?.toJson());

    }
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'created_at': createdAt,
      'is_default': (isDefault??false) ? 1 : 0, // SQLite stores booleans as integers
      'list_words_translate': jsonEncode(listWordTransalte?.map((e) => e?.toMap()).toList()), // Serialize the list
    };
  }

  @override
  String toString() {
    return 'NotebookModel{id: $id, name: $name, createdAt: $createdAt, isDefault: $isDefault, listWordTransalte: $listWordTransalte}';
  }
}
