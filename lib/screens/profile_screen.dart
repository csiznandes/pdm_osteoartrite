import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

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

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakScreenTitle();
    });
  }

  void _speakScreenTitle() {
    final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
    accessibilityService.speak('Tela de Perfil. Meus dados.'); 
  }

  Future<void> _loadProfile() async {
    if (UserSession.userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await _apiService.getUser(UserSession.userId!);
      final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _contactController.text = data['contact'] ?? '';
        _diagnosisController.text = data['diagnosis'] ?? '';
        _comorbiditiesController.text = data['comorbidities'] ?? '';
        _sex = data['sex'];
        _lgpdConsent = data['lgpd_consent'] ?? false;
        
        final access = data['accessibility'] as Map<String, dynamic>? ?? {};
        accessibilityService.setPreferences(
          font: access['font'] ?? false,
          contrast: access['contrast'] ?? false,
          voiceRead: access['voice_read'] ?? false,
        );
        
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perfil: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate() && UserSession.userId != null) {
      setState(() => _isSaving = true);

      final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);

      final payload = {
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text),
        'sex': _sex,
        'contact': _contactController.text,
        'diagnosis': _diagnosisController.text,
        'comorbidities': _comorbiditiesController.text,
        'accessibility': {
          'font': accessibilityService.fontPref,
          'contrast': accessibilityService.contrastPref,
          'voice_read': accessibilityService.voiceReadPref,
        },
        'lgpd_consent': _lgpdConsent,
      };

      try {
        final res = await _apiService.updateUser(UserSession.userId!, payload);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Perfil atualizado!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meu Perfil')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Dados Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _nameController, 
                      decoration: InputDecoration(labelText: 'Nome'),
                      onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Nome'),
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(labelText: 'Idade'),
                      keyboardType: TextInputType.number,
                      onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Idade'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _sex,
                      decoration: InputDecoration(labelText: 'Sexo'),
                      items: ['Masculino', 'Feminino', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _sex = v),
                      onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Sexo. Escolha entre masculino, feminino ou outro'),
                    ),
                    TextFormField(controller: _contactController, decoration: InputDecoration(labelText: 'Contato/Telefone'), onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Contato ou Telefone'),),
                    Divider(color: Colors.white24, height: 32),

                    Text('Dados Clínicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextFormField(controller: _diagnosisController, decoration: InputDecoration(labelText: 'Diagnóstico (Ex: Osteoartrite)'), onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Diagnóstico'),),
                    TextFormField(controller: _comorbiditiesController, decoration: InputDecoration(labelText: 'Comorbidades'), onTap: () => Provider.of<AccessibilityService>(context, listen: false).speak('Comorbidades'),),
                    Divider(color: Colors.white24, height: 32),

                    Text('Preferências de Acessibilidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    Consumer<AccessibilityService>(
                      builder: (context, accessService, child) {
                        return Column(
                          children: [
                            CheckboxListTile(
                              title: Text('Fonte (Tamanho/Estilo)'),
                              value: accessService.fontPref,
                              onChanged: (v) {
                                accessService.toggleFontPref(v!);
                              },
                            ),
                            
                            CheckboxListTile(
                              title: Text('Contraste Elevado'),
                              value: accessService.contrastPref,
                              onChanged: (v) => accessService.toggleContrastPref(v!),
                            ),
                            
                            CheckboxListTile(
                              title: Text('Leitura por Voz'),
                              value: accessService.voiceReadPref,
                              onChanged: (v) => accessService.toggleVoiceReadPref(v!),
                            ),

                            CheckboxListTile(
                              title: Text('Concordo com a coleta e uso de dados conforme a LGPD.'),
                              value: _lgpdConsent,
                              onChanged: (v) => setState(() => _lgpdConsent = v!),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 32),

                    _isSaving
                        ? Center(child: CircularProgressIndicator(color: Colors.white))
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
                                    Navigator.pop(context);
                                  },
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
                                    Provider.of<AccessibilityService>(context, listen: false).speak('Atualizando perfil');
                                    _updateProfile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text('Atualizar'),
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