import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/router/app_router.dart';
import 'package:seeker/src/features/onboarding/presentation/model/onboarding_item.dart';
import 'package:seeker/src/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:seeker/src/features/onboarding/presentation/widgets/onboarding_controls.dart';
import 'package:seeker/src/features/onboarding/presentation/widgets/onboarding_floating_item.dart';
import 'package:seeker/src/features/onboarding/presentation/widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _page => _controller.hasClients ? (_controller.page ?? 0) : 0;

  void _goAuth() => context.goNamed(AppRouteNames.auth);

  void _next() {
    if (_page < 1.5) {
      _controller.nextPage(duration: 600.ms, curve: Curves.easeInOutCubic);
    } else {
      _goAuth();
    }
  }

  void _skip() {
    _controller.animateToPage(
      2,
      duration: 700.ms,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final page = _page;

          return Stack(
            children: [
              Positioned.fill(child: OnboardingBackground(page: page)),

              // Тексты и свайп страниц
              PageView(
                controller: _controller,
                children: const [
                  OnboardingPageContent(
                    title: 'Choose a Destination',
                    description: 'Select a place for your trip easily and know the exact cost of the tour.',
                  ),
                  OnboardingPageContent(
                    title: 'Fly to Destination',
                    description: 'Finally get ready for the tour and go to your desired destinations.',
                  ),
                  OnboardingPageContent(
                    title: 'Explore Destinations',
                    description: 'Discover the places for your trip in the world and feel great.',
                  ),
                ],
              ),

              // Объекты ВЫШЕ PageView, иначе они не ловят касания
              for (int i = 0; i < kOnboardingItems.length; i++)
                OnboardingFloatingItem(
                  index: i,
                  item: kOnboardingItems[i],
                  page: page,
                  w: w,
                  h: h,
                ),

              OnboardingControls(
                controller: _controller,
                page: page,
                onSkip: _skip,
                onNext: _next,
              ),
            ],
          );
        },
      ),
    );
  }
}
