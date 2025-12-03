import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import '../widgets/custom_dialog.dart';
import '../screens/video_screen.dart';

class TechniquesScreen extends StatefulWidget {
  @override
  _TechniquesScreenState createState() => _TechniquesScreenState();
}

class _TechniquesScreenState extends State<TechniquesScreen> {
  final ApiService _apiService = ApiService();
  late AccessibilityService _access;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {  //Executa após a tela ser construída
      _access = Provider.of<AccessibilityService>(context, listen: false);
      _access.speak("Tela de técnicas de relaxamento e controle da dor.");
    });
  }

  @override
  void dispose() {
    _access.stopSpeaking(); //Para a narração ao sair da tela
    super.dispose();
  }
  //Mapa que demonstrará o áudio guiado
  final Map<String, String> _guidedAudio = {
    'Relaxamento muscular': """
  Vamos começar o relaxamento muscular progressivo.
  Deite-se confortavelmente. Feche os olhos.
  Comece pelos pés. Contraia os músculos por cinco segundos.
  Agora relaxe completamente... Respire fundo.
  Siga para as panturrilhas. Contraia por cinco segundos... e solte devagar.
  Continue subindo pelo corpo: coxas... barriga... mãos... braços... ombros... rosto.
  Tome seu tempo e mantenha a respiração lenta.
  """,
  };

  //Mapa contendo o nome de cada técnica e seu conteúdo
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

//Constrói TextSpan para estilizar o conteúdo (negrito, itálico, listas, etc.)
  List<TextSpan> _buildTextSpans(String content) {
    final List<TextSpan> spans = [];
    final lines = content.split('\n');

    final baseStyle = TextStyle(color: Colors.white70, fontSize: 16, height: 1.5);
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white);
    final italicStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);

    for (final line in lines) {
      //Negrito
      if (line.startsWith('**') && line.endsWith('**')) {
        spans.add(TextSpan(text: '${line.substring(2, line.length - 2)}\n', style: boldStyle));

      //Itálico
      } else if (line.startsWith('*') && line.endsWith('*')) {
        spans.add(TextSpan(text: '${line.substring(1, line.length - 1)}\n', style: italicStyle));

      //Listas
      } else if (line.startsWith('-')) {
        spans.add(TextSpan(text: '• ${line.substring(1)}\n', style: baseStyle));

      //Linha vazia acaba pulando linha
      } else if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));

      //Ignora links como [Vídeo demonstrativo]
      } else if (line.startsWith('[') && line.endsWith(']')) {
        continue;

      } else {
        spans.add(TextSpan(text: '$line\n', style: baseStyle));
      }
    }
    return spans;
  }

  //Mostra o diálogo com a técnica selecionada
  void _showTechniqueDialog(String title, String content) {
    final access = Provider.of<AccessibilityService>(context, listen: false);

    showContentDialog(
      context: context,
      title: title,
      initialNarration: "Técnica: $title. ${content.replaceAll('\n', ' ').replaceAll('**', '').replaceAll('*', '')}",

      //Conteúdo visual dentro do diálogo
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(text: TextSpan(children: _buildTextSpans(content))),
          const SizedBox(height: 24),

          //Botão de vídeo (se o texto contiver a tag)
          if (content.contains('[Vídeo demonstrativo]'))
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill, color: Colors.black),
              label: const Text('Ver Vídeo'),
              onPressed: () {
                access.stopSpeaking();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VideoScreen(videoId: "GTgdBsBSfT8"),
                    ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),

          //Botão de áudio (ainda não implementado)
          if (content.contains('[Áudio guiado disponível]'))
            ElevatedButton.icon(
              icon: const Icon(Icons.audiotrack, color: Colors.black),
              label: const Text('Ouvir Áudio Guiado'),
              onPressed: () {
                access.stopSpeaking();
                final audioText = _guidedAudio[title];

                if (audioText != null) {
                  access.speak(audioText);
                } else {
                  access.speak("Áudio guiado não disponível para esta técnica.");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),

          //Botão de lembrete diário
          if (content.contains('[Lembrete diário]'))
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month, color: Colors.black),
              label: const Text('Adicionar Lembrete'),
              onPressed: () {
                access.stopSpeaking();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agenda');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  //Busca alertas de segurança na API
  void _showAlertsDialog() async {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    try {
      final alerts = await _apiService.getAlerts(); //Chamada à API
      showContentDialog(
        context: context,
        title: '⚠️ Alertas de Segurança',
        initialNarration: "Abrindo alertas. ${alerts.join(". ")}",
        content: Column(
          children: alerts
              .map((alert) => Text("● $alert"))
              .toList(),
        ),
      );
    } catch (e) {
      access.speak("Erro ao carregar alertas.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar alertas: $e')),
      );
    }
  }

  //Constrói cada botão de técnica
  Widget _buildTechniqueButton(String title) {
    return ElevatedButton.icon(
      icon: Icon(Icons.fitness_center),
      label: Text(title),
      onPressed: () => _showTechniqueDialog(title, _techniqueContent[title] ?? 'Conteúdo não encontrado.'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnicas de Alívio'),
        leading: BackButton(onPressed: () {
          Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
          Navigator.pop(context);
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.amber),
            onPressed: _showAlertsDialog,                   //Abre os alertas de segurança
          ),
        ],
      ),

      body: WillPopScope(
        //Garante que a narração pare ao voltar
        onWillPop: () async {
          Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
          return true;
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Escolha uma técnica para alívio:'),
              const SizedBox(height: 16),

              //Botões das técnicas
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