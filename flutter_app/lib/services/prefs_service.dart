import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kUserEmail = 'userEmail';
  static const _kUserName = 'userName';
  static const _kToken = 'authToken';

  static Future<void> setLogin(String email, String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kIsLoggedIn, true);
    await p.setString(_kUserEmail, email);
    await p.setString(_kUserName, name);
  }

  static Future<void> clearLogin() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kIsLoggedIn);
    await p.remove(_kUserEmail);
    await p.remove(_kUserName);
    await p.remove(_kToken);
  }

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsLoggedIn) ?? false;
  }

  static Future<String?> getUserEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUserEmail);
  }

  static Future<void> setToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  static Future<String?> getUserName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUserName);
  }
}
