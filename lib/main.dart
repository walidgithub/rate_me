import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';
import 'core/di/di.dart';
import 'core/router/app_router.dart';
import 'core/shared/constant/app_strings.dart';
import 'core/shared/style/app_theme.dart';
import 'home_page/presentaion/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceLocator().init();
  await ScreenUtil.ensureScreenSize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppStrings.appName,
              builder: EasyLoading.init(),
              onGenerateRoute: RouteGenerator.getRoute,
              initialRoute: Routes.homeRoute,
              theme: AppTheme.lightTheme);
        });
  }
}
