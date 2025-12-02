import 'package:dartz/dartz.dart';

import 'package:rate_me/core/error/failure.dart';

import 'package:rate_me/home_page/data/model/task_model.dart';

import '../../../core/error/error_handler.dart';
import '../../domain/repository/rate_me_repository.dart';
import '../data_source/rate_me_datasource.dart';

class RateMeRepositoryImpl extends RateMeRepository {
  final RateMeDataSource _rateMeDataSource;

  RateMeRepositoryImpl(this._rateMeDataSource);

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      final result = await _rateMeDataSource.deleteTask(taskId);
      return Right(result);
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getAllTasks() async {
    try {
      final result = await _rateMeDataSource.getAllTasks();
      return Right(result);
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }

  @override
  Future<Either<Failure, void>> insertTask(TaskModel taskModel) async {
    try {
      final result = await _rateMeDataSource.insertTask(taskModel);
      return Right(result);
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskModel taskModel) async {
    try {
      final result = await _rateMeDataSource.updateTask(taskModel);
      return Right(result);
    } catch (error) {
      return Left(ErrorHandler.handle(error).failure);
    }
  }
}
