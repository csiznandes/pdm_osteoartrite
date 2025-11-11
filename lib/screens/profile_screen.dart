import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

//Classe para o layout de perfil
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
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
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Idade'),
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
                  decoration: const InputDecoration(labelText: 'Diagnóstico'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _comorb,
                  decoration: const InputDecoration(labelText: 'Comorbidades (separe por vírgula)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: accessibility,
                  items: ['Padrão', 'Fonte maior', 'Alto contraste', 'Leitura por voz']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => accessibility = v ?? 'Padrão'),
                  decoration: const InputDecoration(labelText: 'Preferências de acessibilidade'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('LGPD (consentimento)'),
                    const Spacer(),
                    Switch(
                      value: lgpd,
                      onChanged: (v) => setState(() => lgpd = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                            id: auth.user!.id,
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

                          await auth.updateProfile(user);
                          setState(() => _loading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                          );
                        },
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Salvar alterações'),
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
