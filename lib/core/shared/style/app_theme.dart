import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rate_me/core/shared/style/app_colors.dart';

import '../constant/app_constants.dart';
import '../constant/app_typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cPrimary),
      primarySwatch: Colors.teal,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cBackground,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(
          color: AppColors.cDark,
        ),
        backgroundColor: AppColors.cBackground,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.h,
          vertical: 5.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cAccent),
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cAccent),
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cAccent),
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cAccent),
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
        hintStyle: AppTypography.kLight14,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.h,
              vertical: 5.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cAccent),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cAccent),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cAccent),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cAccent),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            hintStyle: AppTypography.kLight14,
          )),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cBackground,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ));
}

// Default Overlay.
SystemUiOverlayStyle defaultOverlay = const SystemUiOverlayStyle(
  statusBarColor: AppColors.cTransparent,
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.cDark,
  systemNavigationBarDividerColor: AppColors.cTransparent,
  systemNavigationBarIconBrightness: Brightness.light,
);
