import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_keys.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  Future<List<String>> generatePrompts(
      List<String> selectedActivities, List<String> ratedPrompts) async {
    try {
      List<String> allPrompts = [];

      for (final activity in selectedActivities) {
        final promptText = '''
Based on this activity: $activity

Generate 5 unique, specific, and engaging creative prompts. Each prompt should:
1. Be related to the user's selected activity: $activity.
2. Be specific and actionable.
3. Encourage creativity and exploration
4. Be 10-15 words long
5. Start with an action verb

Format the response as a simple list of 5 prompts, one per line.
''';

        final content = Content.text(promptText);
        final response = await _model.generateContent([content]);
        final responseText = response.text;

        if (responseText == null) {
          print("Empty response for activity: $activity");
          continue; // Skip to the next activity if the response is empty
        }

        List<String> activityPrompts = responseText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .take(5)
            .toList();

        allPrompts.addAll(activityPrompts);
      }

      return allPrompts;
    } catch (e) {
      print("Error generating prompts: $e");
      return [];
    }
  }
}