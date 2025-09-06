enum PasswordStrength { weak, medium, strong, veryStrong }

PasswordStrength checkPasswordStrength(String password) {
  if (password.length < 6) return PasswordStrength.weak;

  bool hasUpper = password.contains(RegExp(r'[A-Z]'));
  bool hasLower = password.contains(RegExp(r'[a-z]'));
  bool hasDigit = password.contains(RegExp(r'\d'));
  bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int strengthPoints = 0;
  if (hasUpper) strengthPoints++;
  if (hasLower) strengthPoints++;
  if (hasDigit) strengthPoints++;
  if (hasSpecial) strengthPoints++;

  if (strengthPoints == 4) return PasswordStrength.veryStrong;
  if (strengthPoints == 3) return PasswordStrength.strong;
  if (strengthPoints == 2) return PasswordStrength.medium;
  return PasswordStrength.weak;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';

  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) return 'Name is required';
  return null;
}
