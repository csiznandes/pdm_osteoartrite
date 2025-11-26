import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class TechniquesScreen extends StatefulWidget {
  @override
  _TechniquesScreenState createState() => _TechniquesScreenState();
}

class _TechniquesScreenState extends State<TechniquesScreen> {
  final ApiService _apiService = ApiService();

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Tela de técnicas de relaxamento e controle da dor.");
  });
}
  
  final Map<String, String> _techniqueContent = {
    'Alongamentos guiados': """
TÉCNICA: **Alongamento de Mãos**
DURAÇÃO: 5 minutos
BOM PARA: Rigidez matinal
COMO FAZER:
1. Sente-se confortavelmente
2. Abra as mãos devagar
3. Feche formando punho suave
4. Repita 10 vezes
5. Descanse
ATENÇÃO: Pare se sentir dor forte
[Vídeo demonstrativo]
[Lembrete diário]
""",
    'Respiração profunda': """
TÉCNICA: **RESPIRAÇÃO PROFUNDA**
DURAÇÃO: 5 minutos
BENEFÍCIO: Reduz tensão e ansiedade
COMO FAZER:
1. Sente-se confortavelmente ou deite
2. Coloque uma mão na barriga
3. Inspire pelo nariz contando até 4
4. Sinta a barriga subir (não o peito)
5. Expire pela boca contando até 6
6. Repita 10 vezes
DICA: Faça antes de dormir
""",
    'Respiração 4-7-8': """
TÉCNICA: **RESPIRAÇÃO 4-7-8**
DURAÇÃO: 3-5 minutos
BENEFÍCIO: Acalma e melhora o sono
COMO FAZER:
1. Inspire pelo nariz: conte até 4
2. Segure o ar: conte até 7
3. Expire pela boca: conte até 8
4. Faça 4 ciclos completos
OBS: Pode dar leve tontura no início - é normal
""",
    'Suspiro de alívio': """
TÉCNICA: **SUSPIRO DE ALÍVIO**
DURAÇÃO: 2 minutos
BENEFÍCIO: Libera tensão rápida
COMO FAZER:
1. Inspire profundamente pelo nariz
2. Solte o ar pela boca com um suspiro sonoro
3. Deixe os ombros caírem
4. Repita 5 vezes
"Aaaah..." - solte o som!
""",
    'Relaxamento muscular': """
TÉCNICA: **RELAXAMENTO MUSCULAR**
DURAÇÃO: 10-15 minutos
BENEFÍCIO: Alivia tensão e dor muscular
COMO FAZER:
1. Deite-se confortavelmente
2. Comece pelos pés:
   - Contraia os músculos por 5 segundos
   - Relaxe completamente por 10 segundos
3. Suba pelo corpo: Panturrilhas - Coxas - Barriga - Mãos e braços - Ombros - Rosto
ATENÇÃO: Não force articulações doloridas
[Áudio guiado disponível]
""",
    'Toque calmante': """
TÉCNICA: **TOQUE CALMANTE**
DURAÇÃO: 5 minutos
BENEFÍCIO: Conforto imediato
COMO FAZER:
1. Esfregue as mãos até aquecer
2. Coloque as mãos nos locais doloridos
3. Faça movimentos circulares suaves
4. Respire profundamente
5. Imagine o calor aliviando a dor
DICA: Pode usar óleo morno.
""",
  };

  void _showTechniqueDialog(String title, String content) {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    access.speak("Técnica: $title. ${content.replaceAll("\n", " ")}");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        titlePadding: EdgeInsets.zero,
        title: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text(title, style: TextStyle(color: Colors.white)),
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
            children: [
              Text(content, style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16),
              if (title == 'Alongamentos guiados')
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_month, color: Colors.black),
                  label: Text('Adicionar Lembrete', style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    Provider.of<AccessibilityService>(context, listen: false)
                        .speak("Adicionar lembrete para a técnica $title");
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/agenda');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertsDialog() async {
    try {
      final alerts = await _apiService.getAlerts();
      final access = Provider.of<AccessibilityService>(context, listen: false);
      access.speak("Abrindo alertas de segurança.");
      access.speak("Alertas: " + alerts.join(". "));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text('⚠️ Alertas de Segurança', style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: alerts.map<Widget>((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text("● $alert", style: TextStyle(color: Colors.white70),),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar alertas: $e')),
      );
    }
  }

  Widget _buildTechniqueButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.fitness_center, color: Colors.black),
        label: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
        onPressed: () {
          Provider.of<AccessibilityService>(context, listen: false)
              .speak("Abrindo técnica: $title");
          _showTechniqueDialog(title, _techniqueContent[title] ?? 'Conteúdo não encontrado.');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Técnicas de Alívio'),
        actions: [
          IconButton(
            icon: Icon(Icons.warning, color: Colors.amber),
            onPressed: _showAlertsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Escolha uma técnica para alívio:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildTechniqueButton('Alongamentos guiados'),
            _buildTechniqueButton('Respiração profunda'),
            _buildTechniqueButton('Respiração 4-7-8'),
            _buildTechniqueButton('Suspiro de alívio'),
            _buildTechniqueButton('Relaxamento muscular'),
            _buildTechniqueButton('Toque calmante'),
            SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Voltar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}