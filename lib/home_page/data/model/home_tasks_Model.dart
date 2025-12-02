
class HomeTasksModel {
  final String taskId;
  final String mainId;
  String detail;
  int rateValue;
  List<HomeTasksModel> children;

  HomeTasksModel({
    required this.taskId,
    required this.mainId,
    required this.detail,
    this.rateValue = 0,
    this.children = const [],
  });
}


