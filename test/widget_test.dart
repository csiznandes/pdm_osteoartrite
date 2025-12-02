// Este é um teste de widget básico do Flutter.
//
// Para interagir com um widget em seu teste, use o utilitário WidgetTester
// no pacote flutter_test. Por exemplo, você pode enviar gestos de toque e rolagem.
// Você também pode usar o WidgetTester para encontrar widgets filhos na árvore de widgets,
// ler texto e verificar se os valores das propriedades do widget estão corretos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_osteoartrite/main.dart';
import 'package:pdm_osteoartrite/screens/login_screen.dart';

void main() {
  testWidgets('Tela de login deve ter campos de email, senha e um botão de login', (WidgetTester tester) async {
    // Constrói o nosso aplicativo e aciona um frame.
    await tester.pumpWidget(CuidaDorApp());

    // Verifica se a LoginScreen é exibida.
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verifica se a tela possui um campo para o email.
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

    // Verifica se a tela possui um campo para a senha.
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

    // Verifica se a tela possui um botão de "Entrar".
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });
}
