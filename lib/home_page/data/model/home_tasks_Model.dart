
class HomeTasksModel {
  final String taskId;
  final String mainId;
  String task;
  int rateValue;
  List<HomeTasksModel> children;

  HomeTasksModel({
    required this.taskId,
    required this.mainId,
    required this.task,
    this.rateValue = 0,
    this.children = const [],
  });
}


