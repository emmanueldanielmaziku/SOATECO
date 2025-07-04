import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserAdmissionNumber = 'user_admission_number';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';

  // Save user authentication data
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String role,
    required String admissionNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserRole, role);
    await prefs.setString(_keyUserAdmissionNumber, admissionNumber);
    await prefs.setBool(_keyIsLoggedIn, true);

    if (additionalData != null) {
      // Convert additional data to string for storage
      final dataString = additionalData.toString();
      await prefs.setString(_keyUserData, dataString);
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // Get user admission number
  static Future<String?> getUserAdmissionNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAdmissionNumber);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get all user data
  static Future<Map<String, dynamic>?> getAllUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString(_keyUserId);
    final email = prefs.getString(_keyUserEmail);
    final role = prefs.getString(_keyUserRole);
    final admissionNumber = prefs.getString(_keyUserAdmissionNumber);
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (userId == null ||
        email == null ||
        role == null ||
        admissionNumber == null) {
      return null;
    }

    return {
      'userId': userId,
      'email': email,
      'role': role,
      'admissionNumber': admissionNumber,
      'isLoggedIn': isLoggedIn,
    };
  }

  // Update user role (for when student is promoted to leader)
  static Future<void> updateUserRole(String newRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, newRole);
  }

  // Clear all user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserAdmissionNumber);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserData);
  }

  // Save specific user data field
  static Future<void> saveUserField(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Get specific user data field
  static Future<String?> getUserField(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
