import 'package:path/path.dart';
import 'package:saveapp/model/save_model.dart';
import 'package:sqflite/sqflite.dart';

class SaveHelper {
  String dbName = 'savedb.db';
  String tableName = 'saves';

  // create database and table
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
CREATE TABLE $tableName(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  note TEXT,
  date TEXT,
  type TEXT,
  money REAL
)
        """);
      },
    );
  }

  //insert data
  Future<int> depositData(SaveModel save) async {
    var openDB = await initDatabase();
    return openDB.insert(tableName, save.toMap());
  }

  // get database
  Future<List<SaveModel>> getAllData() async {
    final openDB = await initDatabase();
    final data = await openDB.query(tableName, orderBy: 'id DESC');
    return data.map((e) => SaveModel.fromMap(e)).toList();
  }

  // total balance
  Future<double> getBalance() async {
    final openDB = await initDatabase();
    final data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName',
    );
    return _readTotal(data);
  }

  // total income
  Future<double> getIncome() async {
    final openDB = await initDatabase();
    final data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName WHERE money > 0',
    );
    return _readTotal(data);
  }

  // Total expenses remain negative to match the stored transaction amounts.
  Future<double> getExpense() async {
    final openDB = await initDatabase();
    final data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName WHERE money < 0',
    );
    return _readTotal(data);
  }

  Future<double> getAverage() async {
    final openDB = await initDatabase();
    final data = await openDB.rawQuery(
      'SELECT AVG(money) AS total FROM $tableName',
    );
    return _readTotal(data);
  }

  double _readTotal(List<Map<String, Object?>> rows) {
    final value = rows.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }
  Future<void> deleteData(SaveModel save) async {
    final openDB = await initDatabase();
    await openDB.delete(tableName, where: 'id = ?', whereArgs: [save.id]);
  }
}