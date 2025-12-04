import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://csiznandes.pythonanywhere.com'; //URL base do serviço de backend.
  //Realiza o login do usuário.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }
  //Registra um novo usuário.
  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }
  //Obtém informações detalhadas de um usuário pelo ID.
  Future<Map<String, dynamic>> getUser(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id'));
    return jsonDecode(res.body);
  }
  //Atualiza os dados de um usuário (ex: nome, idade, preferências).
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/user/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }
  //Adiciona um novo registro de dor (score e localização).
  Future<Map<String, dynamic>> addPain(int id, int score, String location) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/pain'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'score': score, 'location': location}),
    );
    return jsonDecode(res.body);
  }
  //Obtém o histórico de registros de dor.
  Future<List<dynamic>> getPain(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/pain'));
    return jsonDecode(res.body);
  }
  //Adiciona um novo item (lembrete) na agenda do usuário.
  Future<Map<String, dynamic>> addAgenda(int id, Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/agenda'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return jsonDecode(res.body);
  }
  //Obtém a lista de compromissos da agenda.
  Future<List<dynamic>> getAgenda(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/agenda'));
    return jsonDecode(res.body);
  }
  //Deleta um item específico da agenda.
  Future deleteAgenda(int id, int itemId) async {
    await http.delete(Uri.parse('$baseUrl/user/$id/agenda/$itemId'));
  }
  //Obtém a lista de feedbacks/relatórios enviados pelo usuário.
  Future<List<dynamic>> getFeedback(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$id/feedback'));
    return jsonDecode(res.body);
  }
  //Envia um novo feedback (relatório de progresso/problema).
  Future addFeedback(int id, String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/user/$id/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(res.body);
  }
  //Deleta um feedback específico.
  Future deleteFeedback(int id, int fbId) async {
    await http.delete(Uri.parse('$baseUrl/user/$id/feedback/$fbId'));
  }

  Future<List<dynamic>> getAllUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users'));
    if(res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print('Erro ao buscar todos os usuários: ${res.statusCode}');
      return [];
    }
  }
  //Obtém o conteúdo sobre técnicas de alívio.
  Future<Map<String, dynamic>> getTechniques() async {
    final res = await http.get(Uri.parse('$baseUrl/techniques'));
    return jsonDecode(res.body);
  }
  //Obtém o conteúdo educacional sobre a condição.
  Future<Map<String, dynamic>> getEducation() async {
    final res = await http.get(Uri.parse('$baseUrl/education'));
    return jsonDecode(res.body);
  }
  //Obtém a lista de alertas de segurança.
  Future<List<dynamic>> getAlerts() async {
    final res = await http.get(Uri.parse('$baseUrl/alerts'));
    return jsonDecode(res.body);
  }
  //Solicita a redefinição de senha para um e-mail específico.
  Future<Map<String, dynamic>> resetPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reset_password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return jsonDecode(res.body);
  }

  //Lista todos os usuários (para o administrador)
  Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users')); 
    
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Falha ao carregar usuários: ${res.statusCode}');
    }
  }

}
