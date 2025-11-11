import 'package:flutter/material.dart';
import '../models/user.dart';
import '../db/db_helper.dart';

//Classe para provedor de autenticação
class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  final DBHelper _db = DBHelper();

  Future<bool> login(String email, String password) async {
    final u = await _db.getUserByEmailAndPassword(email, password);
    if (u != null) {
      _user = u;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(User user) async {
    try {
      final existing = await _db.getUserByEmail(user.email);
      if (existing != null) {
        return false;
      }

      final id = await _db.insertUser(user);
      user.id = id;
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao registrar: $e');
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_user?.id != null) {
      final u = await _db.getUserById(_user!.id!);
      _user = u;
      notifyListeners();
    }
  }

  Future<void> updateProfile(User user) async {
    await _db.updateUser(user);
    _user = user;
    notifyListeners();
  }
}
