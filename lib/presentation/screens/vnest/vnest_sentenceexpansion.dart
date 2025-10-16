import 'dart:math';
import 'package:flutter/material.dart';

class VnestSentenceExpansionScreen extends StatefulWidget {
  final Map<String, dynamic> data; // viene de la fase anterior

  const VnestSentenceExpansionScreen({super.key, required this.data});

  @override
  State<VnestSentenceExpansionScreen> createState() =>
      _VnestSentenceExpansionScreenState();
}

class _VnestSentenceExpansionScreenState
    extends State<VnestSentenceExpansionScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);
  final Color colorSujeto = Colors.black87;
  final Color colorVerbo = Colors.orange.shade700;
  final Color colorObjeto = Colors.black87;
  final Color colorDonde = Colors.blue.shade700;
  final Color colorPorque = Colors.green.shade700;
  final Color colorCuando = Colors.purple.shade700;

  late String verbo;
  late String who;
  late String what;
  late Map<String, dynamic> currentPair;

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String decapitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  List<String> donde = [];
  List<String> porque = [];
  List<String> cuando = [];

  String? correctDonde;
  String? correctPorque;
  String? correctCuando;

  String? selectedWhere;
  String? selectedWhy;
  String? selectedWhen;

  @override
  void initState() {
    super.initState();

    final exercise = widget.data;
    verbo = exercise['verbo'] ?? '';
    who = exercise['who'] ?? '';
    what = exercise['what'] ?? '';

    // 🔎 buscar el par correcto
    final pares = (exercise['pares'] as List?) ?? [];
    currentPair = pares.firstWhere(
      (p) => p['sujeto'] == who && p['objeto'] == what,
      orElse: () => {},
    );

    // obtener expansiones
    final expansiones = currentPair['expansiones'] ?? {};

    donde = _shuffle(List<String>.from(expansiones['donde']?['opciones'] ?? []));
    porque = _shuffle(List<String>.from(expansiones['por_que']?['opciones'] ?? []));
    cuando = _shuffle(List<String>.from(expansiones['cuando']?['opciones'] ?? []));

    correctDonde = expansiones['donde']?['opcion_correcta'];
    correctPorque = expansiones['por_que']?['opcion_correcta'];
    correctCuando = expansiones['cuando']?['opcion_correcta'];

    // inicializar selección por defecto
    if (donde.isNotEmpty) selectedWhere = donde.first;
    if (porque.isNotEmpty) selectedWhy = porque.first;
    if (cuando.isNotEmpty) selectedWhen = cuando.first;
  }

  List<T> _shuffle<T>(List<T> items) {
    final rand = Random();
    for (int i = items.length - 1; i > 0; i--) {
      int j = rand.nextInt(i + 1);
      final temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
    return items;
  }

  /// Función simple para conjugar presente indicativo 3ra persona singular
  String conjugatePresentIndicative(String sujeto, String verbo) {
    if (verbo.endsWith("ar")) return verbo.substring(0, verbo.length - 2) + "a";
    if (verbo.endsWith("er")) return verbo.substring(0, verbo.length - 2) + "e";
    if (verbo.endsWith("ir")) return verbo.substring(0, verbo.length - 2) + "e";
    return verbo; // fallback
  }

  String buildSentence() {
    final verboConjugado = conjugatePresentIndicative(who, verbo);

    final parts = [
      who,
      verboConjugado, // usamos el verbo conjugado
      what,
      selectedWhere ?? '',
      selectedWhy ?? '',
      selectedWhen ?? ''
    ].where((p) => p.isNotEmpty).join(' ');

    return '$parts.';
  }

  void handleNext() {
    final safeData = Map<String, dynamic>.from(widget.data);

    Navigator.pushNamed(
      context,
      '/vnest-phase3',
      arguments: {
        ...safeData,
        'who': who,
        'what': what,
        'where': selectedWhere,
        'why': selectedWhy,
        'when': selectedWhen,
        'sentence': buildSentence(),
        'id_ejercicio_general': widget.data['id_ejercicio_general'] ?? "",
      },
    );
  }

    // Función para crear el RichText de la oración completa
  Widget buildColoredSentence() {
    final verboConjugado = conjugatePresentIndicative(who, verbo);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          if (who.isNotEmpty)
            TextSpan(
                text: "${capitalize(who)} ",
                style: TextStyle(color: colorSujeto, fontWeight: FontWeight.w600)),
          if (verboConjugado.isNotEmpty)
            TextSpan(
                text: "${decapitalize(verboConjugado)} ",
                style: TextStyle(color: colorVerbo, fontWeight: FontWeight.w600)),
          if (what.isNotEmpty)
            TextSpan(
                text: "${decapitalize(what)} ",
                style: TextStyle(color: colorObjeto, fontWeight: FontWeight.w600)),
          if (selectedWhere != null)
            TextSpan(
                text: "${decapitalize(selectedWhere!)} ",
                style: TextStyle(color: colorDonde, fontWeight: FontWeight.w600)),
          if (selectedWhy != null)
            TextSpan(
                text: "${decapitalize(selectedWhy!)} ",
                style: TextStyle(color: colorPorque, fontWeight: FontWeight.w600)),
          if (selectedWhen != null)
            TextSpan(
                text: "${decapitalize(selectedWhen!)}",
                style: TextStyle(color: colorCuando, fontWeight: FontWeight.w600)),
          TextSpan(text: ".", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (currentPair.isEmpty) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Faltan datos para esta pareja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Regresa y selecciona un contexto y una pareja válidos.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Completa la oración",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              _buildHeaderCards(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                        "1. ¿DÓNDE?", donde, selectedWhere, correctDonde,
                        (v) => setState(() => selectedWhere = v)),
                    _buildSection(
                        "2. ¿POR QUÉ?", porque, selectedWhy, correctPorque,
                        (v) => setState(() => selectedWhy = v)),
                    _buildSection(
                        "3. ¿CUÁNDO?", cuando, selectedWhen, correctCuando,
                        (v) => setState(() => selectedWhen = v)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCards() {
    final verboConjugado = conjugatePresentIndicative(who, verbo);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallCard("¿Quién?", who, Colors.black87),
        _smallCard("Verbo", verboConjugado, orange), // conjugado aquí
        _smallCard("¿Qué?", what, Colors.black87),
      ],
    );
  }

  Widget _smallCard(String label, String text, Color color) {
    final isOrange = color == orange;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOrange ? orange : Colors.black87,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String? selectedValue,
      String? correctValue, Function(String) onSelect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...options.map((op) {
            final isSelected = selectedValue == op;
            final isCorrect = isSelected && op == correctValue;
            final isWrong = isSelected && op != correctValue;

            Color borderColor;
            Color bgColor;
            Color textColor;

            if (isCorrect) {
              borderColor = Colors.green.shade600;
              bgColor = Colors.green.shade50;
              textColor = Colors.green.shade900;
            } else if (isWrong) {
              borderColor = Colors.red.shade600;
              bgColor = Colors.red.shade50;
              textColor = Colors.red.shade900;
            } else {
              borderColor = Colors.grey.shade300;
              bgColor = Colors.white;
              textColor = Colors.black87;
            }

            return GestureDetector(
              onTap: () => onSelect(op),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Text(
                  op,
                  style: TextStyle(
                    color: textColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Oración completa
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Text(
                "Oración completa:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              buildColoredSentence(), // <-- RichText con colores
            ],
          ),
        ),


        // Progreso
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Fase 2", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text("2/4", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.grey.shade200,
            color: orange,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),

        // Botones
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Anterior"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Siguiente",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
