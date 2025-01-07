import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: "Welcome to Creative Prompts!",
      description:
          "Let's get you started with personalized creative prompts.",
      icon: Icons.create,
    ),
    TutorialPage(
      title: "Daily Prompts",
      description:
          "You'll receive 3 creative prompts each day based on your interests.",
      icon: Icons.calendar_today,
    ),
    TutorialPage(
      title: "Rating System",
      description: "Rate prompts to help us understand what inspires you:\n\n"
          "⭐ Hated it - Really didn't connect with this prompt\n"
          "⭐⭐ Didn't like it - Not quite what you were looking for\n"
          "⭐⭐⭐ Neutral - It was okay\n"
          "⭐⭐⭐⭐ Liked it - This prompt sparked some creativity\n"
          "⭐⭐⭐⭐⭐ Loved it - Perfect prompt for your creative journey!",
      icon: Icons.star,
    ),
    TutorialPage(
      title: "Weekly Calibration",
      description:
          "Every week, you can adjust your activity preferences and fine-tune your prompt experience.",
      icon: Icons.refresh,
    ),
    TutorialPage(
      title: "Learning From You",
      description:
          "Your ratings help us understand your preferences and generate better prompts over time.",
      icon: Icons.psychology,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildTutorialPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 80),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Next'),
                        )
                      : TextButton(
                          onPressed: () async {
                            // Mark tutorial as seen
                            final tutorialService = TutorialService();
                            await tutorialService.markTutorialAsSeen();

                            if (mounted) {
                              // Go back to WelcomeScreen
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Get Started'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}