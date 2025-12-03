import 'package:rate_me/core/shared/constant/app_strings.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../home_page/data/model/task_model.dart';

class DbHelper {
  Database? _db;

  String dbdName = 'rate_me.db';

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDB(dbdName);
      return _db!;
    }
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: createDB);
  }

  Future createDB(Database db, int version) async {
    await db.execute(
        'create table rate_me(task_id varchar(50), main_id varchar(50), detail varchar(100), rate_value integer, following boolean)');
  }

  Future<void> insertTask(TaskModel taskModel) async {
    final db = _db!.database;

    final existing = await db.query(
      'rate_me',
      where: 'detail = ?',
      whereArgs: [taskModel.detail],
    );

    if (existing.isNotEmpty) {
      print("logggg-----------------------");
      throw(AppStrings.found);
    }

    await db.insert('rate_me', taskModel.toJson());
  }


  Future<void> deleteTask(String taskId) async {
    if (_db == null) {
      await initDB(dbdName);
    }
    final db = _db!.database;
    db.delete('rate_me', where: 'task_id = ?', whereArgs: [taskId]);
  }

  Future<void> updateTask(TaskModel taskModel) async {
    if (_db == null) {
      await initDB(dbdName);
    }

    final db = _db!.database;
    db.update('rate_me', taskModel.toJson(),
        where: 'task_id = ?', whereArgs: [taskModel.taskId]);
  }

  Future<List<TaskModel>> getAllTasks() async {
    if (_db == null) {
      await initDB(dbdName);
    }

    final db = _db!.database;

    final result =
    await db.rawQuery('SELECT * FROM rate_me Order by task_id ASC');

    return result.map((json) => TaskModel.fromJson(json)).toList();
  }
}