import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _kUserIdKey = 'current_user_id';
  static const _kUserRoleKey = 'current_user_role';

  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUserRole;

  String get currentUserId => _currentUserId ?? '';
  String get currentUserName => _currentUserName ?? '';
  String get currentUserEmail => _currentUserEmail ?? '';
  String get currentUserRole => _currentUserRole ?? 'usuario';
  bool get isLoggedIn => _currentUserId != null;
  bool get isAdmin => _currentUserRole == 'admin';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_kUserIdKey);
    _currentUserRole = prefs.getString(_kUserRoleKey);
  }

  Future<void> login(String userId, String name, String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = userId;
    _currentUserName = name;
    _currentUserEmail = email;
    _currentUserRole = role;
    await prefs.setString(_kUserIdKey, userId);
    await prefs.setString(_kUserRoleKey, role);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserRole = null;
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kUserRoleKey);
  }
}
