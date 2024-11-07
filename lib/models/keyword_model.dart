// กำหนดฟิลด์ข้อมูลของตาราง
class KeywordFields {
  static String tableBooks = "words_history";

  // สร้างเป็นลิสรายการสำหรับคอลัมน์ฟิลด์
  static final List<String> values = [
    id, word, translated, createdAt, wordLanguageCode, translatedLanguageCode, notebookName
  ];

  // กำหนดแต่ละฟิลด์ของตาราง ต้องเป็น String ทั้งหมด
  static const String id = '_id'; // ตัวแรกต้องเป็น _id ส่วนอื่นใช้ชื่อะไรก็ได้
  static const String word = 'word';
  static const String translated = 'translated';
  static const String createdAt = 'created_at';
  static const String wordLanguageCode = 'word_language_code';
  static const String translatedLanguageCode = 'translated_language_code';
  static const String voiceRecordPath = 'voice_record_path';
  static const String notebookName = 'notebook_name';
  static const String memoForWord = 'memo_for_word';
  static const String sharingCommentForWord = 'sharin_comment_for_word';
}

class KeywordModel {
  int? id;
  String? word;
  String? translated;
  String? createdAt;
  String? wordLanguageCode;
  String? translatedLanguageCode;
  String? voiceRecordPath;
  String? notebookName;
  String? memoForWord;
  String? sharingCommentForWord;

  KeywordModel({
    required this.word,
    required this.id,
    required this.translated,
    required this.createdAt,
    required this.wordLanguageCode,
    required this.translatedLanguageCode,
    required this.voiceRecordPath,
    required this.notebookName,
    required this.memoForWord,
    required this.sharingCommentForWord,

  });

  KeywordModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    word = json['word'];
    translated = json['translated'];
    createdAt = json['created_at'];
    wordLanguageCode = json['word_language_code'];
    translatedLanguageCode = json['translated_language_code'];
    voiceRecordPath = json['voice_record_path'];
    notebookName = json['notebook_name'];
    memoForWord = json['memo_for_word'];
    sharingCommentForWord = json['sharin_comment_for_word'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['word'] = word;
    data['translated'] = translated;
    data['created_at'] = createdAt;
    data['word_language_code'] = wordLanguageCode;
    data['translated_language_code'] = translatedLanguageCode;
    data['voice_record_path'] = voiceRecordPath;
    data['notebook_name'] = notebookName;
    data['memo_for_word'] = memoForWord;
    data['sharin_comment_for_word'] = sharingCommentForWord;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'word': word,
      'translated': translated,
      'created_at': createdAt,
      'word_language_code': wordLanguageCode,
      'translated_language_code': translatedLanguageCode,
      'voice_record_path': voiceRecordPath,
      'notebook_name': notebookName,
      'memo_for_word': memoForWord,
      'sharin_comment_for_word': sharingCommentForWord
    };
  }

  @override
  String toString() {
    return 'KeywordModel{id: $id, word: $word, translated: $translated, createdAt: $createdAt, wordLanguageCode: $wordLanguageCode, translatedLanguageCode: $translatedLanguageCode, voiceRecordPath: $voiceRecordPath, notebookName: $notebookName, memoForWord: $memoForWord, sharingCommentForWord: $sharingCommentForWord}';
  }
}
