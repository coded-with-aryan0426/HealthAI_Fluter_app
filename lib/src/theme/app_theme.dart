import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Dark Theme ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final tt   = _buildTextTheme(base.textTheme, isDark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepObsidian,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.dynamicMint,
        secondary:  AppColors.softIndigo,
        surface:    AppColors.charcoalGlass,
        onSurface:  AppColors.darkTextPrimary,
        onPrimary:  AppColors.deepObsidian,
        error:      AppColors.danger,
        tertiary:   AppColors.warning,
      ),
      textTheme: tt,
      primaryTextTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: tt.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dynamicMint,
          foregroundColor: AppColors.deepObsidian,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dynamicMint,
          side: const BorderSide(color: AppColors.dynamicMint, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dynamicMint,
          textStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.charcoalCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _buildInputTheme(isDark: true, tt: tt),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.charcoalCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.darkTextTertiary,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.charcoalCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        titleTextStyle: tt.titleLarge,
        contentTextStyle: tt.bodyMedium,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.charcoalBorder,
        selectedColor: AppColors.dynamicMint.withValues(alpha: 0.2),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        labelStyle: tt.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        iconColor: AppColors.darkTextSecondary,
        titleTextStyle: tt.bodyLarge,
        subtitleTextStyle: tt.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.deepObsidian : AppColors.darkTextTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.dynamicMint : AppColors.charcoalBorder),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.dynamicMint,
        inactiveTrackColor: AppColors.charcoalBorder,
        thumbColor: AppColors.dynamicMint,
        overlayColor: AppColors.dynamicMint.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.dynamicMint,
        valueIndicatorTextStyle: tt.labelSmall?.copyWith(color: AppColors.deepObsidian),
        trackHeight: 4,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.darkTextTertiary.withValues(alpha: 0.4),
        ),
        thickness: WidgetStateProperty.all(3),
        radius: const Radius.circular(3),
        interactive: false,
      ),
      pageTransitionsTheme: _buildPageTransitions(),
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.dynamicMint.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
    );
  }

  // ── Light Theme ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final tt   = _buildTextTheme(base.textTheme, isDark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cloudGray,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.dynamicMint,
        secondary:  AppColors.softIndigo,
        surface:    AppColors.pureWhite,
        onSurface:  AppColors.lightTextPrimary,
        onPrimary:  AppColors.pureWhite,
        error:      AppColors.danger,
        tertiary:   AppColors.warning,
      ),
      textTheme: tt,
      primaryTextTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: tt.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dynamicMint,
          foregroundColor: AppColors.pureWhite,
          elevation: 4,
          shadowColor: AppColors.dynamicMint.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dynamicMint,
          side: const BorderSide(color: AppColors.dynamicMint, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dynamicMint,
          textStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: AppColors.lightBorder,
            width: 1,
          ),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _buildInputTheme(isDark: false, tt: tt),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.lightTextTertiary,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        titleTextStyle: tt.titleLarge,
        contentTextStyle: tt.bodyMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceGray,
        selectedColor: AppColors.dynamicMint.withValues(alpha: 0.15),
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        labelStyle: tt.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        iconColor: AppColors.lightTextSecondary,
        titleTextStyle: tt.bodyLarge,
        subtitleTextStyle: tt.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.pureWhite : AppColors.lightTextTertiary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.dynamicMint : AppColors.surfaceGray),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.transparent : AppColors.lightBorder),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.dynamicMint,
        inactiveTrackColor: AppColors.lightBorder,
        thumbColor: AppColors.dynamicMint,
        overlayColor: AppColors.dynamicMint.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.dynamicMint,
        valueIndicatorTextStyle: tt.labelSmall?.copyWith(color: AppColors.pureWhite),
        trackHeight: 4,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.lightTextTertiary.withValues(alpha: 0.5),
        ),
        thickness: WidgetStateProperty.all(3),
        radius: const Radius.circular(3),
        interactive: false,
      ),
      pageTransitionsTheme: _buildPageTransitions(),
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.dynamicMint.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
    );
  }

  // ── Shared helpers ───────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final primary   = isDark ? AppColors.darkTextPrimary   : AppColors.lightTextPrimary;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final tertiary  = isDark ? AppColors.darkTextTertiary  : AppColors.lightTextTertiary;

    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.0, height: 1.1, color: primary),
      displayMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.15, color: primary),
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2,  color: primary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.25, color: primary),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3,  color: primary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.35, color: primary),
      titleLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.35, color: primary),
      titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1, height: 1.4,  color: primary),
      titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing:  0.0, height: 1.4,  color: secondary),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing:  0.1, height: 1.55, color: primary),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing:  0.1, height: 1.55, color: secondary),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing:  0.1, height: 1.5,  color: tertiary),
      labelLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing:  0.2, height: 1.2,  color: primary),
      labelMedium:   TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing:  0.3, height: 1.2,  color: secondary),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing:  0.5, height: 1.2,  color: tertiary),
    );
  }

  static InputDecorationTheme _buildInputTheme({required bool isDark, required TextTheme tt}) {
    final fill   = isDark ? AppColors.charcoalCard : AppColors.surfaceGray;
    final border = isDark ? AppColors.charcoalBorder : AppColors.lightBorder;
    final focus  = AppColors.dynamicMint;
    final hint   = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: tt.bodyMedium?.copyWith(color: hint),
      labelStyle: tt.bodyMedium?.copyWith(color: hint),
      floatingLabelStyle: tt.labelMedium?.copyWith(color: focus),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: focus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  static PageTransitionsTheme _buildPageTransitions() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
  }
}
