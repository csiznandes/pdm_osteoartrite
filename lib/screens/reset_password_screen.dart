import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _loading = false;

  void _resetPassword() async {
    setState(() => _loading = true);

    try {
      final res = await _apiService.resetPassword(_emailController.text);

      if (res["message"] == "password_reset") {
        final tempPass = res["temp_password"];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Senha temporária: $tempPass")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${res["error"]}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar pedido: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Tela de redefinição de senha. Informe seu email.");

    return Scaffold(
      appBar: AppBar(title: Text("Redefinir Senha")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              onTap: () => access.speak("Digite o email cadastrado."),
              decoration: InputDecoration(
                labelText: "Email cadastrado",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    ),
                    child: Text("Enviar email de redefinição"),
                  )
          ],
        ),
      ),
    );
  }
}
