import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const bgPrimary = Color(0xFF1F2C4E);
  static const bgSecondary = Color(0xFF2E3C6B);

  static const card = Color(0xFF3D4A78);
  static const cardLight = Color(0xFF5A6683);

  static const button = Color(0xFF526CC9);
  static const buttonHover = Color(0xFF869AEE);

  static const accentPurple = Color(0xFFA66BE0);
  static const accentPink = Color(0xFFEAA7ED);

  static const textPrimary = Color(0xFFF0F0F3);
  static const textSecondary = Color(0xFFB2B4BB);

  static const border = Color(0xFF667093);
  static const logo = Color(0xFFE9A6EE);

  static const success = Color(0xFF43D9A2);
  static const danger = Color(0xFFEF6B6B);
  static const warning = Color(0xFFEAC36B);

  static const logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, accentPurple],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [button, accentPurple],
  );
}
