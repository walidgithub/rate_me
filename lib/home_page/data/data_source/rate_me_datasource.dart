import '../../../core/local_db/db_helper.dart';
import '../model/task_model.dart';

abstract class RateMeDataSource {
  Future<void> insertTask(TaskModel taskModel);
  Future<void> deleteTask(String taskId);
  Future<void> updateTask(TaskModel taskModel);
  Future<List<TaskModel>> getAllTasks();
}

class RateMeDataSourceImpl extends RateMeDataSource {
  final DbHelper _dbHelper;

  RateMeDataSourceImpl(this._dbHelper) {
    _dbHelper.database;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final res = await _dbHelper.deleteTask(taskId);
    try {
      return res;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final res = await _dbHelper.getAllTasks();
    try {
      return res;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> insertTask(TaskModel taskModel) async {
    final res = await _dbHelper.insertTask(taskModel);
    try {
      return res;
    } catch (e) {
      print("logggg000000000000");
      print(e.toString());
      throw e.toString();
    }
  }

  @override
  Future<void> updateTask(TaskModel taskModel) async {
    final res = await _dbHelper.updateTask(taskModel);
    try {
      return res;
    } catch (e) {
      throw e.toString();
    }
  }
}
