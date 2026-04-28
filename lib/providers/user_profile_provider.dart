import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/widget_update_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _profile = await _dbService.getUserProfile();

    if (_profile != null) {
      await WidgetUpdateService.saveProfileForWidget(_profile!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProfile(UserProfile profile) async {
    await _dbService.createUserProfile(profile);
    _profile = profile;
    await WidgetUpdateService.saveProfileForWidget(profile);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _dbService.updateUserProfile(profile);
    _profile = profile;
    await WidgetUpdateService.saveProfileForWidget(profile);
    notifyListeners();
  }

  Future<void> restartProgress(UserProfile newProfile) async {
    await _dbService.deleteUserProfile();
    await _dbService.createUserProfile(newProfile);
    _profile = newProfile;
    await WidgetUpdateService.saveProfileForWidget(newProfile);
    notifyListeners();
  }

  int getMoneySaved() => _profile?.getMoneySaved() ?? 0;
  int getDaysSinceQuit() => _profile?.getDaysSinceQuit() ?? 0;
  int getMonthsSinceQuit() => _profile?.getMonthsSinceQuit() ?? 0;
  double getSmokedCigarettesAvoided() =>
      _profile?.getSmokedCigarettesAvoided() ?? 0;
  double getHealthImprovement() => _profile?.getHealthImprovement() ?? 0;
}
