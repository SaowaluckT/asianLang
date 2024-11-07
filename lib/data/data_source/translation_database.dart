import 'package:sqflite/sqflite.dart';
import 'dart:async';

import 'package:path/path.dart';

import '../../models/keyword_model.dart';

class TranslationDatabase {
  // กำหนดตัวแปรสำหรับอ้างอิงฐานข้อมูล
  static final TranslationDatabase instance = TranslationDatabase._init();

  // กำหนดตัวแปรฐานข้อมูล
  static Database? _database;

  TranslationDatabase._init();

  Future<Database> get database async {
    // ถ้ามีฐานข้อมูลนี้แล้วคืนค่า
    if (_database != null) return _database!;
    // ถ้ายังไม่มี สร้างฐานข้อมูล กำหนดชื่อ นามสกุล .db
    _database = await _initDB('translator.db');
    // คืนค่าฐานข้อมูล
    print("TranslationDatabase =========> _database: $_database");

    return _database!;
  }

  // ฟังก์ชั่นสร้างฐานข้อมูล รับชื่อไฟล์ที่กำหนดเข้ามา
  Future<Database> _initDB(String filePath) async {

    // หาตำแหน่งที่จะจัดเก็บในระบบ ที่เตรียมไว้ให้
    final dbPath = await getDatabasesPath();

    // ต่อกับชื่อที่ส่งมา จะเป็น path เต็มของไฟล์
    final path = join(dbPath, filePath);

    // สร้างฐานข้อมูล และเปิดใช้งาน หากมีการแก้ไข ให้เปลี่ยนเลขเวอร์ชั่น เพิ่มขึ้นไปเรื่อยๆ
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // สร้างตาราง
  Future _createDB(Database db, int version) async {
    // รูปแบบข้อมูล sqlite ที่รองรับ
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textCanNullType = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // ทำคำสั่งสร้างตาราง
    await db.execute('CREATE TABLE ${KeywordFields.tableBooks} ("${KeywordFields.id}" $idType, "${KeywordFields.word}" $textType, "${KeywordFields.translated}" $textType, "${KeywordFields.createdAt}" $textType, "${KeywordFields.wordLanguageCode}" $textType, "${KeywordFields.translatedLanguageCode}" $textType, "${KeywordFields.voiceRecordPath}" $textCanNullType, "${KeywordFields.notebookName}" $textCanNullType)');
  }

// คำสั่งสำหรับลบข้อมูลทั้งหมด
  Future<int> deleteAll() async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
    // คืนค่าเป็นตัวเลขจำนวนรายการที่มีการเปลี่ยนแปลง
    return db.delete(
      KeywordFields.tableBooks,
    );
  }

  // คำสั่งสำหรับปิดฐานข้อมูล เท่าที่ลองใช้ เราไม่ควรปิด หรือใช้คำสั่งนี้
  // เหมือนจะเป็น bug เพราะถ้าปิดฐานข้อมูล จะอ้างอิงไม่ค่อยได้ ในตัวอย่าง
  // จะไม่ปิดหรือใช้คำสั่งนี้
  Future close() async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
    db.close();
  }

}
