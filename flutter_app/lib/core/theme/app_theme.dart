import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FlowDesk Material 3 color palette — deep violet + teal accent
class FlowDeskColors {
  FlowDeskColors._();

  // Primary brand — deep indigo-violet
  static const Color primary = Color(0xFF5C6BC0);
  static const Color primaryContainer = Color(0xFFE8EAF6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1A237E);

  // Secondary — teal accent
  static const Color secondary = Color(0xFF26C6DA);
  static const Color secondaryContainer = Color(0xFFE0F7FA);
  static const Color onSecondary = Color(0xFF003E47);
  static const Color onSecondaryContainer = Color(0xFF00363D);

  // Tertiary — amber highlight
  static const Color tertiary = Color(0xFFFFB300);
  static const Color tertiaryContainer = Color(0xFFFFF8E1);

  // Surfaces — dark mode
  static const Color surfaceDark = Color(0xFF12131A);
  static const Color surfaceVariantDark = Color(0xFF1E2030);
  static const Color cardDark = Color(0xFF1E2030);
  static const Color onSurfaceDark = Color(0xFFE6E8F0);

  // Priority colours
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFB300);
  static const Color priorityHigh = Color(0xFFF44336);

  // Status colours
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
}

class FlowDeskTheme {
  FlowDeskTheme._();

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: FlowDeskColors.primary,
      onPrimary: FlowDeskColors.onPrimary,
      primaryContainer: const Color(0xFF3949AB),
      onPrimaryContainer: const Color(0xFFE8EAF6),
      secondary: FlowDeskColors.secondary,
      onSecondary: FlowDeskColors.onSecondary,
      secondaryContainer: const Color(0xFF00696F),
      onSecondaryContainer: FlowDeskColors.secondaryContainer,
      tertiary: FlowDeskColors.tertiary,
      onTertiary: const Color(0xFF3E2800),
      tertiaryContainer: const Color(0xFF8C6400),
      onTertiaryContainer: FlowDeskColors.tertiaryContainer,
      error: const Color(0xFFCF6679),
      onError: const Color(0xFF640020),
      errorContainer: const Color(0xFF8C0033),
      onErrorContainer: const Color(0xFFFFB3C1),
      surface: FlowDeskColors.surfaceDark,
      onSurface: FlowDeskColors.onSurfaceDark,
      surfaceContainerHighest: FlowDeskColors.surfaceVariantDark,
      onSurfaceVariant: const Color(0xFFC3C7D4),
      outline: const Color(0xFF8D9099),
      outlineVariant: const Color(0xFF3A3D4A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE2E2EA),
      onInverseSurface: const Color(0xFF2F3038),
      inversePrimary: const Color(0xFF3F51B5),
    );

    final textTheme = GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 57, fontWeight: FontWeight.w400, color: FlowDeskColors.onSurfaceDark,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32, fontWeight: FontWeight.w700, color: FlowDeskColors.onSurfaceDark,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w600, color: FlowDeskColors.onSurfaceDark,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w600, color: FlowDeskColors.onSurfaceDark,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w500, color: FlowDeskColors.onSurfaceDark,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16, fontWeight: FontWeight.w400, color: FlowDeskColors.onSurfaceDark,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFC3C7D4),
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: FlowDeskColors.surfaceDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: FlowDeskColors.surfaceDark,
        foregroundColor: FlowDeskColors.onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: FlowDeskColors.onSurfaceDark,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: FlowDeskColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3A3D4A), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FlowDeskColors.primary,
          foregroundColor: FlowDeskColors.onPrimary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FlowDeskColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: FlowDeskColors.primary, width: 1.5),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlowDeskColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3A3D4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FlowDeskColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF8D9099)),
        hintStyle: GoogleFonts.outfit(color: const Color(0xFF6B6F7C)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: FlowDeskColors.surfaceVariantDark,
        selectedColor: FlowDeskColors.primaryContainer.withOpacity(0.3),
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF3A3D4A)),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FlowDeskColors.surfaceVariantDark,
        indicatorColor: FlowDeskColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: FlowDeskColors.primary,
        foregroundColor: FlowDeskColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3D4A),
        thickness: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2F3F),
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
