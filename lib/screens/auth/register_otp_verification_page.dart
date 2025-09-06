import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/controllers.dart/register_controller.dart';

class RegisterOtpVerificationPage extends StatelessWidget {
  final String email;
  final String name;
  final String password;

  const RegisterOtpVerificationPage({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    // Use existing controller or create if not found
    final controller = Get.put(RegisterController());

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter the OTP sent to $email',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller
                  .otpController, // Use a dedicated otpController if you want (you can add to controller)
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'OTP Code',
              ),
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),

            // Verify button with loading state
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final otp = controller.otpController.text.trim();
                          if (otp.isEmpty) {
                            Get.snackbar('Error', 'Please enter the OTP.');
                            return;
                          }

                          final success = await controller.verifyOtpAndRegister(
                            email: email,
                            otpCode: otp,
                            name: name,
                            password: password,
                          );
                          if (success) {
                            Get.offAllNamed(AppRoutes.navigation,
                                arguments: {'initialIndex': 2});
                          }
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify OTP'),
                )),

            const SizedBox(height: 20),

            // Resend OTP button + countdown
            // Resend OTP button + countdown
            Obx(() {
              final canResend = controller.canRequestOtp;
              final secondsLeft = controller.resendSecondsLeft.value;

              return TextButton(
                onPressed: canResend
                    ? () async {
                        final success =
                            await controller.requestOtpAndStartTimer(email);
                        if (!success) {
                          Get.snackbar('Error', 'Failed to resend OTP');
                        }
                      }
                    : null, // disabled if timer running
                child: canResend
                    ? const Text('Resend OTP')
                    : Text(
                        'Resend OTP in ${secondsLeft}s',
                        style: const TextStyle(color: Colors.grey),
                      ),
              );
            })
          ],
        ),
      ),
    );
  }
}
