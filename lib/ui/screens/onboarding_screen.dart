import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_spark_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (hasSeenOnboarding) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showOnboarding
        ? OnboardingScreen(
      onDone: _completeOnboarding,
      onSkip: _completeOnboarding,
    )
        : const DailySparkScreen();
  }
}

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onDone;
  final VoidCallback onSkip;

  const OnboardingScreen({
    super.key,
    required this.onDone,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      PageViewModel(
        title: "Welcome to SparkVow!",
        body: "Build discipline by tracking daily tasks and staying focused.",
        image: const Center(
          child: Icon(Icons.local_fire_department, size: 100, color: Colors.deepPurple),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      PageViewModel(
        title: "Master Your Focus",
        body: "Use the Pomodoro timer to boost productivity and avoid distractions.",
        image: const Center(
          child: Icon(Icons.timer, size: 100, color: Colors.green),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 16),
        ),
      ),
      PageViewModel(
        title: "Earn Badges",
        body: "Stay consistent to unlock Gold and Silver badges for your progress!",
        image: const Center(
          child: Icon(Icons.emoji_events, size: 100, color: Colors.amber),
        ),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyTextStyle: TextStyle(fontSize: 16),
        ),
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      onDone: onDone,
      onSkip: onSkip,
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      dotsDecorator: const DotsDecorator(
        activeColor: Colors.deepPurple,
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
      ),
    );
  }
}