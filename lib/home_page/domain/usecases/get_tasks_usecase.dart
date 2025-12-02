import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../data/model/task_model.dart';
import '../repository/rate_me_repository.dart';
import 'base_usecase/base_usecase.dart';

class GetAllTasksUseCase extends BaseUsecase<List<TaskModel>, NoParameters> {
  final RateMeRepository rateMeRepository;

  GetAllTasksUseCase(this.rateMeRepository);

  @override
  Future<Either<Failure, List<TaskModel>>> call(NoParameters parameters) async {
    return await rateMeRepository.getAllTasks();
  }
}