import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  final PageController _pageController = PageController();
  final ValueNotifier<bool> _fadeNotifier = ValueNotifier(true);
  int _currentIndex = 0;

  final box = GetStorage();

  void _nextPage() async {
    if (_currentIndex < globalController.onboardingData.length - 1) {
      _fadeNotifier.value = false;
      await Future.delayed(const Duration(milliseconds: 150));
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _fadeNotifier.value = true;
    } else {
      await skip();
    }
  }

  Future<void> skip() async {
    await box.write('seenOnboarding', true);
    globalController.seenOnboarding.value = true;

    await Future.delayed(
        const Duration(milliseconds: 100)); // ensure smoother transition

    if (!globalController.loginPromptedOnce.value) {
      debugPrint('Navigating to login...');
      Get.offAllNamed(AppRoutes.login);
    } else {
      debugPrint('Navigating to navigation...');
      Get.offAllNamed(AppRoutes.navigation);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = AppColors.onboardingBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: globalController.onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _fadeNotifier.value = true;
            },
            itemBuilder: (context, index) {
              final data = globalController.onboardingData[index];
              final isCurrent = index == _currentIndex;

              return ValueListenableBuilder<bool>(
                valueListenable: _fadeNotifier,
                builder: (context, visible, _) {
                  return AnimatedOpacity(
                    opacity: isCurrent && visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(data['image']!, height: 300),
                          const SizedBox(height: 40),
                          Text(
                            data['title']!,
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            data['description']!,
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: skip,
                  child: const Text(StringAssets.skip),
                ),
                Row(
                  children: List.generate(
                    globalController.onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentIndex == index ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentIndex == globalController.onboardingData.length - 1
                        ? StringAssets.getStarted
                        : StringAssets.next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
