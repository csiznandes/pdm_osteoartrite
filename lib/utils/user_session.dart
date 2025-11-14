// utils/user_session.dart
class UserSession {
  static int? _userId;

  static set userId(int? id) => _userId = id;
  static int? get userId => _userId;

  static void logout() => _userId = null;
}