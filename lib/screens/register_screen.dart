import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Instância do serviço de API.
  final ApiService _apiService = ApiService();
  //Chave global usada para validar o formulário.
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
    //Anuncia o título da tela após a renderização inicial (para acessibilidade).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakScreenTitle();
    });
  }

  //Função dedicada a anunciar o título da tela.
  void _speakScreenTitle() {
    final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
    accessibilityService.speak('Tela de Cadastro. Preencha seus dados.'); 
  }

  //Função assíncrona para processar o cadastro.
  void _submit() async {
    //Validação do consentimento da LGPD.
    if (!_lgpdConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('É necessário dar o consentimento para a LGPD.')),
      );
      return;
    }
    
    //Validação dos campos do formulário (usando a _formKey).
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
      //O widget Form encapsula todos os campos para permitir validação em lote.
      body: Form(
        key: _formKey, //Liga a chave global ao formulário.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //Campos de Autenticação
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email (Obrigatório)'),
                keyboardType: TextInputType.emailAddress,
                //Lógica de validação do email (regex).
                validator: (value) {
                final emailRegex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
                if (value == null || value.isEmpty) return 'Digite um email';
                if (!emailRegex.hasMatch(value)) return 'Email inválido';
                return null;
                },
                //Anuncia o campo para acessibilidade ao tocar.
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Email. Campo Obrigatório.'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha (Obrigatório)'),
                obscureText: true, //Esconde o texto digitado (senha).
                //Lógica de validação da senha (mínimo de 6 caracteres).
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite uma senha';
                  if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                  return null;
                },
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Senha. Campo Obrigatório.'),
              ),
              Divider(color: Colors.white24, height: 32),

              //Dados Pessoais
              Text('Dados Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                //Lógica de validação da idade (deve ser um número válido).
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Digite sua idade';
                  final number = int.tryParse(value);
                  if (number == null || number < 1 || number > 120) return 'Idade inválida';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _sex,
                decoration: InputDecoration(labelText: 'Sexo'),
                items: ['Masculino', 'Feminino', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _sex = v),
                onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Sexo. Escolha entre: masculino, feminino e outro.'),
              ),
              //Campo de telefone com validação (8 a 11 números).
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contato/Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final phoneRegex = RegExp(r'^\d{8,11}$');
                  if (value == null || value.isEmpty) return 'Digite um telefone';
                  if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                    return 'Telefone inválido (use 8 a 11 números)';
                  }
                  return null;
                },
              ),
              Divider(color: Colors.white24, height: 32),

              //Dados Clínicos
              Text('Dados Clínicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(controller: _diagnosisController, decoration: InputDecoration(labelText: 'Diagnóstico (Ex: Osteoartrite)')),
              TextFormField(controller: _comorbiditiesController, decoration: InputDecoration(labelText: 'Comorbidades')),
              Divider(color: Colors.white24, height: 32),

              //Preferências de Acessibilidade
              Text('Preferências de Acessibilidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Fonte (Tamanho/Estilo)'),
                value: _fontPref,
                onChanged: (v) => setState(() => _fontPref = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: Text('Contraste Elevado'),
                value: _contrastPref,
                onChanged: (v) => setState(() => _contrastPref = v!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: Text('Leitura por Voz'),
                value: _voiceReadPref,
                //Ao mudar o estado, anuncia a mudança (para acessibilidade).
                onChanged: (v) {
                  setState(() => _voiceReadPref = v!);
                  Provider.of<AccessibilityService>(context, listen: false).speak(
                    v! ? 'Leitura por voz marcada.' : 'Leitura por voz desmarcada.',
                  );
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Divider(color: Colors.white24, height: 32),

              Text('Consentimento LGPD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Concordo com a coleta e uso de dados conforme a LGPD.'),
                value: _lgpdConsent,
                //O estado do consentimento é atualizado.
                onChanged: (v) {
                  setState(() => _lgpdConsent = v!);
                  Provider.of<AccessibilityService>(context, listen: false).speak(
                    v! ? 'Consentimento LGPD marcado.' : 'Consentimento LGPD desmarcado.',
                  );
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 32),

              //Alterna entre o indicador de carregamento ou os botões de ação.
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.white))
                  : Row(
                      children: [
                        //Botão "Voltar".
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Voltar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<AccessibilityService>(context, listen: false).speak('Enviando cadastro');
                              _submit(); //Chama a função de submissão do formulário.
                            },
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