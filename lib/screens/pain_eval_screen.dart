// screens/pain_eval_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';
import '../widgets/body_map.dart';

class PainEvalScreen extends StatefulWidget {
  @override
  _PainEvalScreenState createState() => _PainEvalScreenState();
}

class _PainEvalScreenState extends State<PainEvalScreen> {
  final ApiService _apiService = ApiService();
  double _painScore = 5.0;
  final _locationController = TextEditingController();
  bool _isSaving = false;

  Color get _painColor {
    if (_painScore <= 2) return Colors.green;
    if (_painScore <= 4) return Colors.lime;
    if (_painScore <= 6) return Colors.yellow;
    if (_painScore <= 8) return Colors.orange;
    return Colors.red;
  }

  void _showPainIndexDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        titlePadding: EdgeInsets.zero,
        title: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text('Índice de Dores', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildIndexItem('0', 'Sem dor', Colors.green),
              _buildIndexItem('1-2', 'Dor Mínima', Colors.lime),
              _buildIndexItem('3-4', 'Dor Leve', Colors.yellow),
              _buildIndexItem('5-6', 'Dor Moderada', Colors.orange),
              _buildIndexItem('7-8', 'Dor Intensa', Colors.redAccent),
              _buildIndexItem('9-10', 'Dor Insuportável', Colors.red),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIndexItem(String score, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(score, textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16),
          Text(description, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _savePain() async {
    if (UserSession.userId == null) return;
    setState(() => _isSaving = true);

    try {
      final res = await _apiService.addPain(
        UserSession.userId!,
        _painScore.toInt(),
        _locationController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avaliação de dor salva! ID: ${res['id']}')),
      );
      setState(() {
        _painScore = 5.0;
        _locationController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar avaliação: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avaliação da Dor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Qual é o seu nível de dor atual?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Nível de Dor: ${_painScore.toInt()}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _painColor)),
                  Slider(
                    value: _painScore,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _painScore.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _painScore = value;
                      });
                    },
                    activeColor: _painColor,
                    inactiveColor: Colors.white30,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            OutlinedButton.icon(
              icon: Icon(Icons.info_outline, color: Colors.white),
              label: Text('Ver Índice de Dores', style: TextStyle(color: Colors.white)),
              onPressed: () => _showPainIndexDialog(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 32),

            Text('Onde você está sentindo dor?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            //Placeholder/simulação do mapa corporal - usar uma imagem/SVG com detecção de toque seria o ideal
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Selecione/Clique no corpo ou descreva a localização:', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Container(
                    height: 350,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: BodyMap(
                      onAreaSelected: (area) {
                        setState(() {
                          _locationController.text = area;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Área selecionada: $area')),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Localização da Dor (Ex: Joelho direito, Mão)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            _isSaving
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Voltar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _savePain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}