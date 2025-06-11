import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static Future<String> initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();

    final pathInternalDatabase = join(
      directory.path,
      "establecimientos-cultura.sqlite",
    );
    final pathInternalMigration = join(directory.path, "last-migration.txt");

    ByteData data = await rootBundle.load(
      "assets/data/establecimientos-cultura.sqlite",
    );
    List<int> bytes = data.buffer.asUint8List();
    await File(pathInternalDatabase).writeAsBytes(bytes, flush: true);

    ByteData dataMigration = await rootBundle.load(
      "assets/data/last-migration.txt",
    );
    List<int> bytesMigration = dataMigration.buffer.asUint8List();
    await File(pathInternalMigration).writeAsBytes(bytesMigration, flush: true);

    return pathInternalDatabase;
  }

  static Future<Database> openDatabaseConnection() async {
    final dbPath = await initDatabase();
    return await openDatabase(dbPath);
  }
}
