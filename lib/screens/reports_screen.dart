import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/feedback_model.dart';

//Classe para o layout de relatórios e feedbacks
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _fbCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<DataProvider>(context, listen: false).loadAll(auth.user!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<DataProvider>(context);
    // Build monthly averages (simple)
    final map = <String, List<int>>{};
    for (var p in data.pains) {
      final d = DateTime.parse(p.date);
      final key = DateFormat('yyyy-MM').format(d);
      map.putIfAbsent(key, ()=>[]).add(p.intensity);
    }
    final months = map.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i=0;i<months.length;i++){
      final avg = map[months[i]]!.fold<int>(0, (s,e)=>s+e) / map[months[i]]!.length;
      spots.add(FlSpot(i.toDouble(), avg));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios e feedbacks')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            const Text('Gráfico de evolução da dor (média por mês)'),
            const SizedBox(height: 12),
            if (spots.isEmpty)
              const Text('Sem dados de dor para exibir')
            else
              SizedBox(height: 200, child: LineChart(LineChartData(
                minY: 0,
                maxY: 10,
                lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3)],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta){
                    final idx = v.toInt();
                    if (idx>=0 && idx<months.length) return Text(months[idx].substring(5));
                    return const Text('');
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                ),
              ))),
            const SizedBox(height: 12),
            const Text('Feedbacks'),
            TextField(controller: _fbCtrl, decoration: const InputDecoration(labelText: 'Escreva um feedback')),
            Row(children: [
              ElevatedButton(onPressed: () async {
                if (auth.user==null || _fbCtrl.text.isEmpty) return;
                final f = FeedbackModel(userId: auth.user!.id, date: DateTime.now().toIso8601String(), text: _fbCtrl.text);
                await Provider.of<DataProvider>(context, listen: false).addFeedback(f);
                _fbCtrl.clear();
              }, child: const Text('Salvar')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: ()=> Navigator.pop(context), child: const Text('Voltar')),
            ]),
            Expanded(child: ListView.builder(itemCount: data.feedbacks.length, itemBuilder: (_,i){
              final f = data.feedbacks[i];
              return ListTile(title: Text(f.text), subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(f.date))), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                await Provider.of<DataProvider>(context, listen: false).deleteFeedback(f.id!, auth.user!.id!);
              }));
            }))
          ]),
        ),
      ),
    );
  }
}
