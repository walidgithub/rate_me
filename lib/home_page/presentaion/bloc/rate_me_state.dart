import 'package:rate_me/home_page/data/model/task_model.dart';

abstract class RateMeState{}

class HomePageInitial extends RateMeState{}

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