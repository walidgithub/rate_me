class TaskModel {
  final String taskId;
  final String mainId;
  final String detail;
  final int rateValue;

  TaskModel({
    required this.taskId,
    required this.mainId,
    required this.detail,
    required this.rateValue
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] ?? '',
      mainId: json['main_id'] ?? '',
      detail: json['detail'] ?? '',
      rateValue: json['rate_value'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'main_id': mainId,
      'detail': detail,
      'rate_value': rateValue
    };
  }
}