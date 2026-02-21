import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ticket/src/common/constants/constants.dart';

class DatabaseService {
  Future<Database> init() async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, Constants.seatTableName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _onCreate(db, version),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${Constants.seatTableName} (
            id INTEGER PRIMARY KEY,
            ${Constants.seatTableId} TEXT,
            ${Constants.seatTableStatus} VARCHAR(15) NOT NULL,
            ${Constants.seatTableLockedBy} TEXT,
            ${Constants.seatTableLockExpirationTime} INTEGER
          )
          ''');

    debugPrint('DB ochildi');

    debugPrint("DB ga ma'lumotlar yuklanmoqda!");

    await _initialData(db);

    debugPrint("DB ga ma'lumotlar yuklandi");
  }

  Future<void> _initialData(Database db) async {
    for (var index = 1; index <= 64; index++) {
      db.transaction((txn) async {
        await txn.rawInsert('''
            INSERT INTO ${Constants.seatTableName}(${Constants.seatTableId}, ${Constants.seatTableStatus})
            VALUES ('$index', 'available');
            ''');
      });
    }
  }
}
