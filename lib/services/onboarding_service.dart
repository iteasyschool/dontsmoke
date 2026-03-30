import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();

  factory OnboardingService() {
    return _instance;
  }

  OnboardingService._internal();

  static const String _onboardingKey = 'isOnboardingCompleted';

  /// Проверить, был ли завершен онбординг
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      // If SharedPreferences channel is temporarily unavailable,
      // treat onboarding as incomplete instead of crashing.
      return false;
    }
  }

  /// Отметить онбординг как завершенный
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
      // Ignore temporary storage failures to avoid blocking UX.
    }
  }

  /// Сбросить статус онбординга (для тестирования)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
    } catch (_) {
      // Ignore temporary storage failures.
    }
  }
}
