import 'package:rate_me/home_page/data/model/task_model.dart';

abstract class RateMeState{}

class RateMeInitial extends RateMeState{}

class GetTasksSuccessState extends RateMeState{
  final List<TaskModel> tasksList;

  GetTasksSuccessState(this.tasksList);
}
class GetTasksErrorState extends RateMeState{
  final String errorMessage;

  GetTasksErrorState(this.errorMessage);
}
class GetTasksLoadingState extends RateMeState{}
// --------------------------------------------------------
class InsertTaskSuccessState extends RateMeState{}
class InsertTaskErrorState extends RateMeState{
  final String errorMessage;

  InsertTaskErrorState(this.errorMessage);
}
class InsertTaskLoadingState extends RateMeState{}
// --------------------------------------------------------
class DeleteTaskSuccessState extends RateMeState{}
class DeleteTaskErrorState extends RateMeState{
  final String errorMessage;

  DeleteTaskErrorState(this.errorMessage);
}
class DeleteTaskLoadingState extends RateMeState{}
// --------------------------------------------------------
class UpdateTaskSuccessState extends RateMeState{}
class UpdateTaskErrorState extends RateMeState{
  final String errorMessage;

  UpdateTaskErrorState(this.errorMessage);
}
class UpdateTaskLoadingState extends RateMeState{}
// --------------------------------------------------------
class DeleteAllTasksSuccessState extends RateMeState{}
class DeleteAllTasksErrorState extends RateMeState{
  final String errorMessage;

  DeleteAllTasksErrorState(this.errorMessage);
}
class DeleteAllTasksLoadingState extends RateMeState{}
// --------------------------------------------------------
class ResetAllTasksSuccessState extends RateMeState{}
class ResetAllTasksErrorState extends RateMeState{
  final String errorMessage;

  ResetAllTasksErrorState(this.errorMessage);
}
class ResetAllTasksLoadingState extends RateMeState{}
// --------------------------------------------------------