import 'package:flutter/material.dart';

/// App color palette for SabayCinema.
/// Designed around a clean, modern, and soft luxury dark aesthetic.
class AppColors {
  AppColors._();

  // Backgrounds & Surface (Matching exact sabaycinema.com color palette: .bg-major #0f0f0f)
  static const Color background = Color(0xFF0F0F0F);      // Exact .bg-major from sabaycinema.com
  static const Color headerBackground = Color(0xFF141417);// Distinct solid cinema dark header background
  static const Color headerBackgroundGlass = Color(0xF2141417);// 95% opacity frosted cinema header
  static const Color footerBackground = Color(0xFF0F0F0F);// Seamless footer background matching page background
  static const Color footerGlow = Color(0x228C3692);      // Subtle ambient logo purple glow stop
  static const Color headerRimCyan = Color(0x18FFFFFF);   // Subtle sleek glass rim line
  static const Color headerBorder = Color(0x24FFFFFF);    // Defined sleek header border
  static const Color surface = Color(0xFF18151E);         // Clean Obsidian Cinema Dark Surface
  static const Color surfaceLighter = Color(0xFF221E2B);  // Elevated Card Surface
  static const Color surfaceElevated = Color(0xFF2B2636); // Raised Card Highlight
  static const Color surfaceGlass = Color(0xD917141E);    // Deep luxury obsidian glass surface

  // Soft Glassmorphic Borders & Highlights
  static const Color glassBorder = Color(0x38FFFFFF);      // 22% White border
  static const Color glassBorderSubtle = Color(0x1FFFFFFF);// 12% Crisp White border
  static const Color glassFill = Color(0x0FFFFFFF);        // 6% White Fill
  static const Color glassFillActive = Color(0x1FFFFFFF);  // 12% White Fill
  static const Color glassHighlight = Color(0x33FFFFFF);   // Top-edge highlight

  // Primary Brand: Signature Sabay Gold (#DDAC45) as seen across sabaycinema.com
  static const Color primary = Color(0xFFDDAC45);        // Sabay Warm Gold
  static const Color primaryVariant = Color(0xFFE8BE65); // Radiant Gold Highlight
  static const Color primaryLight = Color(0xFFF2DCB3);   // Champagne Glow
  static const Color primaryDark = Color(0xFFB58521);    // Deep Amber Gold
  static const Color onPrimary = Color(0xFF0D0D0D);      // Contrast text on gold buttons

  // Secondary Accents: Sabay Fiery Red (#E31B23) & Deep Burgundy Atmosphere
  static const Color secondary = Color(0xFFE31B23);      // Sabay Flame Red Logo Accent
  static const Color secondaryLight = Color(0xFFFF4D58); // Coral Red Flame
  static const Color secondaryDark = Color(0xFFA81118);  // Deep Crimson
  static const Color burgundy = Color(0xFF5C0612);       // Exact Sabay Crimson/Burgundy from sabaycinema.com banner gradient
  static const Color burgundyDark = Color(0xFF38030B);

  // ============================================================================
  // Official Sabay Brand Logo Palette (Extracted directly from logo-sabay.png)
  // ============================================================================
  static const Color logoRed = Color(0xFFD52128);          // Sabay Flame Scarlet Red (#D52128)
  static const Color logoRedBright = Color(0xFFE5262C);    // Vibrant Flame Red Highlight (#E5262C)
  static const Color logoPurple = Color(0xFF8C3692);       // Signature Sabay Ribbon Violet / Purple (#8C3692)
  static const Color logoPurpleDeep = Color(0xFF551458);   // Deep Ambient Ribbon Plum
  static const Color logoMagenta = Color(0xFFBD2D5A);      // Mid Ribbon Transition Magenta (#BD2D5A)
  static const Color logoOrange = Color(0xFFF58220);       // Radiant Flame Orange (#F58220)
  static const Color logoAmber = Color(0xFFF9DB0C);        // Bright Flame Sun Amber (#F9DB0C)
  static const Color logoAmberWarm = Color(0xFFF5B313);    // Warm Gold Amber

  // Cinema Technology & Status Accents
  static const Color accentCyan = Color(0xFF00E5FF);     // IMAX Laser Cyan
  static const Color accentCyanGlow = Color(0x4D00E5FF);
  static const Color accentGold = Color(0xFFDDAC45);     // VIP Gold Tier
  static const Color accentAmber = Color(0xFFF5B313);    // Warm Amber Accent
  static const Color accentEmerald = Color(0xFF28A745);  // Available / Success (Bootstrap green from old site)
  static const Color accentRose = Color(0xFFFF2A85);     // ScreenX / Special Event
  static const Color success = accentEmerald;            // Available / Success status color

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);    // Pure Crisp White
  static const Color textSecondary = Color(0xFFB0B2B4);  // Muted Warm Grey (from old site)
  static const Color textTertiary = Color(0xFF6C757D);   // Subtle Helper Text (#6C757D Bootstrap muted)
  static const Color textHighlight = Color(0xFFDDAC45);  // Gold Ratings, Dates & Awards

  // Cinema Seat Colors
  static const Color seatAvailable = Color(0xFF202024);
  static const Color seatAvailableBorder = Color(0xFF38383E);
  static const Color seatSelected = Color(0xFFDDAC45);
  static const Color seatSelectedGlow = Color(0x80DDAC45);
  static const Color seatReserved = Color(0xFF121214);
  static const Color seatVIP = Color(0xFFDDAC45);
  static const Color seatTwin = Color(0xFF9D4EDD);
  static const Color seatWheelchair = Color(0xFF00E5FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE5B955), Color(0xFFC5952B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFD52128), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFFF5E1B5), Color(0xFFDDAC45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Signature Atmospheric Background Gradient using Sabay Logo colors
  static const LinearGradient sabayAtmosphereGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.85, 0.70),
    colors: [
      Color(0xA6D52128), // 65% Sabay Logo Flame Red
      Color(0x668C3692), // 40% Sabay Logo Ribbon Violet
      Color(0x28BD2D5A), // 16% Logo Magenta Shadow
      Colors.transparent,
    ],
    stops: [0.0, 0.32, 0.64, 0.90],
  );

  // Logo Brand Flame Ribbon Gradient (Direct multi-stop representation of logo-sabay.png)
  static const LinearGradient logoFlameGradient = LinearGradient(
    colors: [
      Color(0xFFF9DB0C), // Flame Sun Amber
      Color(0xFFF58220), // Flame Orange
      Color(0xFFD52128), // Flame Scarlet Red
      Color(0xFFBD2D5A), // Ribbon Magenta
      Color(0xFF8C3692), // Ribbon Violet / Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient burgundyGradient = LinearGradient(
    colors: [Color(0xFF5C0612), Color(0xFF38030B), Color(0xFF0F0F0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1B1B20), // Subtle elevated highlight on top edge
      Color(0xFF131316), // Rich deep cinema header surface
    ],
  );

  static const LinearGradient footerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x1A8C3692),
      Color(0xFF09090A),
    ],
    stops: [0.0, 0.25, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEB201A2B), // Sleek obsidian top-left with subtle warm cinema undertone
      Color(0xE014111C), // Deep cinema dark base
    ],
  );

  static const LinearGradient bannerCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF224162B), // Deep plum/violet luxury cinema glass
      Color(0xD9191122),
      Color(0xBF120D1A),
    ],
  );

  static const LinearGradient glassHighlightGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient screenGlowGradient = LinearGradient(
    colors: [
      Color(0x99DDAC45),
      Color(0x33DDAC45),
      Color(0x00000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
