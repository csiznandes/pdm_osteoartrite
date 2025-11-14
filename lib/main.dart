import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/pain_eval_screen.dart';
import 'screens/techniques_screen.dart';
import 'screens/education_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/reports_screen.dart';

void main() {
  runApp(CuidaDorApp());
}

class CuidaDorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      appBarTheme: AppBarTheme(backgroundColor: Colors.black),
    );

    return MaterialApp(
      title: 'CuidaDor',
      theme: theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/profile': (_) => ProfileScreen(),
        '/pain': (_) => PainEvalScreen(),
        '/techniques': (_) => TechniquesScreen(),
        '/education': (_) => EducationScreen(),
        '/agenda': (_) => AgendaScreen(),
        '/reports': (_) => ReportsScreen(),
      },
    );
  }
}
