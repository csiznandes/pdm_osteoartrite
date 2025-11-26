import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://csiznandes.pythonanywhere.com';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id'));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addPain(int id, int score, String location) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/pain'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'score': score, 'location': location}),
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getPain(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/pain'));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> addAgenda(int id, Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/agenda'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getAgenda(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/agenda'));
    return jsonDecode(res.body);
  }

  Future deleteAgenda(int id, int itemId) async {
    await http.delete(Uri.parse('$baseUrl/user/$id/agenda/$itemId'));
  }

  Future<List<dynamic>> getFeedback(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/feedback'));
    return jsonDecode(res.body);
  }

  Future addFeedback(int id, String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(res.body);
  }

  Future deleteFeedback(int id, int fbId) async {
    await http.delete(Uri.parse('$baseUrl/user/$id/feedback/$fbId'));
  }

  Future<Map<String, dynamic>> getTechniques() async {
    final res = await http.get(Uri.parse('$baseUrl/techniques'));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getEducation() async {
    final res = await http.get(Uri.parse('$baseUrl/education'));
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getAlerts() async {
    final res = await http.get(Uri.parse('$baseUrl/alerts'));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset_password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return jsonDecode(res.body);
  }
}
