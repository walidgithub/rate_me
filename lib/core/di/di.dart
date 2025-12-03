import 'package:get_it/get_it.dart';
import 'package:rate_me/home_page/data/data_source/rate_me_datasource.dart';
import 'package:rate_me/home_page/data/repository_impl/rate_me_repository_impl.dart';
import 'package:rate_me/home_page/domain/usecases/delete_task_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/get_tasks_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/insert_task_usecase.dart';
import 'package:rate_me/home_page/domain/usecases/update_task_usecase.dart';

import '../../home_page/domain/repository/rate_me_repository.dart';
import '../../home_page/presentaion/bloc/rate_me_bloc.dart';
import '../local_db/db_helper.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> init() async {
    // dbHelper
    sl.registerLazySingleton<DbHelper>(() => DbHelper());

    // Bloc
    sl.registerFactory(() => RateMeCubit(sl(), sl(), sl(), sl()));

    // useCases
    sl.registerLazySingleton<InsertTaskUseCase>(() => InsertTaskUseCase(sl()));
    sl.registerLazySingleton<DeleteTaskUseCase>(() => DeleteTaskUseCase(sl()));
    sl.registerLazySingleton<UpdateTaskUseCase>(() => UpdateTaskUseCase(sl()));
    sl.registerLazySingleton<GetAllTasksUseCase>(() => GetAllTasksUseCase(sl()));

    // Repositories
    sl.registerLazySingleton<RateMeRepository>(() => RateMeRepositoryImpl(sl()));

    // DataSources
    sl.registerLazySingleton<RateMeDataSource>(() => RateMeDataSourceImpl(sl()));
  }
}