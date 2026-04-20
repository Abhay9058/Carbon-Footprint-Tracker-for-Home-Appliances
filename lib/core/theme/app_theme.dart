import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color tealAccent = Color(0xFF64FFDA);
  static const Color lightTeal = Color(0xFF80CBC4);
  static const Color ecoGreen = Color(0xFF81C784);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFFB0B0B0);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color errorRed = Color(0xFFE57373);

  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassLightTeal = Color(0x6680CBC4);
  static const Color glassSoftGreen = Color(0x66E8F5E9);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.lightTeal,
        surface: AppColors.white,
        error: AppColors.errorRed,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.glassWhite,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGreen.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.black),
        labelStyle: const TextStyle(color: AppColors.black),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.white.withValues(alpha: 0.9),
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.grey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryGreen);
          }
          return const IconThemeData(color: AppColors.grey);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.lightTeal,
        surface: const Color(0xFF1E1E1E),
        error: AppColors.errorRed,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.7)),
        labelStyle: const TextStyle(color: AppColors.black),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.grey,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.grey,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryGreen);
          }
          return const IconThemeData(color: AppColors.grey);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.grey,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: GoogleFonts.poppins(color: AppColors.white),
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
      dividerColor: const Color(0xFF404040),
    );
  }
}
