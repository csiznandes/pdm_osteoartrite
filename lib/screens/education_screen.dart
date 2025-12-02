import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import '../widgets/custom_dialog.dart';

class EducationScreen extends StatelessWidget {
  final Map<String, String> _educationContent = {
    'O que é Osteoartrite': '''
**ENTENDENDO SUA CONDIÇÃO**
O que acontece? A osteoartrite (ou artrose) é o desgaste natural da cartilagem que protege suas articulações. Com o tempo, os ossos ficam mais próximos e causam dor e rigidez.

*Pense assim: É como o desgaste de um pneu de carro - com o uso ao longo dos anos, a proteção vai diminuindo.*

**IMPORTANTE SABER:**
- É muito comum após os 60 anos
- NÃO é culpa sua
- Tem tratamento e controle
- Você pode viver bem com osteoartrite

**Articulações mais afetadas:**
- Joelhos
- Mãos e dedos
- Quadril
- Coluna
- Pés
''',
    'Sintomas e Sinais': '''
**RECONHECENDO OS SINAIS**

**Sintomas principais:**
✓ Dor nas articulações (piora com movimento)
✓ Rigidez pela manhã (melhora em 30 min)
✓ Inchaço leve nas juntas
✓ Estalos ao movimentar
✓ Dificuldade para realizar tarefas simples
✓ Sensação de "travamento"

**Padrão comum:**
- Manhã: mais rígido
- Tarde: melhora com movimento suave
- Noite: pode doer após atividades

*A dor varia: Alguns dias melhor, outros pior - é normal!*

**QUANDO PROCURAR AJUDA URGENTE:**
- Dor muito forte e súbita
- Inchaço grande e vermelhidão
- Febre junto com dor
- Impossibilidade de mover a articulação

**POR QUE ACONTECE?**

**Causas principais:**
- Idade: desgaste natural ao longo da vida
- Uso repetitivo: trabalhos que sobrecarregam
- Lesões anteriores: fraturas, torções
- Sobrepeso: pressão extra nas articulações
- Genética: pode ser de família
- Postura inadequada

**FATORES QUE VOCÊ PODE CONTROLAR:**
Peso corporal
Atividade física regular
Postura no dia a dia
Proteção das articulações
Alimentação saudável
''',
    'Tratamento e Autocuidados': '''
**OPÇÕES DE TRATAMENTO**
Objetivo: Reduzir dor e manter movimento

A) **MEDICAMENTOS:**
- Analgésicos
- Anti-inflamatórios (com orientação médica)
- Pomadas e géis
- Suplementos.

B) **PRÁTICAS INTEGRATIVAS (PICs):** ✨ *Este app foca nestas práticas!*
- Exercícios adaptados
- Termoterapia
- Acupuntura/Acupressão
- Yoga e Tai Chi
- Massagem terapêutica
- Fitoterapia

C) **FISIOTERAPIA:**
- Fortalecimento muscular
- Melhora da mobilidade
- Técnicas de proteção articular

D) **MUDANÇAS NO ESTILO DE VIDA:**
- Perda de peso (se necessário)
- Alimentação anti-inflamatória
- Exercícios regulares
- Adaptações no dia a dia

E) **TRATAMENTOS AVANÇADOS:**
- Infiltrações (injeções)
- Viscossuplementação
- Cirurgia (casos específicos)

**ABORDAGEM INTEGRADA:** O melhor resultado vem da COMBINAÇÃO de tratamentos, não apenas um!
''',
    'Alimentação Saudável': '''
**COMENDO PARA ALIVIAR**

**Alimentos AMIGOS (anti-inflamatórios):**
🐟 Peixes (salmão, sardinha) - ômega 3
🫒 Azeite de oliva extra virgem
🥬 Vegetais verde-escuros
🍓 Frutas vermelhas
🧄 Alho e cebola
🫚 Gengibre e cúrcuma
🌰 Castanhas e nozes
🍊 Frutas cítricas (vitamina C)

**Alimentos a EVITAR ou REDUZIR:**
❌ Açúcar em excesso
❌ Frituras
❌ Carnes processadas
❌ Bebidas alcoólicas em excesso
❌ Sal em excesso

**HIDRATAÇÃO:** Beba 6-8 copos de água por dia. *A cartilagem precisa de água!*

**Chás recomendados:**
- Chá verde
- Gengibre
- Cúrcuma
- Cavalinha

*Sempre consulte seu médico antes de mudanças grandes na dieta.*
''',
    'Saúde e Bem-estar': '''
**ADAPTAÇÕES PRÁTICAS**

**Na cozinha:**
- Use utensílios com cabos grossos
- Abridores automáticos
- Banqueta.

**No banheiro:**
- Barras de apoio
- Tapete antiderrapante
- Banco para sentar no banho.

**Calçados:**
- Prefira solado antiderrapante
- Salto baixo (2-3 cm)
- Amortecimento.

**Movimentação:**
- Use bengala se necessário
- Levante-se devagar
- Evite ficar muito tempo na mesma posição.

**Proteção articular:**
- Carregue peso perto do corpo
- Use as duas mãos para tarefas pesadas.

**CUIDANDO DA MENTE**
É normal sentir: Frustração, Medo, Tristeza, Ansiedade. **VOCÊ NÃO ESTÁ SOZINHO!**

**Estratégias de enfrentamento:**
- Foque no que VOCÊ PODE fazer
- Celebre pequenas vitórias
- Mantenha hobbies
- Peça ajuda.

**Busque ajuda se sentir:**
- Tristeza constante
- Perda de interesse
- Isolamento social.
*Psicólogo pode ajudar muito!*

**QUALIDADE DE VIDA**

**Princípios:**
- MOVIMENTO é remédio
- EQUILÍBRIO
- ATITUDE positiva
- APOIO social
- APRENDIZADO.

Lembre-se: *"Osteoartrite é parte de você, mas NÃO define quem você é!"*
''',
  };

  // Função auxiliar para criar a lista de TextSpan a partir do conteúdo em string
  List<TextSpan> _buildTextSpans(String content, BuildContext context) {
    final List<TextSpan> spans = [];
    final lines = content.split('\n');

    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16);
    final boldStyle = baseStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 18);
    final italicStyle = baseStyle?.copyWith(fontStyle: FontStyle.italic);

    for (final line in lines) {
      if (line.startsWith('**') && line.endsWith('**')) {
        spans.add(TextSpan(text: '${line.substring(2, line.length - 2)}\n\n', style: boldStyle));
      } else if (line.startsWith('*') && line.endsWith('*')) {
        spans.add(TextSpan(text: '${line.substring(1, line.length - 1)}\n\n', style: italicStyle));
      } else if (line.startsWith('-') || line.startsWith('✓') || line.startsWith('✅') || line.startsWith('❌') || line.startsWith('🐟') || line.startsWith('🫒') || line.startsWith('🥬') || line.startsWith('🍓') || line.startsWith('🧄') || line.startsWith('🫚') || line.startsWith('🌰') || line.startsWith('🍊')) {
        final marker = line.substring(0, 1);
        final text = line.substring(1).trim();
        spans.add(TextSpan(text: '$marker $text\n', style: baseStyle));
      } else if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
      } else {
        spans.add(TextSpan(text: '$line\n', style: baseStyle));
      }
    }
    return spans;
  }

  void _showEducationDialog(BuildContext context, String title, String content) {
    showContentDialog(
      context: context,
      title: title,
      initialNarration: "Abrindo conteúdo: $title. ${content.replaceAll('\n', ' ').replaceAll('**', '').replaceAll('*', '')}",
      content: RichText(
        text: TextSpan(
          children: _buildTextSpans(content, context),
        ),
      ),
    );
  }

  Widget _buildEducationButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.menu_book, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({})),
        label: Text(title, style: TextStyle(color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}), fontSize: 16)),
        onPressed: () => _showEducationDialog(context, title, _educationContent[title] ?? 'Conteúdo não encontrado.'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityService>(context, listen: false);
    Future.microtask(() => access.speak("Tela de educação. Selecione um tema para aprender mais."));

    return Scaffold(
      appBar: AppBar(title: Text('Educação sobre Osteoartrite')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Selecione um tópico para aprender mais:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildEducationButton(context, 'O que é Osteoartrite'),
            _buildEducationButton(context, 'Sintomas e Sinais'),
            _buildEducationButton(context, 'Tratamento e Autocuidados'),
            _buildEducationButton(context, 'Alimentação Saudável'),
            _buildEducationButton(context, 'Saúde e Bem-estar'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                 Provider.of<AccessibilityService>(context, listen: false).stopSpeaking();
                 Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Voltar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ],
        ),
      ),
    );
  }
}
