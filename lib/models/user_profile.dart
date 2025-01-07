class UserProfile {
  final List<String> selectedActivities;
  final List<RatedPrompt> ratedPrompts;
  final bool isCalibrated;

  UserProfile({
    this.selectedActivities = const [],
    this.ratedPrompts = const [],
    this.isCalibrated = false,
  });

  UserProfile copyWith({
    List<String>? selectedActivities,
    List<RatedPrompt>? ratedPrompts,
    bool? isCalibrated,
  }) {
    return UserProfile(
      selectedActivities: selectedActivities ?? this.selectedActivities,
      ratedPrompts: ratedPrompts ?? this.ratedPrompts,
      isCalibrated: isCalibrated ?? this.isCalibrated,
    );
  }
}

class RatedPrompt {
  final String prompt;
  final int rating; // 1-5 stars
  final DateTime ratedAt;

  RatedPrompt({
    required this.prompt,
    required this.rating,
    required this.ratedAt,
  });
} 