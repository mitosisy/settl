import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:settl/core/theme/theme_extension.dart';
import 'package:settl/core/constants/strings.dart';
import 'package:settl/core/widgets/gradient_scaffold.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': Strings.onboardingTitle1,
      'body': Strings.onboardingBody1,
      'icon': 'verified_user', // Mock icon name
    },
    {
      'title': Strings.onboardingTitle2,
      'body': Strings.onboardingBody2,
      'icon': 'wifi_off',
    },
    {
      'title': Strings.onboardingTitle3,
      'body': Strings.onboardingBody3,
      'icon': 'key',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'verified_user':
        return Icons.verified_user_rounded;
      case 'wifi_off':
        return Icons.wifi_off_rounded;
      case 'key':
        return Icons.key_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _CarouselPage(
                    title: _pages[index]['title']!,
                    body: _pages[index]['body']!,
                    icon: _getIconData(_pages[index]['icon']!),
                  );
                },
              ),
            ),
            
            // Bottom Section: Indicators and CTA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? context.colors.primary
                              : context.colors.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () {
                        if (_currentIndex < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          context.go('/wallet_setup');
                        }
                      },
                      child: Text(
                        _currentIndex < _pages.length - 1
                            ? 'Next'
                            : Strings.getStarted,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselPage extends StatelessWidget {
  const _CarouselPage({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon/Graphic
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.white : Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: context.isDarkMode ? Colors.black : Colors.white,
            ),
          )
          .animate()
          .scale(duration: 400.ms, curve: Curves.easeOutBack)
          .fadeIn(),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            title,
            style: context.typography.headlineLarge,
            textAlign: TextAlign.center,
          )
          .animate()
          .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms)
          .fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Body
          Text(
            body,
            style: context.typography.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms)
          .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
