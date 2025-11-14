import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';
import 'package:intl/intl.dart';

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
  }

  Future<void> _loadAgenda() async {
    if (UserSession.userId != null) {
      setState(() {
        _agendaFuture = _apiService.getAgenda(UserSession.userId!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
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
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addAgendaItem() async {
    if (_selectedDate == null || _selectedTime == null || _descriptionController.text.isEmpty || UserSession.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha data, hora e descrição.')),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final dateIso = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeIso = _selectedTime!.format(context);
      final payload = {
        'date': dateIso,
        'time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
        'description': _descriptionController.text,
      };

      await _apiService.addAgenda(UserSession.userId!, payload);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar lembrete: $e')),
      );
    } finally {
      setState(() => _isAdding = false);
    }
  }

  void _deleteAgendaItem(int itemId) async {
    if (UserSession.userId == null) return;
    try {
      await _apiService.deleteAgenda(UserSession.userId!, itemId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lembrete excluído.')),
      );
      _loadAgenda();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agenda e Lembretes')),
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
                    onPressed: () => _selectDate(context),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
                  ),
                  SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: Icon(Icons.access_time, color: Colors.white),
                    label: Text(
                      _selectedTime == null ? 'Selecionar Hora' : _selectedTime!.format(context),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _selectTime(context),
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição (Ex: Alongamento de Mãos)',
                      border: OutlineInputBorder(),
                    ),
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
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Nenhum lembrete agendado.', style: TextStyle(color: Colors.white70)),
                ));
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAgendaItem(item['id']),
                      ),
                      leading: Icon(Icons.notifications_active, color: Colors.amber),
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