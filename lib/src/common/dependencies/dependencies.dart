import 'package:sqflite/sqlite_api.dart';

class AppDependencies {
  AppDependencies({
    required this.database,
  });

  final Database database;
}
