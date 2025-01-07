import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import 'prompt_selection_screen.dart';

class ActivitySelectionScreen extends StatefulWidget {
  const ActivitySelectionScreen({super.key});

  @override
  State<ActivitySelectionScreen> createState() => _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  // Existing activity options
  final List<String> activities = ["Writing", "Drawing", "Music", "Poetry"];
  // Searchable activity database
  final List<String> allActivities = ["Exploring outside"];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();
    final selectedActivities = userProfileProvider.userProfile.selectedActivities;

    // Filter the suggestions based on searchQuery (fuzzy matching)
    final List<String> searchResults = allActivities.where((activity) {
      final query = searchQuery.toLowerCase();
      final target = activity.toLowerCase();
      return query.length >= 3 && target.contains(query);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "WHAT ACTIVITIES ARE YOU INTERESTED IN?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search for activity...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Search suggestions
            if (searchResults.isNotEmpty && searchQuery.isNotEmpty)
              ...searchResults.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    if (!activities.contains(suggestion)) {
                      setState(() {
                        activities.add(suggestion);
                      });
                    }
                    userProfileProvider.addActivity(suggestion);
                    setState(() {
                      searchQuery = "";
                    });
                  },
                );
              }),
            const SizedBox(height: 16),
            // Display activity buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities.map((activity) {
                final isSelected = selectedActivities.contains(activity);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      userProfileProvider.removeActivity(activity);
                    } else {
                      userProfileProvider.addActivity(activity);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Text(
                      activity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: selectedActivities.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromptSelectionScreen(),
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