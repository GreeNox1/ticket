import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ticket/src/common/dependencies/dependencies.dart';
import 'package:ticket/src/common/service/database_service.dart';

class InitializeApp {
  Future<AppDependencies> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    DatabaseService service = DatabaseService();
    Database database = await service.init();

    return AppDependencies(database: database);
  }
}
