import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  final _feedbackController = TextEditingController();
  late Future<List<dynamic>> _painFuture;
  late Future<List<dynamic>> _feedbackFuture;
  bool _isSendingFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (UserSession.userId != null) {
      setState(() {
        _painFuture = _apiService.getPain(UserSession.userId!);
        _feedbackFuture = _apiService.getFeedback(UserSession.userId!);
      });
    }
  }

  void _addFeedback() async {
    if (_feedbackController.text.isEmpty || UserSession.userId == null) return;

    setState(() => _isSendingFeedback = true);

    try {
      await _apiService.addFeedback(UserSession.userId!, _feedbackController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback enviado!')),
      );
      _feedbackController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar feedback: $e')),
      );
    } finally {
      setState(() => _isSendingFeedback = false);
    }
  }

  void _deleteFeedback(int fbId) async {
    if (UserSession.userId == null) return;
    try {
      await _apiService.deleteFeedback(UserSession.userId!, fbId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback excluído.')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatórios e Feedbacks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Gráfico de Evolução da Dor (Mensal)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _painFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar dados de dor: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum registro de dor para exibir.', style: TextStyle(color: Colors.white70));
                }

                final data = snapshot.data!;
                final latestEntries = data.length > 5 ? data.sublist(data.length - 5) : data; 
                
                return Container(
                  height: 200,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Gráfico Simulado\nÚltimas 5 notas de dor (Score/Data):\n${latestEntries.map((e) => '${e['score']} em ${e['created_at'].substring(5, 10)}').join(', ')}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
            
            Divider(color: Colors.white24, height: 32),

            Text('Envie seu Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Seu comentário ou sugestão',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _isSendingFeedback
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
                    onPressed: _addFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Enviar Feedback'),
                  ),
            
            Divider(color: Colors.white24, height: 32),

            Text('Feedbacks Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _feedbackFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar feedbacks: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum feedback registrado.', style: TextStyle(color: Colors.white70));
                }

                final feedbacks = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = feedbacks[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(fb['text']),
                        subtitle: Text('Em: ${fb['created_at'].substring(0, 10)}', style: TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //FAZER A LÓGICA DE EDITAR AQUI (SE QUISERMOS)
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFeedback(fb['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}