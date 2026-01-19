import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class TacticalTheme {
  // Color Palette
  static const Color voidBlack = Color(0xFF050505);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceGlass = Color(0x40FFFFFF);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonAmber = Color(0xFFFFD600);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonRed = Color(0xFFFF0040);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFA0A0A0);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      colorScheme: const ColorScheme.dark(
        background: voidBlack,
        surface: surfaceDark,
        primary: neonCyan,
        secondary: neonAmber,
        error: neonRed,
        onPrimary: voidBlack,
        onSecondary: voidBlack,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: neonCyan,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: neonCyan,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: neonCyan,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceDark,
          foregroundColor: neonCyan,
          side: const BorderSide(color: neonCyan, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: surfaceGlass, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: surfaceGlass),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: surfaceGlass),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        hintStyle: GoogleFonts.rajdhani(
          color: textSecondary,
        ),
        labelStyle: GoogleFonts.rajdhani(
          color: neonCyan,
        ),
      ),
    );
  }
  
  // Glass morphism container
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 12,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? surfaceGlass,
            width: 1,
          ),
          color: surfaceDark.withOpacity(0.8),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
  
  // Chamfered container for messages
  static Widget chamferedContainer({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry? padding,
    double chamferSize = 8,
  }) {
    return CustomPaint(
      painter: ChamferPainter(
        color: color ?? surfaceDark,
        chamferSize: chamferSize,
      ),
      child: Container(
        padding: padding,
        child: child,
      ),
    );
  }
  
  // Status colors
  static Color getStatusColor(bool isConnected) {
    return isConnected ? neonCyan : neonAmber;
  }
  
  // Priority colors
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0: // SOS
        return neonRed;
      case 1: // Medical
        return neonAmber;
      case 2: // Alert
        return neonGreen;
      case 3: // Chat
        return neonCyan;
      default:
        return textSecondary;
    }
  }
}

class ChamferPainter extends CustomPainter {
  final Color color;
  final double chamferSize;
  
  ChamferPainter({required this.color, this.chamferSize = 8});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Create chamfered rectangle
    path.moveTo(chamferSize, 0);
    path.lineTo(size.width - chamferSize, 0);
    path.lineTo(size.width, chamferSize);
    path.lineTo(size.width, size.height - chamferSize);
    path.lineTo(size.width - chamferSize, size.height);
    path.lineTo(chamferSize, size.height);
    path.lineTo(0, size.height - chamferSize);
    path.lineTo(0, chamferSize);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant ChamferPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.chamferSize != chamferSize;
  }
}
