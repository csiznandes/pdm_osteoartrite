import 'package:flutter/material.dart';
import '../services/api_service.dart';                      
import 'package:provider/provider.dart';                  
import '../services/accessibility_service.dart';          

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();       //Controlador para capturar o email digitado
  final ApiService _apiService = ApiService();            //Instância do serviço de API
  bool _loading = false;                                  //Indica se a requisição está em andamento

  //Função chamada ao clicar no botão de redefinir senha
  void _resetPassword() async {
    setState(() => _loading = true);                      //Ativa indicador de carregamento

    try {
      //Chama a API passando o email digitado
      final res = await _apiService.resetPassword(_emailController.text);

      //Verifica se a API retornou sucesso
      if (res["message"] == "password_reset") {
        final tempPass = res["temp_password"];            //Senha temporária recebida

        //Mostra senha temporária ao usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Senha temporária: $tempPass")),
        );

        Navigator.pop(context);                           //Volta para a tela anterior
      } else {
        //Erro retornado pela API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${res["error"]}")),
        );
      }

    } catch (e) {
      //Erro inesperado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar pedido: $e")),
      );
    }

    setState(() => _loading = false);                     //Desativa carregamento
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityService>(context, listen: false);

    //Narração automática ao abrir a tela
    access.speak("Tela de redefinição de senha. Informe seu email.");

    return Scaffold(
      appBar: AppBar(title: const Text("Redefinir Senha")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            //Campo de texto para digitar o email cadastrado
            TextField(
              controller: _emailController,
              onTap: () => access.speak("Digite o email cadastrado."),
              decoration: const InputDecoration(
                labelText: "Email cadastrado",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            //Se estiver carregando, mostra spinner
            _loading
                ? const CircularProgressIndicator(color: Colors.white)

                //Se não estiver carregando, mostra botão
                : ElevatedButton(
                    onPressed: _resetPassword,             //Chama função para enviar email
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,       
                      foregroundColor: Colors.black,      
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    ),
                    child: const Text("Enviar email de redefinição"),
                  )
          ],
        ),
      ),
    );
  }
}
