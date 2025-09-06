import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/login_controller.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);
  final loginController = Get.find<LoginController>(tag: ControllerIds.login);
  final box = GetStorage();

  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _fadeOutController;
  late final Animation<double> _fadeOutAnimation;

  bool _showTextAnimation = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeOutAnimation = CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(
        const AssetImage('assets/images/logo.png'),
        context,
      );

      _logoController.forward();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _showTextAnimation = true);
        }
      });

      // Call auto login logic
      await _handleAutoLoginAndNavigation();
    });
  }

  Future<void> _handleAutoLoginAndNavigation() async {
    await loginController.tryAutoLogin();

    globalController.seenOnboarding.value = box.read('seenOnboarding') ?? false;
    globalController.loginPromptedOnce.value =
        box.read('loginPromptedOnce') ?? false;
    globalController.registerPromptedOnce.value =
        box.read('registerPromptedOnce') ?? false;

    final isLoggedIn = globalController.isLoggedIn.value;
    final seenOnboarding = globalController.seenOnboarding.value;
    final loginPrompted = globalController.loginPromptedOnce.value;

    await Future.delayed(const Duration(milliseconds: 2500));
    await _fadeOutController.forward();

    if (!seenOnboarding) {
      Get.offAllNamed(AppRoutes.onBoarding);
    } else if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.navigation);
    } else if (!loginPrompted) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.navigation); // Guest mode
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeOutAnimation),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoAnimation,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 0.9.sw(context),
                    height: 0.4.sh(context),
                    cacheHeight: 400,
                  ),
                ),
                SizedBox(height: 0.02.sh(context)),
                Text(
                  "ANUGAM",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                SizedBox(height: 0.01.sh(context)),
                if (_showTextAnimation)
                  AnimatedTextKit(
                    totalRepeatCount: 1,
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        "Discover. Travel. Repeat.",
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                        speed: const Duration(milliseconds: 80),
                        cursor: '|',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
