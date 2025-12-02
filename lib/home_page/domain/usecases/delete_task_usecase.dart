import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../repository/rate_me_repository.dart';
import 'base_usecase/base_usecase.dart';

class DeleteTaskUseCase extends BaseUsecase {
  final RateMeRepository rateMeRepository;

  DeleteTaskUseCase(this.rateMeRepository);

  @override
  Future<Either<Failure, void>> call(parameters) async {
    return await rateMeRepository.deleteTask(parameters);
  }
}