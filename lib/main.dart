import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screens.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

//Classe principal, que rodará o programa, inicializando o banco de dados
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const CuidaDorApp());
}

class CuidaDorApp extends StatelessWidget {
  const CuidaDorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'CuidaDor',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          colorScheme: baseTheme.colorScheme.copyWith(
            primary: Colors.white,
            secondary: Colors.grey,
          ),
          scaffoldBackgroundColor: Colors.black,
          textTheme: baseTheme.textTheme.apply(bodyColor: Colors.white),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
