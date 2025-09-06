import 'package:frontend/constants/app_strings.dart';

class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicPath; // path or URL
  final String? coverPicPath; // path or URL
  final String? bio;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? dateOfBirth;
  final String? gender;
  final String? location;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePicPath,
    this.coverPicPath,
    this.bio,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.dateOfBirth,
    this.gender,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePicPath: json['profile_pic']?.toString(),
      coverPicPath: json['cover_pic']?.toString(),
      bio: json['bio']?.toString(),
      isEmailVerified: json['is_email_verified'] == true,
      isPhoneVerified: json['is_phone_verified'] == true,
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      location: json['location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      if (profilePicPath != null) 'profile_pic': profilePicPath,
      if (coverPicPath != null) 'cover_pic': coverPicPath,
      if (bio != null) 'bio': bio,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (location != null) 'location': location,
    };
  }

  /// Returns full URL for profile pic if available
  String? get profilePicUrl {
    if (profilePicPath == null || profilePicPath!.isEmpty) return null;
    if (profilePicPath!.startsWith('http')) return profilePicPath;
    return StringAssets.mediaUrl + profilePicPath!;
  }

  /// Returns full URL for cover pic if available
  String? get coverPicUrl {
    if (coverPicPath == null || coverPicPath!.isEmpty) return null;
    if (coverPicPath!.startsWith('http')) return coverPicPath;
    return StringAssets.mediaUrl + coverPicPath!;
  }
}
