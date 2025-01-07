import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile();

  UserProfile get userProfile => _userProfile;

  void addActivity(String activity) {
    if (!_userProfile.selectedActivities.contains(activity)) {
      final updatedActivities = [..._userProfile.selectedActivities, activity];
      _userProfile = _userProfile.copyWith(selectedActivities: updatedActivities);
      notifyListeners();
    }
  }

  void removeActivity(String activity) {
    final updatedActivities = _userProfile.selectedActivities
        .where((a) => a != activity)
        .toList();
    _userProfile = _userProfile.copyWith(selectedActivities: updatedActivities);
    notifyListeners();
  }

  void ratePrompt(String prompt, int rating) {
    final newRatedPrompt = RatedPrompt(
      prompt: prompt,
      rating: rating,
      ratedAt: DateTime.now(),
    );
    final updatedRatedPrompts = [..._userProfile.ratedPrompts, newRatedPrompt];
    _userProfile = _userProfile.copyWith(ratedPrompts: updatedRatedPrompts);
    notifyListeners();
  }

  void setCalibrated(bool isCalibrated) {
    _userProfile = _userProfile.copyWith(isCalibrated: isCalibrated);
    notifyListeners();
  }
}