import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/pain_entry.dart';

//Classe para o layout de avaliação de dores
class PainScreen extends StatefulWidget {
  const PainScreen({super.key});
  @override
  State<PainScreen> createState() => _PainScreenState();
}

class _PainScreenState extends State<PainScreen> {
  double intensity = 0;
  String location = '';
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<DataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliação da dor'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            const Text('Insira a intensidade da dor (0-10)'),
            Slider(value: intensity, min: 0, max: 10, divisions: 10, label: intensity.toInt().toString(), onChanged: (v)=> setState(()=> intensity = v)),
            TextButton(onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('ÍNDICE DE DORES'),
                content: Column(mainAxisSize: MainAxisSize.min, children: const[
                  Text('0: Sem dor'),
                  Text('1-2: Dor mínima'),
                  Text('3-4: Dor leve'),
                  Text('5-6: Dor moderada'),
                  Text('7-8: Dor intensa'),
                  Text('9-10: Dor insuportável'),
                ]),
                actions: [IconButton(icon: const Icon(Icons.close), onPressed: ()=> Navigator.pop(context))],
              ));
            }, child: const Text('Clique para ver o índice de dores')),
            const SizedBox(height: 12),
            const Text('Aponte o local da sua dor (texto)'),
            TextField(onChanged: (v)=> location = v, decoration: const InputDecoration(labelText: 'Local da dor (ex: joelho direito)')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () async {
                if (auth.user == null) return;
                final now = DateTime.now();
                final entry = PainEntry(userId: auth.user!.id, date: now.toIso8601String(), intensity: intensity.toInt(), location: location);
                await data.addPain(entry);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação salva')));
              }, child: const Text('Salvar'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: ()=> Navigator.pop(context), child: const Text('Voltar'))),
            ])
          ]),
        ),
      ),
    );
  }
}
