import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  Widget _item(BuildContext context, String text, String route, {IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.white) : null,
      title: Text(text, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey[900]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset('assets/CuidaDor2.png', fit: BoxFit.cover),
                    ),
                    SizedBox(height: 12),
                    Text('Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
              _item(context, 'Home', '/home', icon: Icons.home),
              _item(context, 'Perfil', '/profile', icon: Icons.person),
              _item(context, 'Avaliação da dor', '/pain', icon: Icons.healing),
              _item(context, 'Técnicas de alívio', '/techniques', icon: Icons.self_improvement),
              _item(context, 'Educação', '/education', icon: Icons.menu_book),
              _item(context, 'Agenda e lembretes', '/agenda', icon: Icons.calendar_today),
              _item(context, 'Relatórios e feedbacks', '/reports', icon: Icons.insert_chart),
              Divider(color: Colors.white24),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.white),
                title: Text('Sair', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
