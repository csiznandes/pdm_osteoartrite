import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  //Recebe os dados básicos do usuário que o administrador clicou
  const UserDetailsScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _painFuture;
  late Future<List<dynamic>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  //Chama os endpoints da API para buscar os dados específicos do usuário
  void _loadUserDetails() {
    setState(() {
      _painFuture = _apiService.getPain(widget.userId); 
      _feedbackFuture = _apiService.getFeedback(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.userName} (${widget.userId})'),
            Text(
              widget.userEmail,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Seção de Registros de Dor
            const Text('Histórico de Dor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            FutureBuilder<List<dynamic>>(
              future: _painFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar dor: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum registro de dor encontrado.');
                }

                final painEntries = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: painEntries.length,
                  itemBuilder: (context, index) {
                    final entry = painEntries[index];
                    final date = DateTime.parse(entry['created_at']);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(entry['score'].toString()),
                        backgroundColor: _getPainColor(entry['score']),
                      ),
                      title: Text('Nível de Dor: ${entry['score']}'),
                      subtitle: Text(
                        'Local: ${entry['location']}\nData: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            //Seção de Feedbacks
            const Text('Feedbacks Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            FutureBuilder<List<dynamic>>(
              future: _feedbackFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar feedbacks: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum feedback registrado.');
                }

                final feedbacks = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = feedbacks[index];
                    final date = DateTime.parse(fb['created_at']);
                    
                    //Exibição do feedback
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(fb['text']), 
                        subtitle: Text(
                          'Em: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                          style: const TextStyle(color: Colors.white54)
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  //Função auxiliar para definir a cor do nível de dor
  Color _getPainColor(int score) {
    if (score <= 3) return Colors.green;
    if (score <= 6) return Colors.amber;
    return Colors.red;
  }
}
