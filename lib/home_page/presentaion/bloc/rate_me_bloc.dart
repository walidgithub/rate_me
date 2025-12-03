import 'package:rate_me/home_page/domain/usecases/base_usecase/base_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/delete_all_tasks_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/delete_task_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/get_tasks_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/reset_all_tasks_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/update_task_usecase.dart';
import 'package:rate_me/home_page/presentaion/bloc/rate_me_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/task_model.dart';
import '../../domain/usecases/insert_task_usecase.dart';

class RateMeCubit extends Cubit<RateMeState> {
  RateMeCubit(
    this.getAllTasksUseCase,
    this.insertTaskUseCase,
    this.updateTaskUseCase,
    this.deleteTaskUseCase,
    this.resetAllTasksUseCase,
    this.deleteAllTasksUseCase,
  ) : super(RateMeInitial());

  final GetAllTasksUseCase getAllTasksUseCase;
  final InsertTaskUseCase insertTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ResetAllTasksUseCase resetAllTasksUseCase;
  final DeleteAllTasksUseCase deleteAllTasksUseCase;

  static RateMeCubit get(context) => BlocProvider.of(context);

  Future<void> insertTask(TaskModel taskModel) async {
    emit(InsertTaskLoadingState());
    final result = await insertTaskUseCase.call(taskModel);
    result.fold(
      (failure) => emit(InsertTaskErrorState(failure.message)),
      (added) => emit(InsertTaskSuccessState()),
    );
  }

  Future<void> getAllTasks() async {
    emit(GetTasksLoadingState());
    final result = await getAllTasksUseCase.call(const NoParameters());
    result.fold(
      (failure) => emit(GetTasksErrorState(failure.message)),
      (tasks) => emit(GetTasksSuccessState(tasks)),
    );
  }

  Future<void> deleteAllTasks() async {
    emit(DeleteAllTasksLoadingState());
    final result = await deleteAllTasksUseCase.call(const NoParameters());
    result.fold(
          (failure) => emit(DeleteAllTasksErrorState(failure.message)),
          (deletedAll) => emit(DeleteAllTasksSuccessState()),
    );
  }

  Future<void> resetAllTasks() async {
    emit(ResetAllTasksLoadingState());
    final result = await resetAllTasksUseCase.call(const NoParameters());
    result.fold(
          (failure) => emit(ResetAllTasksErrorState(failure.message)),
          (resetAll) => emit(ResetAllTasksSuccessState()),
    );
  }

  Future<void> deleteTask(String taskId) async {
    emit(DeleteTaskLoadingState());
    final result = await deleteTaskUseCase.call(taskId);
    result.fold(
      (failure) => emit(DeleteTaskErrorState(failure.message)),
      (deleted) => emit(DeleteTaskSuccessState()),
    );
  }

  Future<void> updateTask(TaskModel taskModel) async {
    emit(UpdateTaskLoadingState());
    final result = await updateTaskUseCase.call(taskModel);
    result.fold(
      (failure) => emit(UpdateTaskErrorState(failure.message)),
      (updated) => emit(UpdateTaskSuccessState()),
    );
  }
}
