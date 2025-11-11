import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/pain_entry.dart';
import '../models/reminder.dart';
import '../models/feedback_model.dart';

//Classe destinada para funções do banco de dados
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cuidador.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        age INTEGER,
        sex TEXT,
        contact TEXT,
        diagnosis TEXT,
        comorbidities TEXT,
        accessibility TEXT,
        lgpd INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE pain_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        intensity INTEGER,
        location TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        time TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE feedbacks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        text TEXT
      )
    ''');
  }

  //USER CRUD
  Future<int> insertUser(User user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user.toMap());
  }

  //Verifica se já existe um usuário com o mesmo e-mail
  Future<User?> getUserByEmail(String email) async {
    final dbClient = await db;
    final res = await dbClient.query('users', where: 'email = ?', whereArgs: [email]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }

//Lista todos os usuários (somente para debugar)
  Future<List<User>> getAllUsers() async {
    final dbClient = await db;
    final res = await dbClient.query('users');
    return res.map((e) => User.fromMap(e)).toList();
  }

//Deleta um usuário específico (somente para testes)
  Future<int> deleteUserByEmail(String email) async {
    final dbClient = await db;
    return await dbClient.delete('users', where: 'email = ?', whereArgs: [email]);
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final dbClient = await db;
    final res = await dbClient.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }
  //Captação do id do usuário
  Future<User?> getUserById(int id) async {
    final dbClient = await db;
    final res = await dbClient.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return User.fromMap(res.first);
    return null;
  }
  //Atualização das informações do usuário
  Future<int> updateUser(User user) async {
    final dbClient = await db;
    return await dbClient.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  //Dores
  Future<int> insertPain(PainEntry p) async {
    final dbClient = await db;
    return await dbClient.insert('pain_entries', p.toMap());
  }

  Future<List<PainEntry>> getPainEntriesForUser(int userId) async {
    final dbClient = await db;
    final res = await dbClient.query('pain_entries', where: 'userId = ?', whereArgs: [userId], orderBy: 'date ASC');
    return res.map((e) => PainEntry.fromMap(e)).toList();
  }

  //Reminders
  Future<int> insertReminder(Reminder r) async {
    final dbClient = await db;
    return await dbClient.insert('reminders', r.toMap());
  }

  Future<List<Reminder>> getRemindersForUser(int userId) async {
    final dbClient = await db;
    final res = await dbClient.query('reminders', where: 'userId = ?', whereArgs: [userId], orderBy: 'date ASC, time ASC');
    return res.map((e) => Reminder.fromMap(e)).toList();
  }

  Future<int> deleteReminder(int id) async {
    final dbClient = await db;
    return await dbClient.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  //Feedbacks
  Future<int> insertFeedback(FeedbackModel f) async {
    final dbClient = await db;
    return await dbClient.insert('feedbacks', f.toMap());
  }

  Future<List<FeedbackModel>> getFeedbacksForUser(int userId) async {
    final dbClient = await db;
    final res = await dbClient.query('feedbacks', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return res.map((e) => FeedbackModel.fromMap(e)).toList();
  }

  Future<int> deleteFeedback(int id) async {
    final dbClient = await db;
    return await dbClient.delete('feedbacks', where: 'id = ?', whereArgs: [id]);
  }
}
