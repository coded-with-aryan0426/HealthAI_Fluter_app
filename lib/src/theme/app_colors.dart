import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Accents ──────────────────────────────────────────────────────────
  static const Color dynamicMint    = Color(0xFF00D4B2);
  static const Color mintLight      = Color(0xFF33DEC0);
  static const Color mintDark       = Color(0xFF00A88D);
  static const Color softIndigo     = Color(0xFF6B7AFF);
  static const Color indigoLight    = Color(0xFF8B99FF);
  static const Color indigoDark     = Color(0xFF4A5BE8);

  // ── Dark Mode Surface Tokens ─────────────────────────────────────────────────
  static const Color deepObsidian   = Color(0xFF080B12);
  static const Color obsidianMid    = Color(0xFF0D1018);
  static const Color charcoalGlass  = Color(0xFF141720);
  static const Color charcoalCard   = Color(0xFF1A1E2A);
  static const Color charcoalBorder = Color(0xFF252836);
  static const Color darkTextPrimary    = Color(0xFFF0F2F8);
  static const Color darkTextSecondary  = Color(0xFF7A8197);
  static const Color darkTextTertiary   = Color(0xFF4D5369);

  // ── Light Mode Surface Tokens ────────────────────────────────────────────────
  static const Color pureWhite      = Color(0xFFFFFFFF);
  static const Color cloudGray      = Color(0xFFF4F6FA);
  static const Color surfaceGray    = Color(0xFFEEF0F5);
  static const Color lightCard      = Color(0xFFFFFFFF);
  static const Color lightBorder    = Color(0xFFE8ECF4);
  static const Color lightTextPrimary    = Color(0xFF0F1117);
  static const Color lightTextSecondary  = Color(0xFF5A6172);
  static const Color lightTextTertiary   = Color(0xFF9AA0B4);

  // ── Semantic Colors ──────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF41C9E2);
  static const Color warning   = Color(0xFFFF9F43);
  static const Color warningDark = Color(0xFFE88E38);
  static const Color danger    = Color(0xFFFF4B4B);
  static const Color dangerDark = Color(0xFFE83C3C);
  static const Color purple    = Color(0xFF9B59B6);
  static const Color purpleLight = Color(0xFFB060D0);

  // ── Extended Accent Tokens ───────────────────────────────────────────────────
  /// Warm amber used for streak banners and daily-goal highlights
  static const Color amberGlow     = Color(0xFFF59E0B);
  static const Color amberGlowDark = Color(0xFFD97706);
  /// Coral rose used for protein / calorie-exceeded states
  static const Color roseAccent    = Color(0xFFF43F5E);
  static const Color roseAccentDark= Color(0xFFE11D48);
  /// Deep warm obsidian — slightly warmer than deepObsidian, hero card bg
  static const Color warmObsidian  = Color(0xFF0E0C14);
  /// Electro cyan — chart highlight, water goal met
  static const Color electroCyan   = Color(0xFF22D3EE);

  // ── Gradient Presets ────────────────────────────────────────────────────────
  static const LinearGradient mintGradient = LinearGradient(
    colors: [dynamicMint, mintDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient indigoGradient = LinearGradient(
    colors: [softIndigo, indigoDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient mintIndigoGradient = LinearGradient(
    colors: [dynamicMint, softIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [danger, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sleepGradient = LinearGradient(
    colors: [softIndigo, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient waterGradient = LinearGradient(
    colors: [Color(0xFF41C9E2), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  /// Amber streak gradient — used on streak/accomplishment banners
  static const LinearGradient amberGradient = LinearGradient(
    colors: [amberGlow, Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  /// Rose gradient — calorie exceeded, alert states
  static const LinearGradient roseGradient = LinearGradient(
    colors: [roseAccent, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  /// Sunrise hero gradient — dashboard hero card background
  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFF6B7AFF), Color(0xFF00D4B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Design Tokens ─────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 28;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;

  /// Standard horizontal page padding
  static const double pagePad = 24;
}

class AppRadius {
  static const double chip    = 12;
  static const double button  = 16;
  static const double card    = 20;
  static const double cardLg  = 24;
  static const double hero    = 28;
  static const double sheet   = 32;
  static const double full    = 999;
}

class AppDurations {
  static const Duration instant  = Duration(milliseconds: 80);
  static const Duration fast     = Duration(milliseconds: 150);
  static const Duration normal   = Duration(milliseconds: 250);
  static const Duration slow     = Duration(milliseconds: 400);
  static const Duration page     = Duration(milliseconds: 350);
  static const Duration long     = Duration(milliseconds: 600);
  static const Duration xlong    = Duration(milliseconds: 900);
  static const Duration countUp  = Duration(milliseconds: 1200);
  static const Duration typeChar = Duration(milliseconds: 28);
}

class AppCurves {
  static const Curve slide      = Curves.easeOutCubic;
  static const Curve popIn      = Curves.easeOutBack;
  static const Curve fadeIn     = Curves.easeOut;
  static const Curve spring     = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve emphasised = Curves.easeInOutCubicEmphasized;
  static const Curve bouncy     = Curves.bounceOut;
}
