import 'package:flutter/material.dart';

//Classe para o layout de educação
class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  void _show(BuildContext ctx, String title, String content) => showDialog(context: ctx, builder: (_) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(child: Text(content)),
    actions: [IconButton(icon: const Icon(Icons.close), onPressed: ()=> Navigator.pop(ctx))],
  ));

  @override
  Widget build(BuildContext context) {
    final Map<String,String> items = {
      'O que é Osteoartrite': 'ENTENDENDO SUA CONDIÇÃO\nA osteoartrite (ou artrose) é o desgaste natural da cartilagem...',
      'Sintomas e sinais': 'RECONHECENDO OS SINAIS\n... (conforme seu texto)',
      'Tratamento e autocuidados': 'OPÇÕES DE TRATAMENTO\n... (conforme seu texto)',
      'Alimentação saudável': 'COMENDO PARA ALIVIAR\n... (conforme seu texto)',
      'Saúde e bem-estar': 'CUIDANDO DA MENTE\n... (conforme seu texto)',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Educação sobre Osteoartrite'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Wrap(spacing: 8, runSpacing: 8, children: items.keys.map((k)=> ElevatedButton(onPressed: ()=> _show(context, k, items[k]!), child: Text(k))).toList()),
            const Spacer(),
            OutlinedButton(onPressed: ()=> Navigator.pop(context), child: const Text('Voltar')),
          ]),
        ),
      ),
    );
  }
}
