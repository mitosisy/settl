import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  final dbPath = p.join(Platform.environment['USERPROFILE']!, r'Documents\ashish_projects\blockchain_upi\chain_pay\.dart_tool\sqflite', 'offline_queue.db'); // Note: flutter desktop path is different.

  // Let's just find where it's stored on windows. Wait, we don't know the exact path for sqflite on Windows. 
  print(dbPath);
}
