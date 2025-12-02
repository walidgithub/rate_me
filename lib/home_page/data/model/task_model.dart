class TaskModel {
  final int taskId;
  final int mainId;
  final String detail;
  final int rateValue;
  final bool following;

  TaskModel({
    required this.taskId,
    required this.mainId,
    required this.detail,
    required this.rateValue,
    required this.following,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskI_id'] ?? 0,
      mainId: json['main_id'] ?? 0,
      detail: json['detail'] ?? '',
      rateValue: json['rate_value'] ?? 0,
      following: json['following'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskI_id': taskId,
      'main_id': mainId,
      'detail': detail,
      'rate_value': rateValue,
      'following': following,
    };
  }
}