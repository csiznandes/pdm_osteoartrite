import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
//Exibe um diálogo modal com título e conteúdo, integrado com o serviço de acessibilidade.
void showContentDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  String? initialNarration,
}) {
  final access = Provider.of<AccessibilityService>(context, listen: false);
  //Garante que qualquer narração anterior seja interrompida antes de abrir o novo diálogo.
  access.stopSpeaking();
  
  if (initialNarration != null) {
    access.speak(initialNarration);
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return WillPopScope(
        onWillPop: () async {
          access.stopSpeaking();
          return true;
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
