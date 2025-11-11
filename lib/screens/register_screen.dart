import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

//Classe para o layout de registro de usuários
class RegisterScreen extends StatefulWidget {
  final bool editing;
  const RegisterScreen({super.key, this.editing = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _age = TextEditingController();
  final _sex = TextEditingController();
  final _contact = TextEditingController();
  final _diagnosis = TextEditingController();
  final _comorb = TextEditingController();
  String accessibility = 'Padrão';
  bool lgpd = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (widget.editing && auth.user != null) {
      final u = auth.user!;
      _name.text = u.name;
      _email.text = u.email;
      _pass.text = u.password;
      _age.text = u.age?.toString() ?? '';
      _sex.text = u.sex ?? '';
      _contact.text = u.contact ?? '';
      _diagnosis.text = u.diagnosis ?? '';
      _comorb.text = u.comorbidities ?? '';
      accessibility = u.accessibility ?? 'Padrão';
      lgpd = u.lgpd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? 'Editar Perfil' : 'Cadastro Pessoal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // === CAMPOS BÁSICOS ===
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome completo' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe um e-mail' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe uma senha' : null,
                ),
                const SizedBox(height: 8),

                // === OUTRAS INFORMAÇÕES ===
                TextFormField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sex,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(labelText: 'Contato'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _diagnosis,
                  decoration:
                  const InputDecoration(labelText: 'Registro de diagnóstico'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _comorb,
                  decoration: const InputDecoration(
                      labelText: 'Comorbidades (separe por vírgula)'),
                ),
                const SizedBox(height: 12),

                // === PREFERÊNCIAS DE ACESSIBILIDADE ===
                DropdownButtonFormField<String>(
                  value: accessibility,
                  items: ['Padrão', 'Fonte maior', 'Alto contraste', 'Leitura por voz']
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => accessibility = v ?? 'Padrão'),
                  decoration: const InputDecoration(
                      labelText: 'Preferências de acessibilidade'),
                ),
                const SizedBox(height: 12),

                // === LGPD ===
                Row(
                  children: [
                    const Text('LGPD (consentimento de dados)'),
                    const Spacer(),
                    Switch(
                      value: lgpd,
                      onChanged: (v) => setState(() => lgpd = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // === BOTÕES ===
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _loading = true);

                          final user = User(
                            name: _name.text,
                            email: _email.text,
                            password: _pass.text,
                            age: int.tryParse(_age.text),
                            sex: _sex.text,
                            contact: _contact.text,
                            diagnosis: _diagnosis.text,
                            comorbidities: _comorb.text,
                            accessibility: accessibility,
                            lgpd: lgpd,
                          );

                          bool ok;
                          if (widget.editing && auth.user != null) {
                            user.id = auth.user!.id;
                            await auth.updateProfile(user);
                            ok = true;
                          } else {
                            ok = await auth.register(user);
                          }

                          setState(() => _loading = false);

                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.editing
                                    ? 'Perfil atualizado!'
                                    : 'Cadastro realizado com sucesso!'),
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                                  (_) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Erro ao cadastrar. E-mail já em uso.')),
                            );
                          }
                        },
                        child: _loading
                            ? const CircularProgressIndicator()
                            : Text(widget.editing ? 'Salvar' : 'Cadastrar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
