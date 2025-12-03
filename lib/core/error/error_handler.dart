import '../error/failure.dart';
import '../shared/constant/app_strings.dart';

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    switch (error) {
      case AppStrings.success:
        failure = DataSource.SUCCESS.getFailure();
        break;
      default:
        failure = DataSource.DEFAULT.getFailure();
    }
  }
}

enum DataSource { SUCCESS, DEFAULT }

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.SUCCESS:
        return Failure(ResponseMessage.SUCCESS);
      case DataSource.DEFAULT:
        return Failure(ResponseMessage.DEFAULT);
    }
  }
}

class ResponseMessage {
  static const String SUCCESS = AppStrings.success;
  static const String DEFAULT = AppStrings.someThingWentWrong;
}
