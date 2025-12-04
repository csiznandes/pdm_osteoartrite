import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'user_details_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  @override
  _AdminReportsScreenState createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _apiService.getUsers(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios de Usuários')),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum usuário comum encontrado.', style: TextStyle(color: Colors.white70))); 
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name'] ?? user['email']),
                subtitle: Text('Email: ${user['email']} | ID: ${user['id']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsScreen(
                        userId: user['id'],
                        userName: user['name'] ?? user['email'],
                        userEmail: user['email'],
                      ),
                    ),
                  );
                },
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
              );
            },
          );
        },
      ),
    );
  }
}
