import 'package:flutter/material.dart';
import 'app_colors.dart';

class EmotionPalette {
  final Color main;
  final Color lightBackground;
  final List<Color> gradient;
  final Color shadow;
  final IconData icon;

  const EmotionPalette({
    required this.main,
    required this.lightBackground,
    required this.gradient,
    required this.shadow,
    required this.icon,
  });
}

class EmotionThemeMapper {
  static EmotionPalette getPalette(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'ansiedad':
        return EmotionPalette(
          main: AppColors.anxietyOrange,
          lightBackground: AppColors.anxietyOrange.withValues(alpha: 0.1),
          gradient: [AppColors.anxietyOrange, const Color(0xFFD97706)],
          shadow: AppColors.anxietyOrange.withValues(alpha: 0.3),
          icon: Icons.sentiment_dissatisfied,
        );
      case 'calma':
        return EmotionPalette(
          main: AppColors.calmTeal,
          lightBackground: AppColors.calmTeal.withValues(alpha: 0.1),
          gradient: [AppColors.calmTeal, AppColors.primaryDark],
          shadow: AppColors.calmTeal.withValues(alpha: 0.3),
          icon: Icons.sentiment_satisfied_alt,
        );
      case 'enojo':
        return EmotionPalette(
          main: AppColors.angerPurple,
          lightBackground: AppColors.angerPurple.withValues(alpha: 0.1),
          gradient: [AppColors.angerPurple, const Color(0xFF7E22CE)],
          shadow: AppColors.angerPurple.withValues(alpha: 0.3),
          icon: Icons.mood_bad,
        );
      case 'tristeza':
        return EmotionPalette(
          main: AppColors.sadnessBlue,
          lightBackground: AppColors.sadnessBlue.withValues(alpha: 0.1),
          gradient: [AppColors.sadnessBlue, const Color(0xFF1D4ED8)],
          shadow: AppColors.sadnessBlue.withValues(alpha: 0.3),
          icon: Icons.sentiment_very_dissatisfied,
        );
      default:
        return EmotionPalette(
          main: AppColors.neutralGray,
          lightBackground: AppColors.neutralGray.withValues(alpha: 0.1),
          gradient: [AppColors.neutralGray, const Color(0xFF64748B)],
          shadow: AppColors.neutralGray.withValues(alpha: 0.2),
          icon: Icons.circle,
        );
    }
  }
}