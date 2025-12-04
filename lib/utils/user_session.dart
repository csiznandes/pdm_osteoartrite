// utils/user_session.dart
class UserSession {
  static int? _userId;
  static bool _isAdmin = false;

  static set userId(int? id) => _userId = id;
  static int? get userId => _userId;

  static set isAdmin(bool status) => _isAdmin = status;
  static bool get isAdmin => _isAdmin;

  static void logout() {
    _userId = null;
    _isAdmin = false;
  }
}