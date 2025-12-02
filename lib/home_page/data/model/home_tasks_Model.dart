class HomeTasksModel {
  String title;
  int progress;
  List<HomeTasksModel> children;

  HomeTasksModel({
    required this.title,
    this.progress = 0,
    this.children = const [],
  });
}