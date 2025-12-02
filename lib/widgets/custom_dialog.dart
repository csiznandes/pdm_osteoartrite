import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

/// Exibe um diálogo de conteúdo padronizado que interrompe a narração de acessibilidade ao ser fechado.
///
/// [context]: O BuildContext da tela que está chamando.
/// [title]: O título a ser exibido na barra de aplicativos do diálogo.
/// [content]: O widget principal a ser exibido como conteúdo do diálogo.
/// [initialNarration]: O texto a ser falado pela acessibilidade quando o diálogo é aberto.
void showContentDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  String? initialNarration,
}) {
  final access = Provider.of<AccessibilityService>(context, listen: false);

  // Inicia a narração, se houver uma.
  if (initialNarration != null) {
    access.speak(initialNarration);
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      // Usa WillPopScope para interceptar o botão "voltar" do sistema.
      return WillPopScope(
        onWillPop: () async {
          // Interrompe a narração quando o diálogo é dispensado.
          access.stopSpeaking();
          return true; // Permite que o diálogo seja fechado.
        },
        child: AlertDialog(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          titlePadding: EdgeInsets.zero,
          title: AppBar(
            backgroundColor: Theme.of(dialogContext).appBarTheme.backgroundColor,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text(title, style: Theme.of(dialogContext).appBarTheme.titleTextStyle),
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(dialogContext).textTheme.bodyLarge?.color),
                // Interrompe a narração quando o botão 'X' é pressionado.
                onPressed: () {
                  access.stopSpeaking();
                  Navigator.pop(dialogContext);
                },
              )
            ],
          ),
          content: SingleChildScrollView(
            child: content,
          ),
        ),
      );
    },
  );
}
