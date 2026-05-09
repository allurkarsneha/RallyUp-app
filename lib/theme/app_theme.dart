import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkGreen,
      primary: AppColors.darkGreen,
      secondary: AppColors.brightGreen,
      background: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
