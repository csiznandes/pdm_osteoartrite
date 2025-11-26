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
import 'services/accessibility_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
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
        final double fontScale = accessService.fontPref ? 1.2 : 1.0;
    
        final Color primaryTextColor = accessService.contrastPref ? Colors.black : Colors.white;
        final Color primaryBackgroundColor = accessService.contrastPref ? Colors.white : Colors.black;
        final Color accentColor = accessService.contrastPref ? Colors.red.shade700 : Colors.blueGrey;
        
        final theme = ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: primaryBackgroundColor, 
          primaryColor: primaryBackgroundColor, 
          
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16 * fontScale),
            bodyMedium: TextStyle(color: primaryTextColor, fontSize: 14 * fontScale),
            titleMedium: TextStyle(color: primaryTextColor, fontSize: 18 * fontScale, fontWeight: FontWeight.bold),
            labelLarge: TextStyle(color: primaryBackgroundColor),
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: primaryBackgroundColor,
            titleTextStyle: TextStyle(color: primaryTextColor, fontSize: 20 * fontScale),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: primaryTextColor.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryTextColor.withOpacity(0.5))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTextColor,
              foregroundColor: primaryBackgroundColor,
            ),
          ),
          
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return primaryTextColor; 
              }
              return Colors.white30; 
            }),
            checkColor: MaterialStateProperty.all(primaryBackgroundColor),
          ),
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
      },
    );
  }
}