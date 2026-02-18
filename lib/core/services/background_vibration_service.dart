import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:vibration/vibration.dart';

Future<void> initializeVibrationService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Rate Me",
      content: "Vibration running",
    );
  }

  int seconds = 1;
  bool isRunning = true;

  service.on('setSeconds').listen((event) {
    seconds = event?['seconds'] ?? 1;
  });

  service.on('stopService').listen((event) {
    isRunning = false;
    service.stopSelf();
  });

  while (isRunning) {
    await Future.delayed(Duration(seconds: seconds));

    if (!isRunning) break;

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
  }
}


