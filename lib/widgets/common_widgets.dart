import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/home_controller.dart';
import 'package:frontend/controllers.dart/login_controller.dart';
import 'package:frontend/controllers.dart/profile_controller.dart';
import 'package:frontend/controllers.dart/register_controller.dart';
import 'package:frontend/data/models/destination.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

final loginController = Get.find<LoginController>(tag: ControllerIds.login);
final registerController =
    Get.find<RegisterController>(tag: ControllerIds.register);

final profileController =
    Get.find<ProfileController>(tag: ControllerIds.profile);

Widget commonTextField({
  required BuildContext context,
  FocusNode? focusNode,
  required String from,
  required String label,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    ),
  );
}

Widget welcomeHeader(GlobalController globalController, BuildContext context) {
  final homeController = Get.put(HomeController(), tag: ControllerIds.home);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Profile pic
      GestureDetector(
        onTap: () => Get.offAllNamed(
          AppRoutes.navigation,
          arguments: {'initialIndex': 2},
        ),
        child: Container(
          width: 0.05.toRes(context),
          height: 0.05.toRes(context),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black87,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: globalController.isLoggedIn.value &&
                    globalController.currentUser.value?.profilePicUrl != null
                ? CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl:
                        globalController.currentUser.value!.profilePicUrl!,
                    placeholder: (context, url) => Center(
                      child: Icon(
                        Icons.account_circle,
                        size: 0.045.toRes(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : Icon(
                    Icons.account_circle,
                    size: 0.045.toRes(context),
                    color: Colors.grey.shade600,
                  ),
          ),
        ),
      ),

      const SizedBox(width: 12),

      // Greeting text
      Expanded(
        child: Obx(() {
          final data = globalController.currentUser.value;
          final isLoggedIn = globalController.isLoggedIn.value;

          final firstName = isLoggedIn
              ? (data?.fullName.split(' ').first ?? 'User')
              : 'Traveler';

          // Time-based greeting
          final hour = DateTime.now().hour;
          String greeting;
          if (hour < 12) {
            greeting = 'Good Morning';
          } else if (hour < 17) {
            greeting = 'Good Afternoon';
          } else {
            greeting = 'Good Evening';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$greeting, $firstName 👋',
                style: TextStyle(
                  fontSize: 0.012.toRes(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Explore the world around you',
                style: TextStyle(
                  fontSize: 0.01.toRes(context),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          );
        }),
      ),

      // Notification icon with badge
      GestureDetector(
        onTap: () {
          // Navigate to notifications page
          //Get.toNamed(AppRoutes.notifications);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none,
              size: 0.03.toRes(context),
              color: Colors.grey.shade700,
            ),
            // Badge for unread notifications
            Positioned(
              right: -2,
              top: -2,
              child: Obx(() {
                if (homeController.unreadNotificationsCount.value == 0) {
                  return const SizedBox();
                }
                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      homeController.unreadNotificationsCount.value > 99
                          ? '99+'
                          : homeController.unreadNotificationsCount.value
                              .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget searchBarWidget({
  required VoidCallback onPressed,
  double width = double.infinity,
  required BuildContext context,
  required TextEditingController controller,
  ValueChanged<String>? onChanged,
}) {
  return SizedBox(
    width: width,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 0.01.toRes(context)),
      decoration: InputDecoration(
        hintText: "Search destinations, routes...",
        hintMaxLines: 1,
        hintStyle: TextStyle(fontSize: 0.014.toRes(context)),
        prefixIcon: Icon(Icons.search, size: 0.02.toRes(context)),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.025.toRes(context)),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

Widget sectionHeader({
  required String title,
  required BuildContext context,
}) {
  return Padding(
    padding: EdgeInsets.only(left: 0.01.sh(context)),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 0.015.toRes(context),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

/// ------------------------ Horizontal Destination List ------------------------
Widget horizontalDestinationList({
  required List<Destination> items,
  required BuildContext context,
  required ScrollController scrollController,
  required void Function(Destination destination) onToggleFavorite,
  bool isLoading = false,
  bool isFetchingMore = false, // new flag for pagination fetch
}) {
  return SizedBox(
    height: 0.18.sh(context),
    child: Obx(() {
      final totalCount =
          items.length + (isFetchingMore ? 1 : 0); // add loader at end

      return ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          // Loader at the end
          if (isFetchingMore && index == totalCount - 1) {
            return SizedBox(
              width: 0.35.sw(context),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final destination = items[index];

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 0.03.sw(context),
              right: index == items.length - 1 ? 0 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.destinationDetailScreen,
                  arguments: {'destination': destination},
                );
              },
              child: Container(
                width: 0.35.sw(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Image
                      CachedNetworkImage(
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: destination.mainImageUrl ?? '',
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 40, color: Colors.grey),
                          ),
                        ),
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Favorite button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onToggleFavorite(destination),
                          child: Obx(() => CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  destination.isFavorite.value
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: destination.isFavorite.value
                                      ? Colors.red
                                      : Colors.white,
                                  size: 18,
                                ),
                              )),
                        ),
                      ),

                      // Name
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          destination.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 0.014.toRes(context),
                            shadows: const [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black87,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }),
  );
}

Widget quickActions({
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("More Features",
          style: TextStyle(
              fontSize: 0.02.toRes(context), fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 0.03.sw(context),
          runSpacing: 0.03.sh(context),
          children: [
            featuredCard(
                icon: Icons.map,
                label: "Plan Itinerary",
                onTap: () => Get.toNamed('/itinerary'),
                context: context),
            featuredCard(
                icon: Icons.add_location_alt_outlined,
                label: "Suggest a Place",
                onTap: () => Get.toNamed('/contribute'),
                context: context),
            featuredCard(
                icon: Icons.bookmark,
                label: "Saved Places",
                onTap: () => Get.toNamed('/saved'),
                context: context),
            featuredCard(
                icon: Icons.edit_note_rounded,
                label: "My Diary",
                onTap: () => Get.toNamed('/diary'),
                context: context),
          ],
        ),
      ),
    ],
  );
}

Widget featuredCard({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 0.19.sw(context),
      padding: EdgeInsets.all(0.01.toRes(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.025.toRes(context)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 0.03.toRes(context), color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 0.01.toRes(context))),
        ],
      ),
    ),
  );
}

/// Shimmer placeholder for horizontal destination list
Widget shimmerCard(BuildContext context, {required int count}) {
  return SizedBox(
    height: 0.22.sh(context),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(width: 0.04.sw(context)),
      itemBuilder: (context, index) {
        // Add delay for staggered animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20), // slight slide up effect
                child: child,
              ),
            );
          },
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 0.35.sw(context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Top image placeholder
                  Container(
                    height: 0.16.sh(context),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  // Bottom text placeholder
                  Container(
                    height: 0.05.sh(context),
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

//used in discover screen
Widget destinationCard(BuildContext context, Destination destination) {
  return GestureDetector(
    onTap: () {
      Get.toNamed(
        AppRoutes.destinationDetailScreen,
        arguments: {'destination': destination},
      );
    },
    child: Stack(
      children: [
        // ---------- CARD ----------
        Container(
          height: 0.20.sh(context),
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ---------- IMAGE ----------
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: destination.mainImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: destination.mainImageUrl!,
                        width: 0.3.sw(context),
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : Container(
                        width: 0.32.sw(context),
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, size: 40),
                      ),
              ),

              // ---------- INFO ----------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Destination name
                      SizedBox(
                        width: 0.4.sw(context),
                        child: Text(
                          destination.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 0.014.toRes(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.redAccent),
                          SizedBox(width: 0.01.sw(context)),
                          Expanded(
                            child: Text(
                              destination.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 0.01.toRes(context),
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.01.sh(context)),

                      // Short description
                      Text(
                        destination.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 0.01.toRes(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 10,
          left: 120,
          child: // Rating + cost row
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber[700]),
              const SizedBox(width: 2),
              Text(
                destination.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 0.016.toRes(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "💰 ${destination.estimatedCost}",
                style: TextStyle(
                  fontSize: 0.015.toRes(context),
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
        // ---------- SAVED ICON (Top Right Corner of Card) ----------
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              destination.isFavorite.value = !destination.isFavorite.value;
            },
            child: Obx(() => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    destination.isFavorite.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: destination.isFavorite.value
                        ? Colors.red
                        : Colors.grey[700],
                    size: 20,
                  ),
                )),
          ),
        ),
      ],
    ),
  );
}

/// Change password dialog
void showChangePasswordBottomSheet() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Form(
          key: profileController.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Current Password
                Obx(() => TextFormField(
                      controller: profileController.currentPasswordController,
                      obscureText:
                          profileController.isCurrentPasswordHidden.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                              profileController.isCurrentPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                          onPressed: () {
                            profileController.isCurrentPasswordHidden.value =
                                !profileController
                                    .isCurrentPasswordHidden.value;
                          },
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    )),
                const SizedBox(height: 16),

                // New Password
                Obx(() => TextFormField(
                      controller: profileController.newPasswordController,
                      obscureText: profileController.isNewPasswordHidden.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(profileController.isNewPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            profileController.isNewPasswordHidden.value =
                                !profileController.isNewPasswordHidden.value;
                          },
                        ),
                      ),
                      onChanged: (_) {
                        // Trigger confirm password validation live
                        profileController.formKey.currentState?.validate();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),

                // Confirm Password
                Obx(() => TextFormField(
                      controller: profileController.confirmPasswordController,
                      obscureText:
                          profileController.isConfirmPasswordHidden.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                              profileController.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                          onPressed: () {
                            profileController.isConfirmPasswordHidden.value =
                                !profileController
                                    .isConfirmPasswordHidden.value;
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (value !=
                            profileController.newPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 20),

                // Submit Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: profileController.isLoading.value
                            ? null
                            : () async {
                                if (profileController.formKey.currentState!
                                    .validate()) {
                                  await profileController.changePassword();
                                }
                              },
                        child: profileController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Change Password"),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  ).whenComplete(() {
    // Clear all text fields and reset visibility when dialog is closed
    profileController.currentPasswordController.clear();
    profileController.newPasswordController.clear();
    profileController.confirmPasswordController.clear();

    profileController.isCurrentPasswordHidden.value = true;
    profileController.isNewPasswordHidden.value = true;
    profileController.isConfirmPasswordHidden.value = true;
    profileController.isLoading.value = false;
  });
}

void showEditUserInfoBottomSheet(UserModel user) {
  final phoneController = TextEditingController(text: user.phone);
  final emailController = TextEditingController(text: user.email);
  final addressController = TextEditingController(text: user.location);
  final genderController = TextEditingController(text: user.gender);
  final dobController = TextEditingController(text: user.dateOfBirth);

  Get.bottomSheet(
    SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit User Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Phone
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            // Address
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),

            // Gender
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: "Gender"),
            ),

            // Date of Birth
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: "Date of Birth"),
              onTap: () async {
                // Show date picker
                FocusScope.of(Get.context!).unfocus(); // hide keyboard
                DateTime? pickedDate = await showDatePicker(
                  context: Get.context!,
                  initialDate:
                      DateTime.tryParse(dobController.text) ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  dobController.text =
                      pickedDate.toIso8601String().split('T').first;
                }
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await profileController.updateUserInfo(
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim(),
                  location: addressController.text.trim(),
                  gender: genderController.text.trim(),
                  dateOfBirth: dobController.text.trim(),
                );
                Get.back(); // Close bottom sheet
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
