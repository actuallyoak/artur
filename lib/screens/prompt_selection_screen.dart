import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/gemini_service.dart';
import 'finish_calibration_screen.dart';

class PromptSelectionScreen extends StatefulWidget {
  const PromptSelectionScreen({super.key});

  @override
  State<PromptSelectionScreen> createState() => _PromptSelectionScreenState();
}

class _PromptSelectionScreenState extends State<PromptSelectionScreen> {
  final GeminiService _geminiService = GeminiService();
  List<String> currentPrompts = [];
  Set<String> selectedPrompts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialPrompts();
  }

  Future<void> _loadInitialPrompts() async {
    setState(() => isLoading = true);

    final userProfile = context.read<UserProfileProvider>().userProfile;
    final prompts = await _geminiService.generatePrompts(
      userProfile.selectedActivities,
      userProfile.ratedPrompts.map((rp) => rp.prompt).toList(),
    );

    if (mounted) {
      setState(() {
        currentPrompts = _filterPrompts(prompts);
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPrompts() async {
    setState(() => isLoading = true);

    final userProfile = context.read<UserProfileProvider>().userProfile;

    // Generate prompts in a round-robin fashion
    List<String> newPrompts = await _generatePromptsRoundRobin(
      userProfile.selectedActivities,
      [], // Pass an empty list for rated prompts
      5, // Ensure we get 5 prompts
    );

    if (mounted) {
      setState(() {
        // Replace old prompts with new ones
        currentPrompts = _filterPrompts(newPrompts);

        isLoading = false;
      });
    }
  }

  // Filter out previously selected prompts
  List<String> _filterPrompts(List<String> prompts) {
    return prompts.where((prompt) => !selectedPrompts.contains(prompt)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CHOOSE 3 PROMPTS YOU LIKE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "These will help personalize future prompts",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: currentPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = currentPrompts[index];
                      final isSelected = selectedPrompts.contains(prompt);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              prompt,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.blue)
                                : const Icon(Icons.circle_outlined),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedPrompts.remove(prompt);
                                } else if (selectedPrompts.length < 3) {
                                  selectedPrompts.add(prompt);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (!isLoading) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Select ${3 - selectedPrompts.length} more prompt${selectedPrompts.length == 2 ? '' : 's'}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(                  
                  child: TextButton.icon(
                    onPressed: isLoading || selectedPrompts.length == 3 ? null : _refreshPrompts,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Get New Prompts"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: selectedPrompts.length == 3
          ? FloatingActionButton(
              onPressed: () {
                final userProfileProvider = context.read<UserProfileProvider>();
                // Add selected prompts to user profile with 5-star rating
                for (final prompt in selectedPrompts) {
                  userProfileProvider.ratePrompt(prompt, 5);
                }
                // Mark calibration as complete
                userProfileProvider.setCalibrated(true);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinishCalibrationScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }
}