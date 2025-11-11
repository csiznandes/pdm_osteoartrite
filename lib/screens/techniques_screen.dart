import 'package:flutter/material.dart';

//Classe para o layout de técnicas de alívio
class TechniquesScreen extends StatelessWidget {
  const TechniquesScreen({super.key});

  void _showTechnique(BuildContext ctx, String title, String content) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(content)),
      actions: [IconButton(icon: const Icon(Icons.close), onPressed: ()=> Navigator.pop(ctx))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final base = {
      'Alongamentos guiados': 'TÉCNICA: Alongamento de Mãos\nDURAÇÃO: 5 minutos\nBOM PARA: Rigidez matinal\nCOMO FAZER:\n1. Sente-se confortavelmente\n2. Abra as mãos devagar\n3. Feche formando punho suave\n4. Repita 10 vezes\n5. Descanse\nATENÇÃO: Pare se sentir dor forte\n[Vídeo demonstrativo]\n[Lembrete diário]',
      'Respiração profunda': 'RESPIRAÇÃO PROFUNDA 5 minutos\n... (conforme texto fornecido)',
      'Respiração 4-7-8': 'RESPIRAÇÃO 4-7-8 3-5 minutos\n... (conforme texto fornecido)',
      'Suspiro de alívio': 'SUSPIRO DE ALÍVIO 2 minutos\n... (conforme texto fornecido)',
      'Relaxamento muscular': 'RELAXAMENTO MUSCULAR 10-15 minutos\n... (conforme texto fornecido)',
      'Toque calmante': 'TOQUE CALMANTE 5 minutos\n... (conforme texto fornecido)',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Técnicas de alívio'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            ElevatedButton(onPressed: ()=> _showTechnique(context, 'Alertas de segurança', '● Pare se sentir tontura intensa\n● Não force se tiver dor\n● Consulte seu médico se tiver dúvidas'), child: const Text('Alertas de segurança')),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: base.keys.map((k)=> ElevatedButton(onPressed: ()=> _showTechnique(context, k, base[k]!), child: Text(k))).toList()),
            const Spacer(),
            OutlinedButton(onPressed: ()=> Navigator.pop(context), child: const Text('Voltar')),
          ]),
        ),
      ),
    );
  }
}
