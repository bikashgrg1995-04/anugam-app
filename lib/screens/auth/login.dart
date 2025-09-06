import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/login_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:frontend/utils/validators.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final loginController = Get.find<LoginController>(tag: ControllerIds.login);
  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for keep-alive

    return Scaffold(
      backgroundColor: Colors.white, // ✅ Prevent pure white screen issue
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(0.02.toRes(context)),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Optional: close button only if loginPromptedOnce is false
                    Obx(() {
                      final showClose =
                          !(globalController.loginPromptedOnce.value);
                      return showClose
                          ? Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                onPressed: _skip,
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                    Text(
                      'Welcome Back',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 0.012.toRes(context),
                                color: Colors.black, // ✅ Text visible
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.02.sh(context)),

                    // Email field
                    commonTextField(
                      context: context,
                      focusNode: loginController.usernameFocusNode,
                      from: 'login',
                      label: 'Email',
                      controller: loginController.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),

                    // Password field
                    Obx(() => commonTextField(
                          context: context,
                          focusNode: loginController.passwordFocusNode,
                          from: 'login',
                          label: 'Password',
                          controller: loginController.passwordController,
                          obscureText: loginController.obscureText.value,
                          validator: validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              loginController.obscureText.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: loginController.toggleObscureText,
                          ),
                        )),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // 👉 Navigate to forgot password page
                          Get.toNamed(AppRoutes.forgotPassword);
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 14.0, color: Colors.blue),
                        ),
                      ),
                    ),

                    // Submit button
                    Obx(() => ElevatedButton(
                          onPressed: loginController.isFormFilled.value &&
                                  !loginController.isLoading.value
                              ? () => _submit()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.01.sh(context),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: loginController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 0.012.toRes(context),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        )),

                    SizedBox(height: 0.01.sh(context)),

                    // Register button
                    TextButton(
                      onPressed: () {
                        //globalController.loginPromptedOnce.value = true;
                        Get.toNamed(AppRoutes.register);
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(fontSize: 14.0, color: Colors.blue),
                      ),
                    ),

                    // Optional Skip button
                    Obx(() {
                      final showSkip =
                          !(globalController.loginPromptedOnce.value);
                      return showSkip
                          ? TextButton(
                              onPressed: _skip,
                              child: Text(
                                "Maybe Later",
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.grey),
                              ),
                            )
                          : const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final box = GetStorage();
      final success = await loginController.loginUser();
      if (success) {
        globalController.isLoggedIn.value = true;

        await box.write('isLoggedIn', true);

        // ✅ Clear login fields
        loginController.emailController.clear();
        loginController.passwordController.clear();

        Fluttertoast.showToast(msg: "Welcome Back, Login Successful.");
        Get.offAllNamed(AppRoutes.navigation, arguments: {'initialIndex': 2});
      } else {
        Fluttertoast.showToast(msg: "Login Failed");
      }
    }
  }

  void _skip() async {
    await globalController.skipLoginRegiser();
    Get.offAllNamed(AppRoutes.navigation);
  }
}
