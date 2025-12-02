import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import '../widgets/custom_dialog.dart';

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

  @override
  void dispose() {
    Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
    super.dispose();
  }

  final Map<String, String> _techniqueContent = {
    'Alongamentos guiados': """
**TÉCNICA: Alongamento de Mãos.**
DURAÇÃO: 5 minutos.
BOM PARA: Rigidez matinal.

**COMO FAZER:**
- Sente-se confortavelmente.
- Abra as mãos devagar.
- Feche formando punho suave.
- Repita 10 vezes.
- Descanse.

**ATENÇÃO:** Pare se sentir dor forte.
[Vídeo demonstrativo]
[Lembrete diário]
""",
    'Respiração profunda': """
**TÉCNICA: RESPIRAÇÃO PROFUNDA.**
DURAÇÃO: 5 minutos.
BENEFÍCIO: Reduz tensão e ansiedade.

**COMO FAZER:**
- Sente-se confortavelmente ou deite.
- Coloque uma mão na barriga.
- Inspire pelo nariz contando até 4.
- Sinta a barriga subir (não o peito).
- Expire pela boca contando até 6.
- Repita 10 vezes.

**DICA:** Faça antes de dormir.
""",
    'Respiração 4-7-8': """
**TÉCNICA: RESPIRAÇÃO 4-7-8.**
DURAÇÃO: 3-5 minutos.
BENEFÍCIO: Acalma e melhora o sono.

**COMO FAZER:**
- Inspire pelo nariz: conte até 4.
- Segure o ar: conte até 7.
- Expire pela boca: conte até 8.
- Faça 4 ciclos completos.

**OBS:** Pode dar leve tontura no início - é normal.
""",
    'Suspiro de alívio': """
**TÉCNICA: SUSPIRO DE ALÍVIO.**
DURAÇÃO: 2 minutos.
BENEFÍCIO: Libera tensão rápida.

**COMO FAZER:**
- Inspire profundamente pelo nariz.
- Solte o ar pela boca com um suspiro sonoro.
- Deixe os ombros caírem.
- Repita 5 vezes.

*"Aaaah..." - solte o som!*
""",
    'Relaxamento muscular': """
**TÉCNICA: RELAXAMENTO MUSCULAR**
DURAÇÃO: 10-15 minutos.
BENEFÍCIO: Alivia tensão e dor muscular.

**COMO FAZER:**
- Deite-se confortavelmente.
- Comece pelos pés:
  - Contraia os músculos por 5 segundos.
  - Relaxe completamente por 10 segundos.
- Suba pelo corpo: Panturrilhas - Coxas - Barriga - Mãos e braços - Ombros - Rosto.

**ATENÇÃO:** Não force articulações doloridas.
[Áudio guiado disponível]
""",
    'Toque calmante': """
**TÉCNICA: TOQUE CALMANTE**
DURAÇÃO: 5 minutos.
BENEFÍCIO: Conforto imediato.

**COMO FAZER:**
- Esfregue as mãos até aquecer.
- Coloque as mãos nos locais doloridos.
- Faça movimentos circulares suaves.
- Respire profundamente.
- Imagine o calor aliviando a dor.

**DICA:** Pode usar óleo morno.
""",
  };

  // Função auxiliar para criar a lista de TextSpan a partir do conteúdo em string
  List<TextSpan> _buildTextSpans(String content) {
    final List<TextSpan> spans = [];
    final lines = content.split('\n');

    final baseStyle = TextStyle(color: Colors.white70, fontSize: 16, height: 1.5);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);

    for (final line in lines) {
      if (line.startsWith('**') && line.endsWith('**')) {
        spans.add(TextSpan(text: '${line.substring(2, line.length - 2)}\n', style: boldStyle));
      } else if (line.startsWith('*') && line.endsWith('*')) {
        spans.add(TextSpan(text: '${line.substring(1, line.length - 1)}\n', style: italicStyle));
      } else if (line.startsWith('-')) {
        spans.add(TextSpan(text: '• ${line.substring(1)}\n', style: baseStyle));
      } else if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
      } else if (line.startsWith('[') && line.endsWith(']')) {
        continue; // Ignora as linhas de placeholder para botões
      } else {
        spans.add(TextSpan(text: '$line\n', style: baseStyle));
      }
    }
    return spans;
  }

  void _showTechniqueDialog(String title, String content) {
    final access = Provider.of<AccessibilityService>(context, listen: false);

    showContentDialog(
      context: context,
      title: title,
      initialNarration: "Técnica: $title. ${content.replaceAll('\n', ' ').replaceAll('**', '').replaceAll('*', '')}",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(children: _buildTextSpans(content)),
          ),
          const SizedBox(height: 24),
          if (content.contains('[Vídeo demonstrativo]'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.play_circle_fill, color: Colors.black),
                label: const Text('Ver Vídeo', style: TextStyle(color: Colors.black)),
                onPressed: () => access.speak("Botão para vídeo demonstrativo. Funcionalidade ainda não implementada."),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          if (content.contains('[Áudio guiado disponível]'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.audiotrack, color: Colors.black),
                label: const Text('Ouvir Áudio Guiado', style: TextStyle(color: Colors.black)),
                onPressed: () => access.speak("Botão para áudio guiado. Funcionalidade ainda não implementada."),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          if (content.contains('[Lembrete diário]'))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.calendar_month, color: Colors.black),
                label: const Text('Adicionar Lembrete', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  access.stopSpeaking();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/agenda');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showAlertsDialog() async {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    try {
      final alerts = await _apiService.getAlerts();
      showContentDialog(
        context: context,
        title: '⚠️ Alertas de Segurança',
        initialNarration: "Abrindo alertas de segurança. ${alerts.join(". ")}",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: alerts.map<Widget>((alert) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("● $alert", style: Theme.of(context).textTheme.bodyMedium),
          )).toList(),
        ),
      );
    } catch (e) {
      access.speak("Erro ao carregar alertas.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar alertas: $e')),
      );
    }
  }

  Widget _buildTechniqueButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.fitness_center, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({})),
        label: Text(title, style: TextStyle(color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}), fontSize: 16)),
        onPressed: () => _showTechniqueDialog(title, _techniqueContent[title] ?? 'Conteúdo não encontrado.'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
          Navigator.of(context).pop();
        }),
        title: const Text('Técnicas de Alívio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.amber),
            onPressed: _showAlertsDialog,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Escolha uma técnica para alívio:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildTechniqueButton('Alongamentos guiados'),
              _buildTechniqueButton('Respiração profunda'),
              _buildTechniqueButton('Respiração 4-7-8'),
              _buildTechniqueButton('Suspiro de alívio'),
              _buildTechniqueButton('Relaxamento muscular'),
              _buildTechniqueButton('Toque calmante'),
            ],
          ),
        ),
      ),
    );
  }
}
