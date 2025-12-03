import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    //Garante que a lógica inicial seja executada após a construção do primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData(context);
    });
  }
  //Lógica para carregar dados iniciais (principalmente preferências de acessibilidade).
  void _loadInitialData(BuildContext context) {
    //Obtém o serviço de acessibilidade sem escutar mudanças.
    final accessService = Provider.of<AccessibilityService>(context, listen: false);
    //Carrega as preferências de acessibilidade do usuário armazenadas na API.
    accessService.loadPreferencesFromApi();
    //Acessibilidade: Anuncia a tela inicial para o usuário.
    accessService.speak("Tela inicial. Escolha uma opção no menu.");
  }
  
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
            //Botões de navegação principais
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
                side: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
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
          onPressed: () {
            Provider.of<AccessibilityService>(context, listen: false)
                .speak("Abrindo $text");
            Navigator.pushNamed(context, route);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          ),
        ),
      );
  }

  void _showAlertsDialog(BuildContext context) {

    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Abrindo alertas de segurança.");
    access.speak("Pare se sentir tontura intensa. Não force se tiver dor.");
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