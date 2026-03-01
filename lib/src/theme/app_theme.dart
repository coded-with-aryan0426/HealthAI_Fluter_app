import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // --- Dark Mode Theme (Default Premium) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepObsidian,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.dynamicMint,
        secondary: AppColors.softIndigo,
        surface: AppColors.charcoalGlass,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dynamicMint,
          foregroundColor: AppColors.deepObsidian, // Text color on top of mint
          elevation: 0, // rely on borders in dark mode
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1), // Subtle white border
        ),
      ),
    );
  }

  // --- Light Mode Theme (Airy & Clean) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pureWhite,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.dynamicMint,
        secondary: AppColors.softIndigo,
        surface: AppColors.pureWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dynamicMint,
          foregroundColor: AppColors.pureWhite,
          elevation: 4,
          shadowColor: AppColors.dynamicMint.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.04), // Deep diffuse shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
