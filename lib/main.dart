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
import 'screens/reset_password_screen.dart';
import 'screens/admin_reports_screen.dart';
import 'services/accessibility_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider( //O aplicativo é envolto em um ChangeNotifierProvider para que o AccessibilityService esteja disponível em toda a árvore de widgets.
      create: (context) => AccessibilityService(),
      child: CuidaDorApp(),
    ),
  );
}

class CuidaDorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccessibilityService>(
      builder: (context, accessService, child) {
        //Lógica de Acessibilidade
        final double fontScale = accessService.fontPref ? 1.2 : 1.0;
        final bool contrast = accessService.contrastPref;
        //Cores Padrão (Tema Escuro Primário)
        final Color normalBackground = Color(0xFF0F1E3A); 
        final Color normalText = Color(0xFFE0E0E0); 
        final Color normalAccent = Color(0xFF4DD0E1); 
        final Color normalCard = Color(0xFF1B2E50); 
        //Cores de Alto Contraste (Foco na legibilidade)
        final Color highContrastBackground = Color(0xFF121212); 
        final Color highContrastText = Color.fromARGB(255, 255, 255, 255); 
        final Color highContrastAccent = Color(0xFF00C2FF); 
        //Seleção Dinâmica das Cores
        final Color primaryTextColor = contrast ? highContrastText : normalText;
        final Color primaryBackgroundColor = contrast ? highContrastBackground : normalBackground;
        final Color accentColor = contrast ? highContrastAccent : normalAccent;
        final Color cardColor = contrast ? Color(0xFF2E2E2E) : normalCard;
        //Definição do Tema
        final theme = ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: primaryBackgroundColor, 
          primaryColor: primaryBackgroundColor, 
          colorScheme: ColorScheme.dark(
            primary: accentColor,
            secondary: accentColor.withOpacity(0.8),
            surface: cardColor,
            background: primaryBackgroundColor,
            onPrimary: primaryBackgroundColor, 
            onSurface: primaryTextColor,
          ),

          fontFamily: 'Roboto', 
          textTheme: TextTheme( //TextTheme ajusta o tamanho da fonte com base em fontScale
            bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16 * fontScale),
            bodyMedium: TextStyle(color: primaryTextColor, fontSize: 14 * fontScale),
            titleLarge: TextStyle(color: primaryTextColor, fontSize: 24 * fontScale, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: primaryTextColor, fontSize: 18 * fontScale, fontWeight: FontWeight.w600),
            labelLarge: TextStyle(color: primaryBackgroundColor, fontSize: 16 * fontScale, fontWeight: FontWeight.bold), 
          ),
          //Estilo para a Barra de Aplicativo (AppBar)
          appBarTheme: AppBarTheme(
            backgroundColor: primaryBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(color: primaryTextColor, fontSize: 20 * fontScale, fontWeight: FontWeight.w500),
            iconTheme: IconThemeData(color: primaryTextColor),
          ),
          //Estilo para Campos de Formulário (InputDecoration)
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: primaryTextColor.withOpacity(0.7), fontSize: 14 * fontScale),
            hintStyle: TextStyle(color: primaryTextColor.withOpacity(0.4)),
            contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            fillColor: cardColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: accentColor, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: cardColor, width: 1.0), 
            ),
          ),
          //Estilo para Botões Elevados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor, 
              foregroundColor: primaryBackgroundColor, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), 
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              elevation: 4,
            ),
          ),
          //Estilo para Cards
          cardTheme: CardThemeData( 
            color: cardColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), 
            ),
          ),
          //Estilo de Ícones
          iconTheme: IconThemeData(
            color: accentColor, 
          ),
          //Estilo para Checkboxes
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return accentColor;
              }
              return primaryTextColor.withOpacity(0.2); 
            }),
            checkColor: MaterialStateProperty.all(contrast ? Colors.black : primaryBackgroundColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          //Estilo para Seleção de Texto
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: accentColor,
            selectionColor: accentColor.withOpacity(0.3),
            selectionHandleColor: accentColor,
          ),
        );
        //Configuração do MaterialApp e Rotas
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
            '/reset-password': (context) => ResetPasswordScreen(),
            '/admin-reports': (context) => AdminReportsScreen(),
          },
        );
      },
    );
  }
}