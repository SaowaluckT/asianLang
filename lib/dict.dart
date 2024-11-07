import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:intl/intl.dart';

String get exampleMessage => Intl.message(
      'This is an example message',
      name: 'exampleMessage',
      desc: 'Description for translators',
    );

enum Language {
  en,
  zh,
  ja,
  th,
}

class DictionaryDatabase {
  static final DictionaryDatabase instance = DictionaryDatabase._init();
  static Database? _database;

  DictionaryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('dictionary6.db');

    _deleteInitialData(_database!);
    _insertInitialData(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    try {
      await Directory(dbPath).create(recursive: true);
    } catch (_) {}

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    _insertInitialData(db);
  }

  Future<int> insertWord(Word word) async {
    final db = await instance.database;
    return await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final result = await db.query('words');
    return result.map((json) => Word.fromMap(json)).toList();
  }

  void _insertInitialData(Database db) async {
    try {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL,
        lang INTEGER NOT NULL
      );
    ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        word2_id INTEGER NOT NULL,
        priority INTEGER NOT NULL
        );      
    ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS zh_characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        character TEXT NOT NULL,
        pinyin TEXT NOT NULL
      );
    ''');
    } on DatabaseException catch (e) {
      _logError('ERROR-101:');
      _logError(e.toString());
    }

    try {
      await db.transaction((txn) async {
        // comment off 2024.01.07  await txn.delete('words');
        // comment off 2024.01.07  await txn.delete('zh_characters');
        // comment off 2024.01.07  await txn.delete('translations');

        await txn.insert(
          'words',
          {'id': 1, 'word': '你好', 'lang': Language.zh.index},
        );
        await txn.insert(
          'words',
          {'id': 2, 'word': '早上好', 'lang': Language.zh.index},
        );
        await txn.insert(
          'words',
          {'id': 3, 'word': 'Hi', 'lang': Language.en.index},
        );
        await txn.insert(
          'words',
          {'id': 4, 'word': 'Hello', 'lang': Language.en.index},
        );
        await txn.insert(
          'words',
          {'id': 5, 'word': 'Good morning', 'lang': Language.en.index},
        );
        await txn.insert(
          'words',
          {'id': 6, 'word': 'こんにちは', 'lang': Language.ja.index},
        );
        await txn.insert(
          'words',
          {'id': 7, 'word': 'おはよう', 'lang': Language.ja.index},
        );
        await txn.insert(
          'translations',
          {'word_id': 1, 'word2_id': 3, 'priority': 5},
        );
        await txn.insert(
          'translations',
          {'word_id': 1, 'word2_id': 4, 'priority': 5},
        );
        await txn.insert(
          'translations',
          {'word_id': 2, 'word2_id': 5, 'priority': 5},
        );
        await txn.insert(
          'zh_characters',
          {'character': '早', 'pinyin': 'zao3'},
        );
        await txn.insert(
          'zh_characters',
          {'character': '上', 'pinyin': 'shang3'},
        );
        await txn.insert(
          'zh_characters',
          {'character': '好', 'pinyin': 'hao3'},
        );

/*      await txn
          .rawInsert('INSERT INTO words(word, lang) VALUES("Hi", Language.en)');
      await txn.rawInsert(
          'INSERT INTO words(word, lang) VALUES("banana", Language.en)');
      await txn.rawInsert(
          'INSERT INTO words(word, lang) VALUES("carrot", Language.en)');
          */
      });
    } on DatabaseException catch (e) {
      _logError('ERROR-001:');
      _logError(e.toString());
    }
  }

  void _deleteInitialData(Database db) async {
    try {
      await db.transaction((txn) async {
        await txn.execute('DROP TABLE IF EXISTS words;');
        await txn.execute('DROP TABLE IF EXISTS zh_characters;');
        await txn.execute('DROP TABLE IF EXISTS translations;');
      });
    } on DatabaseException catch (e) {
      _logError('ERROR-102:');
      _logError(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchWords() async {
    // Get a reference to the database. ここでget databaseが呼ばれている。
    final db = await instance.database;

    List<Map<String, dynamic>> words = [];

    final _words = await db.query('words');
    words = _words;

    return words;
  }

  Future<List<Word>> searchWords(String searchword) async {
    // Get a reference to the database. ここでget databaseが呼ばれている。
    final db = await instance.database;

    List<Word> words = [];

    var _words = await db.rawQuery(
        'SELECT * FROM words where word like ?', ['%' + searchword + '%']);
    if (_words.isEmpty) {
      _words = await db.rawQuery('SELECT * FROM words where word like ?',
          ['%' + searchword.toLowerCase() + '%']);
    }

    words = _words.map((json) => Word.fromMap(json)).toList();

    return words;
  }

  Future<Map<String, List<Word>>> searchWordsByLang(
      String searchWord, Language fromLang, Language toLang) async {
    // Get a reference to the database. ここでget databaseが呼ばれている。
    final db = await instance.database;

    var _wordsFrom = await db.query('words',
        where: 'word like ? and lang = ?',
        whereArgs: ['%' + searchWord + '%', fromLang.index]);

    if (_wordsFrom.isEmpty) {
      _wordsFrom = await db.query('words',
          where: 'word like ? and lang = ?',
          whereArgs: ['%' + searchWord.toLowerCase() + '%', fromLang.index]);

      if (_wordsFrom.isEmpty) {
        // No 'fromword' is found.
        List<Word> _wwFrom = [
          Word(id: 0, word: 'No word found', lang: 0),
        ];
        List<Word> _wwTo = _wwFrom;
        return {'from': _wwFrom, 'to': _wwTo};
      }
    }

    var wordIds = _wordsFrom.map((word) => word['id']).toList();
    String wordIdsString = wordIds.join(
        ', '); // if there is only one variable, it returns a String without comma.

    /* BUG: IN の中に? を使い、値が「1, 2, 3」のようにカンマ区切りの文字列を入れると、データベースのSQL文が正しく実行されない。
        var _translations = await db.query('translations',
        where: 'word_id IN (?) or word2_id IN (?)',
        whereArgs: [wordIdsString, wordIdsString],
        orderBy: 'priority asc');
            var _translations = await db.rawQuery(
      'SELECT * FROM translations WHERE word_id IN (?) OR word2_id IN (?) ORDER BY priority ASC',
      [wordIdsString, wordIdsString]);
    */
    final String sql = 'SELECT * FROM translations WHERE word_id IN (' +
        wordIdsString +
        ') OR word2_id IN (' +
        wordIdsString +
        ') ORDER BY priority ASC';
    var _translations = await db.rawQuery(sql);

    if (_translations.isEmpty) {
      // No 'translation' is found.
      List<Word> _wwFrom = [
        Word(id: -1, word: 'No translation found', lang: 0),
      ];
      List<Word> _wwTo = _wwFrom;
      return {'from': _wwFrom, 'to': _wwTo};
    }

    wordIds = _translations.map((t) => t['id']).toList();
    wordIdsString = wordIds.join(', ');
    final String sql2 = 'SELECT * FROM words WHERE id IN (' +
        wordIdsString +
        ') AND lang = ' +
        toLang.index.toString();

    var _wordsTo = await db.rawQuery(sql2);

    if (_wordsTo.isEmpty) {
      // No 'toword' is found.
      List<Word> _wwFrom = [
        Word(id: -2, word: 'No word in To lang found', lang: 0),
      ];
      List<Word> _wwTo = _wwFrom;
      return {'from': _wwFrom, 'to': _wwTo};
    }

    List<Word> wordsFrom =
        _wordsFrom.map((json) => Word.fromMap(json)).toList();
    List<Word> wordsTo = _wordsTo.map((json) => Word.fromMap(json)).toList();

    return {'from': wordsFrom, 'to': wordsTo};
  }

  Future<List<ZhCharacter>> fetchZhCharacters() async {
    // Get a reference to the database. ここでget databaseが呼ばれている。
    final db = await instance.database;

    // Query the table for all characters
    final List<Map<String, dynamic>> maps = await db.query('zh_characters');

    // Convert the List<Map<String, dynamic>> into a List<ZhCharacter>
    return List.generate(maps.length, (i) {
      return ZhCharacter.fromMap(maps[i]);
    });
  }
}

void _logError(String error) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/logfile.log');
  file.writeAsStringSync('$error\n', mode: FileMode.append);
}

class Word {
  final int id;
  final String word;
  final int lang;

  Word({
    required this.id,
    required this.word,
    required this.lang,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'lang': lang,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      lang: map['lang'],
    );
  }
}

class ZhCharacter {
  final int id;
  final String character;
  final String pinyin;

  ZhCharacter({
    required this.id,
    required this.character,
    required this.pinyin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
    };
  }

  factory ZhCharacter.fromMap(Map<String, dynamic> map) {
    return ZhCharacter(
      id: map['id'],
      character: map['character'],
      pinyin: map['pinyin'],
    );
  }
}
