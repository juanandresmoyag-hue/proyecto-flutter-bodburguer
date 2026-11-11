import 'package:flutter/material.dart';

class AppColors {
  static const red = Color(0xFFD92300);
  static const ink = Color(0xFF211A17);
  static const brown = Color(0xFF593A31);
  static const background = Color(0xFFFFF8F1);
  static const beige = Color(0xFFF2E8D8);
  static const muted = Color(0xFF927970);
  static const offer = Color(0xFFFFDCD1);
  static const hero = Color(0xFFF8EDDC);
  static const burger = Color(0xFFE9C18F);
  static const quickLogin = Color(0xFFFBF1E2);
}

class AppTheme {
  static ThemeData get data => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      primary: AppColors.red,
      surface: AppColors.background,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.brown, fontSize: 15),
      titleMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 14),
      hintStyle: TextStyle(
        color: Color(0xFFC1B5B0),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: AppColors.brown,
      suffixIconColor: AppColors.brown,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: Colors.white,
        elevation: 1,
        shape: const StadiumBorder(),
      ),
    ),
  );
}

class LoginStyles {
  static const header = TextStyle(
    color: AppColors.ink,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const heroTitle = TextStyle(
    color: AppColors.ink,
    fontSize: 29,
    height: 1.12,
    fontWeight: FontWeight.w800,
  );
  static const heroDescription = TextStyle(
    color: AppColors.brown,
    fontSize: 16,
    height: 1.4,
  );
  static const highlight = TextStyle(color: AppColors.red);
  static const burger = TextStyle(fontSize: 64);
  static const sectionTitle = TextStyle(
    color: AppColors.ink,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const kicker = TextStyle(
    color: AppColors.red,
    fontWeight: FontWeight.w700,
  );
  static const offerText = TextStyle(color: AppColors.ink, fontSize: 15);
  static const offerHeading = TextStyle(
    color: AppColors.red,
    fontWeight: FontWeight.w700,
  );
  static const offerEmphasis = TextStyle(fontWeight: FontWeight.w700);
  static const socialMark = TextStyle(fontSize: 22);
  static const legalLink = TextStyle(decoration: TextDecoration.underline);
  static const primaryButton = TextStyle(
    color: Colors.white,
    fontSize: 23,
    fontWeight: FontWeight.w800,
  );
  static const terms = TextStyle(
    color: AppColors.muted,
    fontSize: 15,
    height: 1.5,
  );

  static ButtonStyle get redButton => ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: AppColors.red,
    elevation: 5,
    shape: const StadiumBorder(),
  );

  static ButtonStyle methodButton(bool selected) => TextButton.styleFrom(
    foregroundColor: selected ? AppColors.ink : AppColors.brown,
    backgroundColor: selected ? Colors.white : Colors.transparent,
    shape: const StadiumBorder(),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );

  static ButtonStyle get guestButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.beige,
    minimumSize: const Size.fromHeight(60),
  );

  static InputDecoration input({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) => InputDecoration(hintText: hint, prefixIcon: prefix, suffixIcon: suffix);
}

/// Scoped styles for profile forms; existing login and home keep their theme.
class ProfileStyles {
  static InputDecoration input(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.beige),
        ),
        errorMaxLines: 3,
      );

  static ButtonStyle get primaryButton => LoginStyles.redButton.copyWith(
    minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}
