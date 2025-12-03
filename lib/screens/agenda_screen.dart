import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _agendaFuture;
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadAgenda();
    //Acessibilidade: Anuncia a tela após o primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final access = Provider.of<AccessibilityService>(context, listen: false);
      access.speak("Tela de Agenda. Adicione lembretes de exercícios e visualize seus compromissos.");
    });
  }
  //Função para carregar a lista de lembretes do usuário na API.
  Future<void> _loadAgenda() async {
    if (UserSession.userId != null) {
      setState(() {
        _agendaFuture = _apiService.getAgenda(UserSession.userId!);
      });
    }
  }
  //Abre o seletor de data e atualiza o estado.
  Future<void> _selectDate(BuildContext context) async {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Selecionar data");

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.grey[900]!,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Colors.black,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      access.speak("Data selecionada: ${DateFormat('dd/MM/yyyy').format(picked)}");
    }
  }
  //Abre o seletor de hora e atualiza o estado.
  Future<void> _selectTime(BuildContext context) async {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Selecionar horário");

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Colors.grey[900]!,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Colors.black,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
      access.speak("Horário selecionado: ${picked.hour}:${picked.minute.toString().padLeft(2, '0')}");
    }
  }
  //Envia o novo lembrete para a API.
  void _addAgendaItem() async {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    //Validação: verifica se todos os campos estão preenchidos.
    if (_selectedDate == null || _selectedTime == null || _descriptionController.text.isEmpty || UserSession.userId == null) {
      access.speak("Preencha data, hora e descrição.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha data, hora e descrição.')),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final dateIso = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      final payload = {
        'date': dateIso,
        'time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
        'description': _descriptionController.text,
      };

      await _apiService.addAgenda(UserSession.userId!, payload);

      access.speak("Lembrete adicionado com sucesso.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lembrete adicionado!')),
      );

      _descriptionController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });

      _loadAgenda();

    } catch (e) {
      access.speak("Erro ao adicionar lembrete.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar lembrete: $e')),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }
  //Envia a requisição para deletar um item específico da agenda.
  void _deleteAgendaItem(int itemId) async {
    final access = Provider.of<AccessibilityService>(context, listen: false);

    try {
      await _apiService.deleteAgenda(UserSession.userId!, itemId);

      access.speak("Lembrete excluído.");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lembrete excluído.')),
      );

      _loadAgenda();
    } catch (e) {
      access.speak("Erro ao excluir lembrete.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda e Lembretes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            access.stopSpeaking();
            Navigator.pop(context);
          },
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Novo Lembrete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  OutlinedButton.icon(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    label: Text(
                      _selectedDate == null ? 'Selecionar Data' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      access.speak("Campo de data");
                      _selectDate(context);
                    },
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
                  ),

                  SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: Icon(Icons.access_time, color: Colors.white),
                    label: Text(
                      _selectedTime == null ? 'Selecionar Hora' : _selectedTime!.format(context),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      access.speak("Campo de hora");
                      _selectTime(context);
                    },
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição (Ex: Alongamento de Mãos)',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => access.speak("Digite a descrição do lembrete"),
                  ),

                  SizedBox(height: 16),

                  _isAdding
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : ElevatedButton(
                          onPressed: _addAgendaItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Adicionar à Agenda'),
                        ),

                  Divider(color: Colors.white24, height: 32),
                  Text('Meus Lembretes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          FutureBuilder<List<dynamic>>(
            future: _agendaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.white)));
              } else if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text('Erro ao carregar lembretes: ${snapshot.error}')));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                access.speak("Nenhum lembrete agendado.");
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Nenhum lembrete agendado.', style: TextStyle(color: Colors.white70)),
                  ),
                );
              }

              final items = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];

                    return ListTile(
                      title: Text(item['description'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Data: ${item['date']} | Hora: ${item['time']?.substring(0, 5)}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      leading: Icon(Icons.notifications_active, color: Colors.amber),

                      onTap: () {
                        access.speak(
                          "Lembrete: ${item['description']}. "
                          "Data ${item['date']} às ${item['time']?.substring(0,5)}"
                        );
                      },

                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          access.speak("Excluir lembrete: ${item['description']}");
                          _deleteAgendaItem(item['id']);
                        },
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
