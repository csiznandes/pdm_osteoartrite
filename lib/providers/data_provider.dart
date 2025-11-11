import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/pain_entry.dart';
import '../models/reminder.dart';
import '../models/feedback_model.dart';

//Classe para provedor de dados
class DataProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<PainEntry> pains = [];
  List<Reminder> reminders = [];
  List<FeedbackModel> feedbacks = [];

  Future<void> loadAll(int userId) async {
    pains = await _db.getPainEntriesForUser(userId);
    reminders = await _db.getRemindersForUser(userId);
    feedbacks = await _db.getFeedbacksForUser(userId);
    notifyListeners();
  }

  Future<void> addPain(PainEntry p) async {
    await _db.insertPain(p);
    await loadAll(p.userId!);
  }

  Future<void> addReminder(Reminder r) async {
    await _db.insertReminder(r);
    await loadAll(r.userId!);
  }

  Future<void> deleteReminder(int id, int userId) async {
    await _db.deleteReminder(id);
    await loadAll(userId);
  }

  Future<void> addFeedback(FeedbackModel f) async {
    await _db.insertFeedback(f);
    await loadAll(f.userId!);
  }

  Future<void> deleteFeedback(int id, int userId) async {
    await _db.deleteFeedback(id);
    await loadAll(userId);
  }
}
