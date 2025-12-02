import 'package:flutter/material.dart';
import '../services/api_service.dart'; 
import '../utils/user_session.dart'; 
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final access = Provider.of<AccessibilityService>(context, listen: false);
        access.speak("Tela de Login.");
      });
    });

    try {
      final res = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (res['message'] == 'ok') {
        UserSession.userId = res['user_id'];
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${res['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ou validação: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Tela de Login. Aplicativo CuidaDor");
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset('assets/corpo_icon.jpg', fit: BoxFit.cover),
              ),
              SizedBox(height: 24),
              Text(
                'CuidaDor',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 48),

              TextField(
                onTap: () => access.speak("Insira seu email."),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                onTap: () => access.speak("Insira sua senha."),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reset-password');
                  },
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ),
              SizedBox(height: 24),

              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Cadastrar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Entrar'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     Provider.of<AccessibilityService>(context, listen: false)
                    //         .speak("Tela de login. Digite seu email e sua senha para entrar.");
                    //   },
                    //   icon: Icon(Icons.volume_up),
                    //   label: Text("Ativar leitura por voz"),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.white,
                    //     foregroundColor: Colors.black,
                    //     padding: EdgeInsets.symmetric(vertical: 14),
                    //   ),
                    // ),
            ],
          ),
        ),
      ),
    );
  }
}