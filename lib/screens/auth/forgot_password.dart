import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/forgot_password_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/utils/validators.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:frontend/utils/extensions.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final forgotPasswordController =
      Get.find<ForgotPasswordController>(tag: ControllerIds.forgotPassword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(0.02.toRes(context)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Enter your registered email to receive a reset code.",
                  style: TextStyle(fontSize: 0.012.toRes(context)),
                ),
                SizedBox(height: 0.02.sh(context)),
                commonTextField(
                  context: context,
                  focusNode: forgotPasswordController.emailFocusNode,
                  from: 'forgot',
                  label: 'Email',
                  controller: forgotPasswordController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                Obx(() {
                  if (forgotPasswordController.otpSent.value) {
                    return Column(
                      children: [
                        SizedBox(height: 0.02.sh(context)),
                        commonTextField(
                          context: context,
                          focusNode: forgotPasswordController.otpFocusNode,
                          from: 'otp',
                          label: 'OTP Code',
                          controller: forgotPasswordController.otpController,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter OTP code' : null,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(height: 0.03.sh(context)),
                Obx(() {
                  return ElevatedButton(
                    onPressed: forgotPasswordController.isLoading.value
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (!forgotPasswordController.otpSent.value) {
                                final sent = await forgotPasswordController
                                    .sendOtpToEmail();
                                if (sent) {
                                  Fluttertoast.showToast(msg: 'OTP sent');
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Failed to send OTP');
                                }
                              } else {
                                final verified =
                                    await forgotPasswordController.verifyOtp();
                                if (verified) {
                                  Get.toNamed(AppRoutes.resetPassword);
                                } else {
                                  Fluttertoast.showToast(msg: 'Invalid OTP');
                                }
                              }
                            }
                          },
                    child: forgotPasswordController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(forgotPasswordController.otpSent.value
                            ? "Verify OTP"
                            : "Send OTP"),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
