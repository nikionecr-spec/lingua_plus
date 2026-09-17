import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingua_plus/core/constants/app_strings.dart';
import 'package:lingua_plus/core/providers.dart';
import 'package:lingua_plus/core/router/app_router.dart';
import 'package:lingua_plus/core/theme/app_colors.dart';
import 'package:lingua_plus/core/theme/app_dimensions.dart';
import 'package:lingua_plus/shared/widgets/ui_kit.dart';

/// First-launch onboarding: 3 swipeable intro pages, then → home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<(String, String, IconData)> _pages = [
    (
      AppStrings.onboardingTitle1,
      AppStrings.onboardingBody1,
      Icons.menu_book_rounded,
    ),
    (
      AppStrings.onboardingTitle2,
      AppStrings.onboardingBody2,
      Icons.auto_stories_rounded,
    ),
    (
      AppStrings.onboardingTitle3,
      AppStrings.onboardingBody3,
      Icons.psychology_rounded,
    ),
  ];

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(sharedPrefsProvider).setBool('onboarded', true);
    if (!mounted) return;
    context.go(Routes.home);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final (title, body, icon) = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.rXl,
                              ),
                            ),
                            child: Icon(icon, size: 56, color: Colors.white),
                          ),
                          const SizedBox(height: AppDimensions.xxl),
                          Text(
                            title,
                            style:
                                Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            body,
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text(AppStrings.onboardingSkip),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        PageDot(active: i == _page),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              GradientButton(
                label: _isLast ? AppStrings.onboardingStart : AppStrings.next,
                icon: _isLast
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_back_rounded, // RTL: next points LEFT
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
