import 'package:flutter/material.dart';

/// Lingua+ palette — dark "midnight" surfaces with a blue→violet premium
/// gradient, plus light-theme counterparts and CEFR/part-of-speech colors.
class AppColors {
  AppColors._();

  // ── Dark (primary) surfaces ────────────────────────────────────────────
  static const Color night = Color(0xFF0A0F24); // page background
  static const Color night2 = Color(0xFF10173A); // secondary surface
  static const Color cardDark = Color(0xFF141C3F); // cards
  static const Color strokeDark = Color(0xFF232D5C); // hairlines / borders

  // ── Light surfaces ─────────────────────────────────────────────────────
  static const Color day = Color(0xFFF5F6FC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color strokeLight = Color(0xFFE3E7F5);

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F7CFF);
  static const Color accent = Color(0xFF9B5CFF);

  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF4F7CFF), Color(0xFF9B5CFF)],
  );

  static const Gradient heroGlow = RadialGradient(
    colors: [Color(0x334F7CFF), Color(0x009B5CFF)],
  );

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textLightMode = Color(0xFF0E1430);
  static const Color textDarkMode = Color(0xFFF2F4FF);
  static const Color mutedDark = Color(0xFF9AA3C7);
  static const Color mutedLight = Color(0xFF66709A);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  /// CEFR level → chip color (consistent across the app).
  static Color levelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF34D399);
      case 'A2':
        return const Color(0xFF4ADE80);
      case 'B1':
        return const Color(0xFF60A5FA);
      case 'B2':
        return const Color(0xFFA78BFA);
      case 'C1':
        return const Color(0xFFF472B6);
      case 'C2':
        return const Color(0xFFF87171);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Part-of-speech → color.
  static Color posColor(String pos) {
    switch (pos) {
      case 'noun':
        return const Color(0xFF60A5FA);
      case 'verb':
        return const Color(0xFFF472B6);
      case 'adjective':
        return const Color(0xFF34D399);
      case 'adverb':
        return const Color(0xFFF59E0B);
      case 'preposition':
        return const Color(0xFFA78BFA);
      case 'conjunction':
        return const Color(0xFF22D3EE);
      case 'pronoun':
        return const Color(0xFFFB923C);
      case 'interjection':
        return const Color(0xFFF87171);
      case 'phrase':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Persian label for a part-of-speech tag.
  static String posLabel(String pos) {
    switch (pos) {
      case 'noun':
        return 'اسم';
      case 'verb':
        return 'فعل';
      case 'adjective':
        return 'صفت';
      case 'adverb':
        return 'قید';
      case 'preposition':
        return 'حرف اضافه';
      case 'conjunction':
        return 'حرف ربط';
      case 'pronoun':
        return 'ضمیر';
      case 'interjection':
        return 'حرف ندا';
      case 'determiner':
        return 'حرف تعریف';
      case 'numeral':
        return 'عدد';
      case 'phrase':
        return 'عبارت';
      default:
        return pos;
    }
  }
}
