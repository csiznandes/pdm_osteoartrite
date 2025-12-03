import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

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
    //Inicia o carregamento dos dados de dor e feedback.
    _loadData();

    //Adiciona um callback para executar após o primeiro frame de renderização.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final access = Provider.of<AccessibilityService>(context, listen: false);
      access.speak("Tela de relatórios e feedbacks.");
    });
  }

  //Função responsável por carregar os dados da API.
  void _loadData() {
    //Verifica se o ID do usuário está disponível.
    if (UserSession.userId != null) {
      setState(() {
        //Busca os dados de dor do usuário.
        _painFuture = _apiService.getPain(UserSession.userId!);
        //Busca os feedbacks do usuário.
        _feedbackFuture = _apiService.getFeedback(UserSession.userId!);
      });
    }
  }

  //Função assíncrona para adicionar um novo feedback.
  void _addFeedback() async {
    //Validação: se o campo estiver vazio ou o ID do usuário não existir, retorna.
    if (_feedbackController.text.isEmpty || UserSession.userId == null) return;

    setState(() => _isSendingFeedback = true);

    try {
      //Chama a função da API para enviar o feedback.
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

  //Função assíncrona para deletar um feedback.
  void _deleteFeedback(int fbId) async {
    //Validação: se o ID do usuário não existir, retorna.
    if (UserSession.userId == null) return;
    try {
      //Chama a função da API para deletar o feedback.
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
      appBar: AppBar(title: const Text('Relatórios e Feedbacks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Gráfico de Evolução da Dor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            //Widget que lida com dados assíncronos (Future) para o gráfico.
            FutureBuilder<List<dynamic>>(
              future: _painFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } 
                else if (snapshot.hasError) {
                  return Text('Erro ao carregar dados de dor: ${snapshot.error}');
                } 
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum registro de dor para exibir.', style: TextStyle(color: Colors.white70));
                }

                final painData = snapshot.data!;
                final spots = <FlSpot>[];
                //Loop para converter os dados da API em pontos para o gráfico (FlSpot).
                for (var i = 0; i < painData.length; i++) {
                  final entry = painData[i];
                  final score = (entry['score'] as num).toDouble();
                  //Cria o ponto: X é o índice na lista, Y é a pontuação da dor.
                  spots.add(FlSpot(i.toDouble(), score));
                }

                //Container para definir o tamanho do gráfico.
                return Container(
                  height: 250,
                  padding: const EdgeInsets.only(right: 16, top: 16),
                  //O widget LineChart que desenha o gráfico de linha.
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false), //Esconde linhas de grade.
                      //Configura os títulos dos eixos.
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            //Função que customiza o widget de título do eixo X (mostra a data).
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < painData.length) {
                                //Pega a data e a formata para 'dd/MM'.
                                final date = DateTime.parse(painData[index]['created_at']);
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
                            //Função que mostra o valor inteiro da pontuação da dor.
                            getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      minX: 0,
                      maxX: (painData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 10,
                      //Define as barras (linhas) de dados.
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true, 
                          color: Colors.amber,
                          barWidth: 3,
                          dotData: const FlDotData(show: true), //Mostra os pontos individuais.
                          //Área abaixo da linha (preenchimento).
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

            const Divider(color: Colors.white24, height: 32),

            //Título da seção de envio de feedback.
            const Text('Envie seu Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            //Campo de texto para o feedback.
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Seu comentário ou sugestão',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              //Função de acessibilidade ao tocar no campo.
              onTap: () => Provider.of<AccessibilityService>(context, listen: false)
                .speak("Campo para escrever comentários e sugestões"),
            ),
            const SizedBox(height: 16),
            //Alterna entre o indicador de carregamento e o botão de envio.
            _isSendingFeedback
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
                    onPressed: () {
                      //Função de acessibilidade ao pressionar o botão.
                      Provider.of<AccessibilityService>(context, listen: false)
                        .speak("Enviando feedback");
                      //Chama a função para adicionar o feedback.
                      _addFeedback();
                    },
                    child: const Text('Enviar Feedback'),
                  ),

            const Divider(color: Colors.white24, height: 32),

            //Título da seção de feedbacks registrados.
            const Text('Feedbacks Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            //Widget que lida com dados assíncronos (Future) para a lista de feedbacks.
            FutureBuilder<List<dynamic>>(
              future: _feedbackFuture,
              builder: (context, snapshot) {
                //Mostra indicador de carregamento.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                } 
                //Mostra erro.
                else if (snapshot.hasError) {
                  return Text('Erro ao carregar feedbacks: ${snapshot.error}');
                } 
                //Mostra mensagem de lista vazia.
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum feedback registrado.', style: TextStyle(color: Colors.white70));
                }

                final feedbacks = snapshot.data!;
                //Constrói a lista de feedbacks.
                return ListView.builder(
                  shrinkWrap: true,
                  //Impede que o ListView tente rolar (já está dentro de um SingleChildScrollView).
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = feedbacks[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        //Exibe o texto do feedback.
                        title: Text(fb['text']),
                        //Exibe a data de criação (substring para pegar apenas a data).
                        subtitle: Text('Em: ${fb['created_at'].substring(0, 10)}', style: const TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Botão para deletar o feedback.
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                //Função de acessibilidade.
                                Provider.of<AccessibilityService>(context, listen: false)
                                    .speak("Excluir feedback");
                                //Chama a função para deletar o feedback usando seu ID.
                                _deleteFeedback(fb['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}