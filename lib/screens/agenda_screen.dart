import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/reminder.dart';

//Classe para o layout de agenda
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}
class _AgendaScreenState extends State<AgendaScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda e lembretes')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                setState(()=> _selectedDate = d);
              }, child: Text(_selectedDate==null ? 'Selecionar data' : DateFormat('dd/MM/yyyy').format(_selectedDate!)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                setState(()=> _selectedTime = t);
              }, child: Text(_selectedTime==null ? 'Selecionar horário' : _selectedTime!.format(context)))),
            ]),
            const SizedBox(height: 8),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Descrição')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () async {
              if (_selectedDate == null || auth.user == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione data e usuário.')));
                return;
              }
              final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
              final timeStr = _selectedTime?.format(context) ?? '';
              final reminder = Reminder(userId: auth.user!.id, date: dateStr, time: timeStr, description: _desc.text);
              await Provider.of<DataProvider>(context, listen: false).addReminder(reminder);
              _desc.clear();
              setState(() {
                _selectedDate = null;
                _selectedTime = null;
              });
            },
              child: const Text('Agendar'),
            ),
            const SizedBox(height: 12),
            const Text('Agendamentos:'),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (auth.user != null) await Provider.of<DataProvider>(context, listen: false).loadAll(auth.user!.id!);
                },
                child: ListView.builder(
                    itemCount: data.reminders.length,
                    itemBuilder: (_, i) {
                      final r = data.reminders[i];
                      return ListTile(
                        title: Text(r.description),
                        subtitle: Text('${r.date} ${r.time}'),
                        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                          await Provider.of<DataProvider>(context, listen: false).deleteReminder(r.id!, auth.user!.id!);
                        }),
                      );
                    }
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
