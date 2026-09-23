import 'package:flutter/material.dart';

/// App color palette for SabayCinema.
/// Designed around a clean, modern, and soft luxury dark aesthetic.
class AppColors {
  AppColors._();

  // Backgrounds & Surface (Matching exact sabaycinema.com color palette: .bg-major #0f0f0f)
  static const Color background = Color(0xFF0F0F0F);      // Exact .bg-major from sabaycinema.com
  static const Color headerBackground = Color(0xCC0F0F0F);// Translucent dark header matching page background
  static const Color footerBackground = Color(0xFF0F0F0F);// Seamless footer background matching page background
  static const Color footerGlow = Color(0x265C0612);      // Subtle ambient burgundy glow stop
  static const Color headerRimCyan = Color(0x18FFFFFF);   // Subtle sleek glass rim line
  static const Color headerBorder = Color(0x18FFFFFF);    // Subtle sleek glass rim line
  static const Color surface = Color(0xFF161616);         // Neutral Cinema Dark Surface
  static const Color surfaceLighter = Color(0xFF1F1F1F);  // Elevated Card Surface
  static const Color surfaceElevated = Color(0xFF282828); // Raised Card Highlight
  static const Color surfaceGlass = Color(0xB80F0F0F);    // Translucent Frosted Glass Surface matching cinema canvas

  // Soft Glassmorphic Borders & Highlights
  static const Color glassBorder = Color(0x2EFFFFFF);      // 18% White border
  static const Color glassBorderSubtle = Color(0x18FFFFFF);// 9.5% White border
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

  // Cinema Technology & Status Accents
  static const Color accentCyan = Color(0xFF00E5FF);     // IMAX Laser Cyan
  static const Color accentCyanGlow = Color(0x4D00E5FF);
  static const Color accentGold = Color(0xFFDDAC45);     // VIP Gold Tier
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
    colors: [Color(0xFFE31B23), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFFF5E1B5), Color(0xFFDDAC45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sabayAtmosphereGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.8, 0.7),
    colors: [
      Color(0xFF5C0612), // Signature Sabay Crimson
      Color(0xFF40040E),
      Color(0xFF220308),
      Color(0xFF0F0F0F), // .bg-major
    ],
    stops: [0.0, 0.28, 0.58, 0.88],
  );

  static const LinearGradient burgundyGradient = LinearGradient(
    colors: [Color(0xFF5C0612), Color(0xFF38030B), Color(0xFF0F0F0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient footerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x55111113),
      Color(0xFF09090A),
    ],
    stops: [0.0, 0.22, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C1C1F), Color(0xFF121214)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
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
