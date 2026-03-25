import 'package:shared_preferences/shared_preferences.dart';

import './db_connector.dart';
import '../models/info_models.dart';
import '../utils/password_encryptation.dart';

class Authorizer {
  static const String _emailKey = 'user_email';

  // Save user email to SharedPreferences
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  // Get stored user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // Clear stored user email (for logout)
  static Future<void> clearUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }

  // Check if user is registered (has stored email and exists in DB)
  static Future<bool> isUserRegistered() async {
    final email = await getUserEmail();
    if (email == null) return false;

    var db = await DBConnector.connect();
    User? user = await DBConnector.getUser(db, email);
    await DBConnector.close(db);
    return user != null;
  }

  // Is Registered
  static Future<bool> isRegistered(String email) async {
    var db = await DBConnector.connect();
    User? user = await DBConnector.getUser(db, email);
    await DBConnector.close(db);
    return user != null;
  }

  // Is Authorized (can be used in Login)
  static Future<bool> isAuthorized(String email, String password) async {
    var db = await DBConnector.connect();
    User? user = await DBConnector.getUser(db, email);
    await DBConnector.close(db);
    return user != null && decryptPassword(user.password) == password;
  }
}
