import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:luneva_application/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _loading = false;

  void _skip() => _completeOnboarding();

  Future<void> _completeOnboarding() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'onboarded': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
  }

  Widget _buildPage({
    required Color backgroundColor,
    required String lottieUrl,
    required String title,
    required String subtitle,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required String buttonText,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(lottieUrl, height: 220),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const CircularProgressIndicator()
          else
            Row(
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPage(
            backgroundColor: const Color(0xFFE8EAF6), // Light blue
            lottieUrl: 'https://lottie.host/e1ac1e79-6708-4a21-a1cf-5b1b4e838cca/sUM2Te8QbT.json',
            title: 'Track your work and get the result',
            subtitle: 'Remember to keep track of your professional accomplishments.',
            onNext: () => _pageController.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            onSkip: _skip,
            buttonText: 'NEXT',
          ),
          _buildPage(
            backgroundColor: const Color(0xFFFCE4EC), // Light pink
            lottieUrl: 'https://lottie.host/fadde0fa-6f50-4494-8cfd-6bc01911a337/BgGfW2SEe1.json',
            title: 'Stay organized with team',
            subtitle: 'Understand the contributions your colleagues make to your team and company.',
            onNext: () => _pageController.animateToPage(2, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
            onSkip: _skip,
            buttonText: 'NEXT',
          ),
          _buildPage(
            backgroundColor: const Color(0xFFF3E5F5), // Light purple
            lottieUrl: 'https://lottie.host/448b917c-6355-4ea2-a423-3be528eff52e/MPkSYKhQUG.json',
            title: 'Get notified when work happens',
            subtitle: 'Take control of notifications, collaborate live or on your own time.',
            onNext: _completeOnboarding,
            onSkip: _skip,
            buttonText: 'START',
          ),
        ],
      ),
    );
  }
}
