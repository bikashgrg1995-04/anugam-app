import 'package:flutter/material.dart';
import 'package:frontend/bindings/initial_binding.dart';
import 'package:frontend/onboarding_screen.dart';
import 'package:frontend/screens/auth/forgot_password.dart';
import 'package:frontend/screens/auth/login.dart';
import 'package:frontend/screens/auth/register.dart';
import 'package:frontend/screens/auth/register_otp_verification_page.dart';
import 'package:frontend/screens/auth/reset_password_page.dart';
import 'package:frontend/screens/detination_detail_screen.dart';
import 'package:frontend/splash_screen.dart';
import 'package:get/get.dart';
import '../screens/navigation_page.dart';
import '../screens/home_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onBoarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.navigation,
      page: () => const NavigationPage(),
      transition: Transition.fadeIn,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.discover,
      page: () => const DiscoverScreen(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    //auth
    //login and register

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      transition: Transition.downToUp,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
      binding: InitialBinding(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.downToUp,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.destinationDetailScreen,
      page: () => const DestinationDetailScreen(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.resetPassword,
      page: () => ResetPasswordPage(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: AppRoutes.registerOtpVerification,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return RegisterOtpVerificationPage(
          email: args['email'],
          name: args['name'],
          password: args['password'],
        );
      },
      transition: Transition.downToUp,
      curve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 400),
      binding: InitialBinding(),
    ),
  ];
}
