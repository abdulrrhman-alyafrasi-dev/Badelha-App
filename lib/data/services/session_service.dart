import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 🔐 Session & Token Storage Service (Laravel Sanctum & Secure Storage)
class SessionService {
  static const String _keyToken = 'auth_access_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyRole = 'auth_user_role';
  static const String _keyTokenType = 'auth_token_type';
  static const String _keyLoggedInAt = 'auth_logged_in_at';

  static const _secureStorage = FlutterSecureStorage();
  static const _uuid = Uuid();

  /// Generates Sanctum Token format for offline mock / test
  static String generateSanctumToken(String userId) {
    final cleanId = userId.replaceAll(RegExp(r'[^0-9]'), '');
    final idPrefix = cleanId.isNotEmpty ? cleanId.substring(0, cleanId.length > 4 ? 4 : cleanId.length) : '1';
    final randomHex = '${_uuid.v4().replaceAll('-', '')}${_uuid.v4().replaceAll('-', '')}'.substring(0, 48);
    return '$idPrefix|$randomHex';
  }

  /// Save persistent session securely
  static Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
  }) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyTokenType, 'Bearer');
    await prefs.setString(_keyLoggedInAt, DateTime.now().toIso8601String());
  }

  /// Retrieve the current stored Sanctum access token
  static Future<String?> getAccessToken() async {
    try {
      final secureToken = await _secureStorage.read(key: _keyToken);
      if (secureToken != null && secureToken.isNotEmpty) {
        return secureToken;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Retrieve the current logged-in user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Retrieve the user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  /// Check whether a valid session exists
  static Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    final userId = await getUserId();
    return token != null && token.trim().isNotEmpty && userId != null && userId.trim().isNotEmpty;
  }

  /// Revoke and delete local token and session data (Logout)
  static Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyLoggedInAt);
  }
}
