import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  final _feedbackController = TextEditingController();
  late Future<List<dynamic>> _painFuture;
  late Future<List<dynamic>> _feedbackFuture;
  bool _isSendingFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (UserSession.userId != null) {
      setState(() {
        _painFuture = _apiService.getPain(UserSession.userId!);
        _feedbackFuture = _apiService.getFeedback(UserSession.userId!);
      });
    }
  }

  void _addFeedback() async {
    if (_feedbackController.text.isEmpty || UserSession.userId == null) return;

    setState(() => _isSendingFeedback = true);

    try {
      await _apiService.addFeedback(UserSession.userId!, _feedbackController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback enviado!')),
      );
      _feedbackController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar feedback: $e')),
      );
    } finally {
      setState(() => _isSendingFeedback = false);
    }
  }

  void _deleteFeedback(int fbId) async {
    if (UserSession.userId == null) return;
    try {
      await _apiService.deleteFeedback(UserSession.userId!, fbId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback excluído.')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatórios e Feedbacks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Gráfico de Evolução da Dor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _painFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar dados de dor: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum registro de dor para exibir.', style: TextStyle(color: Colors.white70));
                }

                final painData = snapshot.data!;
                final spots = <FlSpot>[];
                for (var i = 0; i < painData.length; i++) {
                  final entry = painData[i];
                  final score = (entry['score'] as num).toDouble();
                  spots.add(FlSpot(i.toDouble(), score));
                }

                return Container(
                  height: 250,
                  padding: const EdgeInsets.only(right: 16, top: 16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < painData.length) {
                                final date = DateTime.parse(painData[index]['created_at']);
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(DateFormat('dd/MM').format(date), style: TextStyle(color: Colors.white70, fontSize: 10)),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      minX: 0,
                      maxX: (painData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 10,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.amber,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            Divider(color: Colors.white24, height: 32),

            Text('Envie seu Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Seu comentário ou sugestão',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _isSendingFeedback
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
                    onPressed: _addFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Enviar Feedback'),
                  ),
            
            Divider(color: Colors.white24, height: 32),

            Text('Feedbacks Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _feedbackFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar feedbacks: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum feedback registrado.', style: TextStyle(color: Colors.white70));
                }

                final feedbacks = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = feedbacks[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(fb['text']),
                        subtitle: Text('Em: ${fb['created_at'].substring(0, 10)}', style: TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //FAZER A LÓGICA DE EDITAR AQUI (SE QUISERMOS)
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFeedback(fb['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}