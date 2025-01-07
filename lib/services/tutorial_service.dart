import 'package:shared_preferences/shared_preferences.dart';  // Fixed import
class TutorialService {
  static const String _hasSeenTutorialKey = 'has_seen_tutorial';

  Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTutorialKey) ?? false;
  }

  Future<void> markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTutorialKey, true);
  }
}