class TaskModel {
  final String taskId;
  final String mainId;
  final String task;
  final int rateValue;

  TaskModel({
    required this.taskId,
    required this.mainId,
    required this.task,
    required this.rateValue
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] ?? '',
      mainId: json['main_id'] ?? '',
      task: json['task_name'] ?? '',
      rateValue: json['rate_value'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'main_id': mainId,
      'task_name': task,
      'rate_value': rateValue
    };
  }
}