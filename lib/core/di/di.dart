import 'package:get_it/get_it.dart';

import '../local_db/db_helper.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    // dbHelper
    sl.registerLazySingleton<DbHelper>(() => DbHelper());
  }
}