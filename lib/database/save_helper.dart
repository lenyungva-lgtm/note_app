import 'package:path/path.dart';
import 'package:saveapp/model/save_model.dart';
import 'package:sqflite/sqflite.dart';

class SaveHelper {
  String dbName = "savedb.db";
  String tableName = "saves";

  // create database and table
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute("""
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
    var openDB = await initDatabase();
    var data = await openDB.query(tableName, orderBy: 'id DESC');
    return data.map((e) => SaveModel.fromMap(e)).toList();
  }

  // total balance
  Future<double> getBalance() async {
    var openDB = await initDatabase();
    var data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName',
    );
    return data.first['total'] as double? ?? 0.0;
  }

  // total income
  Future<double> getIncome() async {
    var openDB = await initDatabase();
    var data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName WHERE money > 0',
    );
    return data.first['total'] as double? ?? 0.0;
  }

  // total expensesss'

  Future<double> getExpense() async {
    var openDB = await initDatabase();
    var data = await openDB.rawQuery(
      'SELECT SUM(money) AS total FROM $tableName WHERE money < 0',
    );
    return data.first['total'] as double? ?? 0.0;
  }

  Future<double> getAverage() async {
    var openDB = await initDatabase();
    var data = await openDB.rawQuery(
      'SELECT AVG(money) AS total FROM $tableName',
    );
    return data.first['total'] as double? ?? 0.0;
  }
}
