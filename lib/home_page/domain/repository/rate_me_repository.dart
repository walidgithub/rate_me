import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../data/model/task_model.dart';

abstract class RateMeRepository {
  Future<Either<Failure, void>> insertTask(TaskModel taskModel);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, void>> updateTask(TaskModel taskModel);
  Future<Either<Failure, List<TaskModel>>> getAllTasks();
}