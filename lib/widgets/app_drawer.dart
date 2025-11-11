import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/pain_screen.dart';
import '../screens/techniques_screen.dart';
import '../screens/education_screen.dart';
import '../screens/agenda_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/login_screens.dart';

//Classe para o layout de menu
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(title: Text(auth.user?.name ?? 'Usuário'), subtitle: Text(auth.user?.email ?? '')),
            const Divider(),
            ListTile(leading: const Icon(Icons.person), title: const Text('Perfil'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            ListTile(leading: const Icon(Icons.heart_broken), title: const Text('Avaliação da dor'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const PainScreen()))),
            ListTile(leading: const Icon(Icons.self_improvement), title: const Text('Técnicas de alívio'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const TechniquesScreen()))),
            ListTile(leading: const Icon(Icons.menu_book), title: const Text('Educação'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationScreen()))),
            ListTile(leading: const Icon(Icons.event), title: const Text('Agenda e lembretes'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen()))),
            ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Relatórios e feedbacks'), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            const Spacer(),
            ListTile(leading: const Icon(Icons.exit_to_app), title: const Text('Sair'), onTap: (){
              auth.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const LoginScreen()), (_) => false);
            }),
          ],
        ),
      ),
    );
  }
}
