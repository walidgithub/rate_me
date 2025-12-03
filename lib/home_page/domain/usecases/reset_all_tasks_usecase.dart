import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../data/model/task_model.dart';
import '../repository/rate_me_repository.dart';
import 'base_usecase/base_usecase.dart';

class ResetAllTasksUseCase extends BaseUsecase<void, NoParameters> {
  final RateMeRepository rateMeRepository;

  ResetAllTasksUseCase(this.rateMeRepository);

  @override
  Future<Either<Failure, void>> call(NoParameters parameters) async {
    return await rateMeRepository.resetAllTasks();
  }
}