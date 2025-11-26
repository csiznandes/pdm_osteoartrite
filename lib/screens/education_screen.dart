import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';

class EducationScreen extends StatelessWidget {
  
  final Map<String, String> _educationContent = {
    'O que é Osteoartrite': """
**ENTENDENDO SUA CONDIÇÃO**
O que acontece? A osteoartrite (ou artrose) é o desgaste natural da cartilagem que protege suas articulações. Com o tempo, os ossos ficam mais próximos e causam dor e rigidez.
*Pense assim: É como o desgaste de um pneu de carro - com o uso ao longo dos anos, a proteção vai diminuindo.*
✅ **IMPORTANTE SABER:**
- É muito comum após os 60 anos
- NÃO é culpa sua
- Tem tratamento e controle
- Você pode viver bem com osteoartrite
**Articulações mais afetadas:**
- Joelhos - Mãos e dedos - Quadril - Coluna - Pés
""",
    'Sintomas e Sinais': """
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
- Dor muito forte e súbita - Inchaço grande e vermelhidão - Febre junto com dor - Impossibilidade de mover a articulação
**POR QUE ACONTECE?**
**Causas principais:**
- Idade: desgaste natural ao longo da vida - Uso repetitivo: trabalhos que sobrecarregam - Lesões anteriores: fraturas, torções - Sobrepeso: pressão extra nas articulações - Genética: pode ser de família - Postura inadequada
**FATORES QUE VOCÊ PODE CONTROLAR:**
✅ Peso corporal ✅ Atividade física regular ✅ Postura no dia a dia ✅ Proteção das articulações ✅ Alimentação saudável
""",
    'Tratamento e Autocuidados': """
**OPÇÕES DE TRATAMENTO**
Objetivo: Reduzir dor e manter movimento
A) **MEDICAMENTOS:**
- Analgésicos - Anti-inflamatórios (com orientação médica) - Pomadas e géis - Suplementos.
B) **PRÁTICAS INTEGRATIVAS (PICs):** ✨ *Este app foca nestas práticas!*
- Exercícios adaptados - Termoterapia - Acupuntura/Acupressão - Yoga e Tai Chi - Massagem terapêutica - Fitoterapia
C) **FISIOTERAPIA:**
- Fortalecimento muscular - Melhora da mobilidade - Técnicas de proteção articular
D) **MUDANÇAS NO ESTILO DE VIDA:**
- Perda de peso (se necessário) - Alimentação anti-inflamatória - Exercícios regulares - Adaptações no dia a dia
E) **TRATAMENTOS AVANÇADOS:**
- Infiltrações (injeções) - Viscossuplementação - Cirurgia (casos específicos)
**ABORDAGEM INTEGRADA:** O melhor resultado vem da COMBINAÇÃO de tratamentos, não apenas um!
""",
    'Alimentação Saudável': """
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
❌ Açúcar em excesso ❌ Frituras ❌ Carnes processadas ❌ Bebidas alcoólicas em excesso ❌ Sal em excesso
**HIDRATAÇÃO:** Beba 6-8 copos de água por dia. *A cartilagem precisa de água!*
**Chás recomendados:** Chá verde - Gengibre - Cúrcuma - Cavalinha
*Sempre consulte seu médico antes de mudanças grandes na dieta.*
""",
    'Saúde e Bem-estar': """
**ADAPTAÇÕES PRÁTICAS**
**Na cozinha:** Use utensílios com cabos grossos, Abridores automáticos, Banqueta.
**No banheiro:** Barras de apoio, Tapete antiderrapante, Banco para sentar no banho.
**Calçados:** Prefira solado antiderrapante, Salto baixo (2-3 cm), Amortecimento.
**Movimentação:** Use bengala se necessário, Levante-se devagar, Evite ficar muito tempo na mesma posição.
**Proteção articular:** Carregue peso perto do corpo, Use as duas mãos para tarefas pesadas.
**CUIDANDO DA MENTE**
É normal sentir: Frustração, Medo, Tristeza, Ansiedade. **VOCÊ NÃO ESTÁ SOZINHO!**
**Estratégias de enfrentamento:** Foque no que VOCÊ PODE fazer, Celebre pequenas vitórias, Mantenha hobbies, Peça ajuda.
**Busque ajuda se sentir:** Tristeza constante, Perda de interesse, Isolamento social. *Psicólogo pode ajudar muito!*
**QUALIDADE DE VIDA**
**Princípios:** MOVIMENTO é remédio, EQUILÍBRIO, ATITUDE positiva, APOIO social, APRENDIZADO.
Lembre-se: *"Osteoartrite é parte de você, mas NÃO define quem você é!"*
""",
  };

  void _showEducationDialog(BuildContext context, String title, String content) {
    Provider.of<AccessibilityService>(context, listen: false)
      .speak("Abrindo conteúdo: $title. ${content.replaceAll("\n", " ")}");
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
          child: Text(content, style: TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

  Widget _buildEducationButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.menu_book, color: Colors.black),
        label: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
        onPressed: () => _showEducationDialog(context, title, _educationContent[title] ?? 'Conteúdo não encontrado.'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final access = Provider.of<AccessibilityService>(context, listen: false);
      access.speak("Tela de educação. Selecione um tema para aprender mais.");
    });

    return Scaffold(
      appBar: AppBar(title: Text('Educação sobre Osteoartrite')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Selecione um tópico para aprender mais:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildEducationButton(context, 'O que é Osteoartrite'),
            _buildEducationButton(context, 'Sintomas e Sinais'),
            _buildEducationButton(context, 'Tratamento e Autocuidados'),
            _buildEducationButton(context, 'Alimentação Saudável'),
            _buildEducationButton(context, 'Saúde e Bem-estar'),
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