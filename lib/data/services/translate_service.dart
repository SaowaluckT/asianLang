import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lpinyin/lpinyin.dart';

 class TranslateService {
  static TranslateService _translateService = TranslateService._internal();

  TranslateService._internal() {
    _translateService = this;
  }

  factory TranslateService() => _translateService;
// class TranslateService {
//   TranslateService._();

  Future<String> translate(String text, String targetLanguage) async {
    const String apiKey = 'AIzaSyDOGjOQWiThJxdjiaKtaKFRf5PLasu_A3I';
    const String apiUrl =
        'https://translation.googleapis.com/language/translate/v2';
    final Uri uri =
        Uri.parse('$apiUrl?key=$apiKey&q=$text&target=$targetLanguage');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String translatedText =
            data['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {
        throw Exception('Failed to load translation');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> translateToPinyin(String text,
      [String? targetLanguage]) async {
    // Translate Chinese text to Pinyin using the lpinyin library
    // String pinyin =  PinyinHelper.getPinyinE(text, format: PinyinFormat.WITH_TONE_MARK);
    // print("Output: $pinyin");
    return PinyinHelper.getPinyin(text,
        separator: ' ', format: PinyinFormat.WITHOUT_TONE);
  }

  Future<Map<String, String>> loadTranslations() async {
    try {
      // โหลดข้อมูลจากไฟล์ JSON
      final jsonFile = await rootBundle.loadString('assets/readthai.json');

      // แปลงข้อมูล JSON เป็น Map<String, String>
      final Map<String, dynamic> translationsMap = json.decode(jsonFile);

      // เพิ่มข้อมูลคำอ่านลงใน Map ที่จะส่งกลับ
      final Map<String, String> translationsWithPronunciation = {};
      translationsMap.forEach((key, value) {
        translationsWithPronunciation[key] =
            '$value'; // ไม่ต้องเพิ่ม Pinyin ในขณะนี้
      });

      return translationsWithPronunciation;
    } catch (e) {
      // กรณีเกิดข้อผิดพลาดในการโหลดหรือแปลง JSON
      debugPrint('Error loading translations: $e');
      return {}; // ส่งค่าว่างกลับให้ไปแสดงผลแทน
    }
  }

  Future<String> translateToEnglish(String text) async {
    // Translate Thai text to English
    try {
      final String translatedText =
          await translate(text, 'en');
      return translatedText;
    } catch (e) {
      throw Exception('Error translating to English: $e');
    }
  }
}
