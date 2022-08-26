import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'contact_dao.dart';
import 'user_dao.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), "bank.db");

  return openDatabase(
    path,
    onCreate: (db, version) {
      tablesToCreate().forEach((table) {
        try {
          db.execute(table);
        } catch (e) {
          print(e);
        }
      });
    },
    version: 3,
  );
}

List<String> tablesToCreate() {
  return [
    UserDao.tableSql,
    ContactDao.tableSql,
  ];
}
