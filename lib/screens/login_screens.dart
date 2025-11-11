import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

//Classe para o layout de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('CuidaDor', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'E-mail')),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {
                  // fluxo simples: show dialog to reset (not implemented full email send)
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: const Text('Redefinir senha'),
                    content: const Text('Aqui você implementaria o fluxo de redefinição por e-mail.'),
                    actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('OK'))],
                  ));
                }, child: const Text('Esqueceu a senha?')),
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  }, child: const Text('Cadastrar'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: _loading ? null : () async {
                    setState(() { _loading = true; _error = null; });
                    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
                    setState(() { _loading = false; });
                    if (ok) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    } else {
                      setState(() { _error = 'E-mail ou senha inválidos'; });
                    }
                  }, child: _loading ? const CircularProgressIndicator() : const Text('Entrar'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
