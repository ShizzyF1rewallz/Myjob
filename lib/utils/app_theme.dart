import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Fallback pour les glyphes manquants (réduit l'avertissement Noto sur le web).
  static const List<String> _fontFallbacks = ['Noto Sans', 'sans-serif'];

  // Palette moderne — Indigo / Slate
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color accent = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);

  static ThemeData get light {
    final textTheme = _buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight.withValues(alpha: 0.15),
        secondary: accent,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: const Color(0xFF0F172A),
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
        error: const Color(0xFFDC2626),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: cardBackground,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF475569), size: 24),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outline, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: TextStyle(color: onSurfaceVariant, fontSize: 15),
        hintStyle: TextStyle(color: onSurfaceVariant.withValues(alpha: 0.8)),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardBackground,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withValues(alpha: 0.15),
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF334155),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    final base = TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: const Color(0xFF0F172A),
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: const Color(0xFF0F172A),
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: const Color(0xFF0F172A),
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF475569),
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF334155),
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
        height: 1.5,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: const Color(0xFF64748B),
      ),
    );
    return TextTheme(
      displayLarge: base.displayLarge?.copyWith(fontFamilyFallback: _fontFallbacks),
      displayMedium: base.displayMedium?.copyWith(fontFamilyFallback: _fontFallbacks),
      displaySmall: base.displaySmall?.copyWith(fontFamilyFallback: _fontFallbacks),
      headlineLarge: base.headlineLarge?.copyWith(fontFamilyFallback: _fontFallbacks),
      headlineMedium: base.headlineMedium?.copyWith(fontFamilyFallback: _fontFallbacks),
      headlineSmall: base.headlineSmall?.copyWith(fontFamilyFallback: _fontFallbacks),
      titleLarge: base.titleLarge?.copyWith(fontFamilyFallback: _fontFallbacks),
      titleMedium: base.titleMedium?.copyWith(fontFamilyFallback: _fontFallbacks),
      titleSmall: base.titleSmall?.copyWith(fontFamilyFallback: _fontFallbacks),
      bodyLarge: base.bodyLarge?.copyWith(fontFamilyFallback: _fontFallbacks),
      bodyMedium: base.bodyMedium?.copyWith(fontFamilyFallback: _fontFallbacks),
      bodySmall: base.bodySmall?.copyWith(fontFamilyFallback: _fontFallbacks),
      labelLarge: base.labelLarge?.copyWith(fontFamilyFallback: _fontFallbacks),
      labelMedium: base.labelMedium?.copyWith(fontFamilyFallback: _fontFallbacks),
      labelSmall: base.labelSmall?.copyWith(fontFamilyFallback: _fontFallbacks),
    );
  }

  /// Ombres douces pour cartes
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowHover => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
