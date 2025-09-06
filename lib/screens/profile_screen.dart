// profile_screen.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bindings/controller_ids.dart';
import 'package:frontend/controllers.dart/global_controller.dart';
import 'package:frontend/controllers.dart/profile_controller.dart';
import 'package:frontend/utils/extensions.dart';
import 'package:frontend/widgets/common_widgets.dart';
import 'package:get/get.dart';

import '../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileController =
      Get.find<ProfileController>(tag: ControllerIds.profile);

  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  void _logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      onConfirm: () async {
        Get.back();
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        await profileController.logoutUser();
        if (Get.isDialogOpen ?? false) Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await profileController.fetchProfile();
        },
        child: Obx(() {
          final user = profileController.currentUser.value;

          if (user == null) {
            return const Center(child: Text("No user logged in"));
          }

          return ListView(
            children: [
              _buildCoverProfileSection(context, user),
              SizedBox(height: 0.04.sh(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(user.fullName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              if (user.bio != null && user.bio!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(user.bio!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ),
                ),
              if (user.bio != null && user.bio!.isNotEmpty)
                const SizedBox(height: 16),
              Obx(() => Column(
                    children: [
                      ProfileMenuItem(
                        label: "User Information",
                        icon: Icons.info,
                        trailingWidget: Icon(
                          profileController.isUserInfoExpanded.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                        onTap: () {
                          profileController.isUserInfoExpanded.value =
                              !profileController.isUserInfoExpanded.value;
                        },
                      ),
                      if (profileController.isUserInfoExpanded.value)
                        _buildUserInfoSection(user),
                    ],
                  )),
              ProfileMenuItem(label: "Diaries", icon: Icons.book, onTap: () {}),
              ProfileMenuItem(
                  label: "Change Password",
                  icon: Icons.lock,
                  onTap: () => showChangePasswordBottomSheet()),
              const Divider(height: 1),
              ProfileMenuItem(
                  label: "Logout", icon: Icons.logout, onTap: _logout),
            ],
          );
        }),
      ),
    );
  }
}

// Cover + Profile
Widget _buildCoverProfileSection(BuildContext context, UserModel user) {
  final profileController =
      Get.find<ProfileController>(tag: ControllerIds.profile);

  final globalController =
      Get.find<GlobalController>(tag: ControllerIds.global);

  return SizedBox(
    height: 0.3.sh(context),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover
        Obx(() {
          final ImageProvider? imageProvider =
              profileController.tempCoverPic.value != null
                  ? FileImage(File(profileController.tempCoverPic.value!))
                  : (user.coverPicUrl != null
                      ? CachedNetworkImageProvider(user.coverPicUrl!)
                      : null);

          return Container(
            height: 0.25.sh(context),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green,
              image: imageProvider != null
                  ? DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileController.isUploadingCoverPic.value
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value:
                              profileController.coverUploadProgress.value / 100,
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                        Text(
                          '${profileController.coverUploadProgress.value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          );
        }),

        // Cover edit button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () async {
              if (!profileController.isUploadingCoverPic.value) {
                final pickedFile =
                    await globalController.pickImage(isProfilePic: false);
                if (pickedFile != null) {
                  profileController.tempCoverPic.value = pickedFile.path;
                  await profileController.updateUserInfo(
                      coverPicPath: pickedFile.path);
                }
              }
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white70,
              child: Icon(Icons.edit, size: 20, color: Colors.black87),
            ),
          ),
        ),

        // Profile Pic
        Positioned(
          top: 0.15.sh(context),
          left: 0.34.sw(context),
          child: Obx(() {
            final ImageProvider? imageProvider =
                profileController.tempProfilePic.value != null
                    ? FileImage(File(profileController.tempProfilePic.value!))
                    : (user.profilePicUrl != null
                        ? CachedNetworkImageProvider(user.profilePicUrl!)
                        : null);

            return Stack(
              alignment: Alignment.center,
              children: [
                // Profile picture with border
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black87,
                    backgroundImage: imageProvider,
                  ),
                ),

                // Uploading indicator
                if (profileController.isUploadingProfilePic.value)
                  CircularProgressIndicator(
                    value: profileController.profileUploadProgress.value / 100,
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                if (profileController.isUploadingProfilePic.value)
                  Positioned(
                    child: Text(
                      '${profileController.profileUploadProgress.value.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Edit button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      if (!profileController.isUploadingProfilePic.value) {
                        final pickedFile = await globalController.pickImage(
                            isProfilePic: true);
                        if (pickedFile != null) {
                          profileController.tempProfilePic.value =
                              pickedFile.path;
                          await profileController.updateUserInfo(
                              profilePicPath: pickedFile.path);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    ),
  );
}

// Menu
class ProfileMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  const ProfileMenuItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[300],
      leading: Icon(icon, color: Colors.black87),
      title: Text(label),
      trailing: trailingWidget ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// User info
Widget _buildUserInfoSection(UserModel user) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.phone.isNotEmpty)
              _infoRow(Icons.phone, "Phone", user.phone),
            if (user.location != null && user.location!.isNotEmpty)
              _infoRow(Icons.location_on, "Address", user.location!),
            if (user.gender != null && user.gender!.isNotEmpty)
              _infoRow(Icons.person, "Gender", user.gender!),
            if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty)
              _infoRow(Icons.cake, "Date of Birth", user.dateOfBirth!),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              showEditUserInfoBottomSheet(user);
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.edit, size: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _infoRow(IconData icon, String label, String value,
    {bool verified = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$label: $value",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (verified)
          const Icon(
            Icons.verified,
            color: Colors.blue,
            size: 18,
          ),
      ],
    ),
  );
}
