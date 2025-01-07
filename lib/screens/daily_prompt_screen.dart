import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/gemini_service.dart';
import 'summary_screen.dart';

class DailyPromptScreen extends StatefulWidget {
  const DailyPromptScreen({super.key});

  @override
  State<DailyPromptScreen> createState() => _DailyPromptScreenState();
}

class _DailyPromptScreenState extends State<DailyPromptScreen> {
  final GeminiService _geminiService = GeminiService();
  int currentPromptIndex = 0;
  int? selectedRating;
  bool showFlipMessage = false;
  bool isLoading = true;
  List<String> dailyPrompts = [];

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    final userProfile = context.read<UserProfileProvider>().userProfile;

    // Use the round-robin method to generate 3 prompts
    final prompts = await _generatePromptsRoundRobin(
      userProfile.selectedActivities,
      userProfile.ratedPrompts.map((rp) => rp.prompt).toList(),
      3, // Generate exactly 3 prompts
    );

    if (mounted) {
      setState(() {
        dailyPrompts = prompts;
        isLoading = false;
      });
    }
  }

  Future<List<String>> _generatePromptsRoundRobin(
      List<String> selectedActivities,
      List<String> ratedPrompts,
      int totalPromptsNeeded) async {
    List<String> generatedPrompts = [];
    Map<String, List<String>> promptsByActivity = {};

    // Generate prompts for each activity
    for (String activity in selectedActivities) {
      promptsByActivity[activity] = await _geminiService.generatePrompts(
        [activity],
        ratedPrompts,
      );
    }

    // Distribute prompts in a round-robin fashion
    int activityIndex = 0;
    while (generatedPrompts.length < totalPromptsNeeded) {
      String currentActivity =
          selectedActivities[activityIndex % selectedActivities.length];
      List<String> activityPrompts = promptsByActivity[currentActivity]!;

      if (activityPrompts.isNotEmpty) {
        generatedPrompts.add(activityPrompts.removeAt(0));
      }

      activityIndex++;
    }

    return generatedPrompts;
  }

  void _ratePrompt(int rating) {
    final userProfileProvider = context.read<UserProfileProvider>();
    userProfileProvider.ratePrompt(dailyPrompts[currentPromptIndex], rating);

    setState(() {
      selectedRating = rating;
      showFlipMessage = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (currentPromptIndex < 2) {
        setState(() {
          currentPromptIndex++;
          selectedRating = null;
          showFlipMessage = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SummaryScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const CircularProgressIndicator(
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Generating your creative prompts...",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ] else if (!showFlipMessage) ...[
                Text(
                  "PROMPT ${currentPromptIndex + 1}/3",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  dailyPrompts[currentPromptIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < (selectedRating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        size: 32,
                        color: Colors.blue,
                      ),
                      onPressed: () => _ratePrompt(index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Rate this prompt to see the next one",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.screen_rotation,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  "FLIP YOUR DEVICE\nTO SEE THE NEXT PROMPT",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}