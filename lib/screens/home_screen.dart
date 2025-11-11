import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'pain_screen.dart';
import 'techniques_screen.dart';
import 'education_screen.dart';
import 'agenda_screen.dart';
import 'reports_screen.dart';

//Classe para o layout da home (tela principal)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: ()=> Scaffold.of(context).openDrawer())),
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: () {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Alertas de segurança'),
              content: Column(mainAxisSize: MainAxisSize.min, children: const [
                Text('● Pare se sentir tontura intensa'),
                Text('● Não force se tiver dor'),
                Text('● Consulte seu médico se tiver dúvidas'),
              ]),
              actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Fechar'))],
            ));
          }, icon: const Icon(Icons.warning))
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text('Olá, ${auth.user?.name ?? 'usuário'}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _MenuButton(label: 'Perfil', icon: Icons.person, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                _MenuButton(label: 'Avaliação da dor', icon: Icons.thermostat, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const PainScreen()))),
                _MenuButton(label: 'Técnicas de alívio', icon: Icons.self_improvement, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const TechniquesScreen()))),
                _MenuButton(label: 'Educação', icon: Icons.menu_book, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationScreen()))),
                _MenuButton(label: 'Agenda e lembretes', icon: Icons.event, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen()))),
                _MenuButton(label: 'Relatórios e feedbacks', icon: Icons.bar_chart, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
              ],
            )
          ]),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.icon, required this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.white10),
      onPressed: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 36),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center),
      ]),
    );
  }
}
