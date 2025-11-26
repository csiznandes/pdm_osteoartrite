import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _comorbiditiesController = TextEditingController();
  String? _sex;
  bool _lgpdConsent = false;
  bool _fontPref = false;
  bool _contrastPref = false;
  bool _voiceReadPref = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakScreenTitle();
    });
  }

  void _speakScreenTitle() {
    final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
    accessibilityService.speak('Tela de Cadastro. Preencha seus dados.'); 
  }

  void _submit() async {
    if (!_lgpdConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('É necessário dar o consentimento para a LGPD.')),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final payload = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text),
        'sex': _sex,
        'contact': _contactController.text,
        'diagnosis': _diagnosisController.text,
        'comorbidities': _comorbiditiesController.text,
        'accessibility': {
          'font': _fontPref,
          'contrast': _contrastPref,
          'voice_read': _voiceReadPref,
        },
        'lgpd_consent': _lgpdConsent,
      };

      try {
        final res = await _apiService.register(payload);
        if (res['message'] == 'Registro efetuado') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no cadastro: ${res['error']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro Pessoal')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email (Obrigatório)'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Email. Campo Obrigatório.'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha (Obrigatório)'),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Senha. Campo Obrigatório.'),
              ),
              Divider(color: Colors.white24, height: 32),

              Text('Dados Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _sex,
                decoration: InputDecoration(labelText: 'Sexo'),
                items: ['Masculino', 'Feminino', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _sex = v),
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Sexo. Escolha entre: masculino, feminino e outro.'),
              ),
              TextFormField(controller: _contactController, decoration: InputDecoration(labelText: 'Contato/Telefone')),
              Divider(color: Colors.white24, height: 32),

              Text('Dados Clínicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _diagnosisController, decoration: InputDecoration(labelText: 'Diagnóstico (Ex: Osteoartrite)')),
              TextFormField(controller: _comorbiditiesController, decoration: InputDecoration(labelText: 'Comorbidades')),
              Divider(color: Colors.white24, height: 32),

              Text('Preferências de Acessibilidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Fonte (Tamanho/Estilo)'),
                value: _fontPref,
                onChanged: (v) => setState(() => _fontPref = v!),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text('Contraste Elevado'),
                value: _contrastPref,
                onChanged: (v) => setState(() => _contrastPref = v!),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              CheckboxListTile(
                title: Text('Leitura por Voz'),
                value: _voiceReadPref,
                onChanged: (v) {
                  setState(() => _voiceReadPref = v!);
                  Provider.of<AccessibilityService>(context, listen: false).speak(
                    v! ? 'Leitura por voz marcada.' : 'Leitura por voz desmarcada.',
                  );
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              Divider(color: Colors.white24, height: 32),

              Text('Consentimento LGPD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Concordo com a coleta e uso de dados conforme a LGPD.'),
                value: _lgpdConsent,
                onChanged: (v) {
                  setState(() => _lgpdConsent = v!);
                  Provider.of<AccessibilityService>(context, listen: false).speak(
                    v! ? 'Consentimento LGPD marcado.' : 'Consentimento LGPD desmarcado.',
                  );
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ),
              SizedBox(height: 32),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Voltar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<AccessibilityService>(context, listen: false).speak('Enviando cadastro');
                              _submit();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Cadastrar'),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}