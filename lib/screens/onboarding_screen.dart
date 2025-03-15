import 'package:flutter/material.dart';
import 'package:mamaapp/services/shared_preferences_service.dart';
import 'package:mamaapp/screens/login_screen.dart';
import 'package:mamaapp/screens/register_screen.dart';
import 'package:mamaapp/screens/user_onboarding/first_child_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Check your Health Condition',
      image: 'assets/doctors.png',
      description: '',
    ),
    OnboardingItem(
      image: 'assets/pregnantmother.png',
      title: 'Track your Pregnancy Journey',
      description: '',
    ),
    OnboardingItem(
      image: 'assets/learning.png',
      title: 'Discover helpful Maternal Tips',
      description: '',
    ),
    OnboardingItem(
      image: 'assets/medicine.png',
      title: '',
      description:
          'Caring for you and your little one every step of the way. Explore health tips, expert advice and nearby healthcare services for a safer and healthier journey to motherhood!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onSkip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await SharedPreferencesService.setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(item: _items[index]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == _items.length - 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome to Mama App',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Caring for you and your little one every step of the way. '
                          'Explore health tips, expert advice and nearby healthcare '
                          'services for a safer and healthier journey to motherhood!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _finishOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCB4172),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _onSkip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFFCB4172),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCB4172),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/pinklogo.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 8),
                const Text(
                  'MAMA APP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCB4172),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (item.title.isNotEmpty) ...[
              Text(
                item.title.replaceAllMapped(
                  RegExp(r'(\S+\s+\S+)\s+'),
                  (match) => '${match.group(1)}\n',
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCB4172),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                item.image,
                fit: BoxFit.contain,
              ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
