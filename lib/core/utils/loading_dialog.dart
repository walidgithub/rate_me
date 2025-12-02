import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../shared/constant/app_strings.dart';
import '../shared/style/app_colors.dart';

void showLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = AppColors.cPrimary
    ..indicatorColor = AppColors.cSurface
    ..textColor = AppColors.cSurface
    ..indicatorSize = 50.0.w
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..radius = 10.0.w
    ..dismissOnTap = false
    ..userInteractions = false;
  EasyLoading.show(
    maskType: EasyLoadingMaskType.black,
    status: AppStrings.loading,
  );
}

void hideLoading() {
  EasyLoading.dismiss();
}
