import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - CuidaDor'),
        actions: [
          IconButton(
            icon: Icon(Icons.warning, color: Colors.amber),
            onPressed: () => _showAlertsDialog(context),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Bem-vindo(a)! Escolha uma opção:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            _buildHomeButton(context, 'Perfil', '/profile', Icons.person),
            _buildHomeButton(context, 'Avaliação da Dor', '/pain', Icons.healing),
            _buildHomeButton(context, 'Técnicas de Alívio', '/techniques', Icons.self_improvement),
            _buildHomeButton(context, 'Educação', '/education', Icons.menu_book),
            _buildHomeButton(context, 'Agenda e Lembretes', '/agenda', Icons.calendar_today),
            _buildHomeButton(context, 'Relatórios e Feedbacks', '/reports', Icons.insert_chart),
            SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color.fromARGB(255, 255, 0, 0)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Sair', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, String text, String route, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: TextStyle(color: Colors.black, fontSize: 16)),
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
  
  void _showAlertsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text('⚠️ Alertas de Segurança', style: TextStyle(color: Colors.amber)),
        content: Text('Alertas: Pare se sentir tontura intensa. Não force se tiver dor. Consulte seu médico se tiver dúvidas.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}