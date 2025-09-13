import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color veryLightBlue = Color(0xFFEFF6FF);

  // Success Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color lightGreen = Color(0xFF34D399);
  static const Color veryLightGreen = Color(0xFFD1FAE5);

  // Warning Colors
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color lightYellow = Color(0xFFFEF3C7);
  static const Color veryLightYellow = Color(0xFFFDE68A);

  // Error Colors
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color lightRed = Color(0xFFFEE2E2);

  // Purple Colors
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  // Gray Scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF0F9FF);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color surfaceWhite = Colors.white;

  // Gradient Colors
  static const List<Color> primaryGradient = [primaryBlue, secondaryBlue];
  static const List<Color> successGradient = [successGreen, lightGreen];
  static const List<Color> warningGradient = [lightYellow, veryLightYellow];
  static const List<Color> cardGradient = [veryLightBlue, lightBlue];

  // Create the main theme
  static ThemeData get lightTheme {
    return ThemeData(
      // Use Material 3
      useMaterial3: true,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: successGreen,
        onSecondary: Colors.white,
        tertiary: warningOrange,
        onTertiary: Colors.white,
        surface: surfaceWhite,
        onSurface: gray900,
        background: backgroundLight,
        onBackground: gray900,
        error: dangerRed,
        onError: Colors.white,
        outline: gray300,
        outlineVariant: gray200,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundLight,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(),

      // Button Themes
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),

      // Card Theme
      // cardTheme: CardTheme(
      //   color: surfaceWhite,
      //   elevation: 2,
      //   shadowColor: Colors.black.withOpacity(0.08),
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // ),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 10,
        selectedItemColor: primaryBlue,
        unselectedItemColor: gray500,
        type: BottomNavigationBarType.fixed,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: gray100,
        selectedColor: primaryBlue,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: gray200,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(color: gray200, thickness: 1),

      // Font Family
      fontFamily: 'Inter',
    );
  }

  // Text Theme
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Headlines
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: gray900,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: gray900,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Inter',
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: gray800,
        fontFamily: 'Inter',
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Inter',
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Inter',
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: gray700,
        fontFamily: 'Inter',
      ),

      // Body Text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: gray800,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: gray700,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: gray600,
        fontFamily: 'Inter',
        height: 1.4,
      ),

      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray700,
        fontFamily: 'Inter',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: gray600,
        fontFamily: 'Inter',
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: gray500,
        fontFamily: 'Inter',
      ),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        color: gray400,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
      labelStyle: const TextStyle(
        color: gray600,
        fontSize: 14,
        fontFamily: 'Inter',
      ),
    );
  }

  // Custom Gradients
  static LinearGradient get primaryGradientDecoration => const LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradientDecoration => const LinearGradient(
    colors: successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warningGradientDecoration => const LinearGradient(
    colors: warningGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradientDecoration => const LinearGradient(
    colors: cardGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Styles
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, -2),
      blurRadius: 10,
    ),
  ];

  // Border Radius Constants
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );
}

// Extension for easy color access
extension AppColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// Custom Color Extensions
extension CustomColors on ColorScheme {
  Color get success => AppTheme.successGreen;
  Color get warning => AppTheme.warningOrange;
  Color get info => AppTheme.primaryBlue;

  Color get gray50 => AppTheme.gray50;
  Color get gray100 => AppTheme.gray100;
  Color get gray200 => AppTheme.gray200;
  Color get gray300 => AppTheme.gray300;
  Color get gray400 => AppTheme.gray400;
  Color get gray500 => AppTheme.gray500;
  Color get gray600 => AppTheme.gray600;
  Color get gray700 => AppTheme.gray700;
  Color get gray800 => AppTheme.gray800;
  Color get gray900 => AppTheme.gray900;

  Color get lightBlue => AppTheme.lightBlue;
  Color get lightGreen => AppTheme.veryLightGreen;
  Color get lightYellow => AppTheme.lightYellow;
  Color get lightRed => AppTheme.lightRed;
}
