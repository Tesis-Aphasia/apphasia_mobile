import 'dart:math';
import 'package:flutter/material.dart';

/// =============================
///  Modelo para opción-explicación
/// =============================
class ExpansionPair {
  final String opcion;
  final String explicacion;
  const ExpansionPair(this.opcion, this.explicacion);
}

/// =============================
///  Pantalla principal
/// =============================
class VnestSentenceExpansionScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const VnestSentenceExpansionScreen({super.key, required this.data});

  @override
  State<VnestSentenceExpansionScreen> createState() =>
      _VnestSentenceExpansionScreenState();
}

class _VnestSentenceExpansionScreenState
    extends State<VnestSentenceExpansionScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  late String verbo;
  late String who;
  late String what;
  late Map<String, dynamic> currentPair;

  List<ExpansionPair> dondePairs = [];
  List<ExpansionPair> porquePairs = [];
  List<ExpansionPair> cuandoPairs = [];

  String? correctDonde;
  String? correctPorque;
  String? correctCuando;

  String? selectedWhere;
  String? selectedWhy;
  String? selectedWhen;

  String? feedbackMessage; 

  // =============================
  //  Utils de texto
  // =============================
  String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  String decapitalize(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  // Conjugación simple a 3ra persona (presente)
  String conjugatePresentIndicative(String sujeto, String verbo) {
    if (verbo.endsWith("ar")) return verbo.substring(0, verbo.length - 2) + "a";
    if (verbo.endsWith("er")) return verbo.substring(0, verbo.length - 2) + "e";
    if (verbo.endsWith("ir")) return verbo.substring(0, verbo.length - 2) + "e";
    return verbo;
  }

  // =============================
  //  INITSTATE
  // =============================
  @override
  void initState() {
    super.initState();

    final exercise = widget.data;
    verbo = exercise['verbo'] ?? '';
    who = exercise['who'] ?? '';
    what = exercise['what'] ?? '';

    final paresRaw = (exercise['pares'] ?? []) as List;
    currentPair = Map<String, dynamic>.from(
      paresRaw.cast<Map>().firstWhere(
        (p) => p['sujeto'] == who && p['objeto'] == what,
        orElse: () => <String, dynamic>{},
      ),
    );

    final expansiones =
        Map<String, dynamic>.from(currentPair['expansiones'] ?? {});

    List<ExpansionPair> _makePairs(String key) {
      final section =
          Map<String, dynamic>.from(expansiones[key] ?? <String, dynamic>{});
      final ops = List<String>.from(section['opciones'] ?? []);
      final exps = List<String>.from(section['explicaciones'] ?? []);
      final pairs = <ExpansionPair>[];
      for (int i = 0; i < ops.length; i++) {
        pairs.add(ExpansionPair(ops[i], i < exps.length ? exps[i] : ""));
      }
      pairs.shuffle(Random());
      return pairs;
    }

    dondePairs = _makePairs('donde');
    porquePairs = _makePairs('por_que');
    cuandoPairs = _makePairs('cuando');

    correctDonde =
        expansiones['donde'] != null ? expansiones['donde']['opcion_correcta'] : null;
    correctPorque =
        expansiones['por_que'] != null ? expansiones['por_que']['opcion_correcta'] : null;
    correctCuando =
        expansiones['cuando'] != null ? expansiones['cuando']['opcion_correcta'] : null;
  }

  // =============================
  //  Construcción de oración
  // =============================
  String buildSentence() {
    final vConj = conjugatePresentIndicative(who, verbo);
    final parts = <String>[
      capitalize(who),
      decapitalize(vConj),
      decapitalize(what),
      if (selectedWhere != null && selectedWhere!.isNotEmpty)
        decapitalize(selectedWhere!),
      if (selectedWhy != null && selectedWhy!.isNotEmpty)
        decapitalize(selectedWhy!),
      if (selectedWhen != null && selectedWhen!.isNotEmpty)
        decapitalize(selectedWhen!),
    ];
    final sentence = parts.where((p) => p.trim().isNotEmpty).join(' ');
    return sentence.endsWith('.') ? sentence : '$sentence.';
  }

  // =============================
  //  Oración final coloreada
  // =============================
  Widget buildColoredSentence() {
    final whereCorrect = selectedWhere != null && selectedWhere == correctDonde;
    final whyCorrect = selectedWhy != null && selectedWhy == correctPorque;
    final whenCorrect = selectedWhen != null && selectedWhen == correctCuando;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: "${capitalize(who)} ",
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: "${decapitalize(conjugatePresentIndicative(who, verbo))} ",
            style: TextStyle(color: orange, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: "${decapitalize(what)} ",
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          if (selectedWhere != null)
            TextSpan(
              text: "${decapitalize(selectedWhere!)} ",
              style: TextStyle(
                color: whereCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (selectedWhy != null)
            TextSpan(
              text: "${decapitalize(selectedWhy!)} ",
              style: TextStyle(
                color: whyCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (selectedWhen != null)
            TextSpan(
              text: "${decapitalize(selectedWhen!)}",
              style: TextStyle(
                color: whenCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          const TextSpan(
            text: ".",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // =============================
  //  Validación antes de continuar
  // =============================
  void handleNext() {
    final whereCorrect = selectedWhere == correctDonde;
    final whyCorrect = selectedWhy == correctPorque;
    final whenCorrect = selectedWhen == correctCuando;

    if (!whereCorrect || !whyCorrect || !whenCorrect) {
      setState(() {
        feedbackMessage =
            "Debes seleccionar correctamente las tres opciones antes de continuar.";
      });
      return;
    }

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

  // =============================
  //  Tarjetas superiores
  // =============================
  Widget _wordCard(String label, String text, {bool isVerb = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isVerb ? orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isVerb ? orange : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isVerb ? orange : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isVerb ? orange : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCards() {
    final verboConjugado = conjugatePresentIndicative(who, verbo);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _wordCard("¿Quién?", capitalize(who)),
        _wordCard("Verbo", verboConjugado, isVerb: true),
        _wordCard("¿Qué?", decapitalize(what)),
      ],
    );
  }

  // =============================
  //  Sección de preguntas
  // =============================
  Widget _buildQuestionSection({
    required IconData icon,
    required String title,
    required List<ExpansionPair>? pairs,
    required String? selectedValue,
    required String? correctValue,
    required void Function(String) onSelect,
    required Color accentColor,
  }) {
    final safePairs = pairs ?? [];
    if (safePairs.isEmpty) return const SizedBox();

    final ExpansionPair selectedPair = safePairs.firstWhere(
      (p) => p.opcion == selectedValue,
      orElse: () => const ExpansionPair("", ""),
    );
    final selectedExplanation = selectedPair.explicacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withOpacity(0.1),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...safePairs.map((p) {
          final op = p.opcion;
          final isSelected = selectedValue == op;
          final isCorrect = isSelected && op == correctValue;
          final isWrong = isSelected && op != correctValue;

          Color borderColor = Colors.grey.shade300;
          Color bgColor = Colors.white;
          Color textColor = Colors.black87;

          if (isSelected) {
            borderColor = accentColor.withOpacity(0.5);
            bgColor = accentColor.withOpacity(0.05);
          }
          if (isCorrect) {
            borderColor = Colors.green.shade600;
            bgColor = Colors.green.shade50;
            textColor = Colors.green.shade900;
          } else if (isWrong) {
            borderColor = Colors.red.shade600;
            bgColor = Colors.red.shade50;
            textColor = Colors.red.shade900;
          }

          return GestureDetector(
            onTap: () => setState(() {
              onSelect(op);
              feedbackMessage = null;
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      op,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  if (isWrong)
                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                ],
              ),
            ),
          );
        }),
        if (selectedExplanation.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              selectedExplanation,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
      ],
    );
  }

  // =============================
  //  BUILD
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Expansión de Oraciones",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {}, // futuro: TTS
            icon: const Icon(Icons.volume_up_rounded, color: Colors.black54),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Paso 2 de 5",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: 0.3,
                color: orange,
                backgroundColor: Colors.grey.shade200,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 16),
              _buildHeaderCards(),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildQuestionSection(
                      icon: Icons.location_on_rounded,
                      title: "¿Dónde?",
                      pairs: dondePairs,
                      selectedValue: selectedWhere,
                      correctValue: correctDonde,
                      onSelect: (v) => selectedWhere = v,
                      accentColor: Colors.orange,
                    ),
                    _buildQuestionSection(
                      icon: Icons.psychology_alt_rounded,
                      title: "¿Por qué?",
                      pairs: porquePairs,
                      selectedValue: selectedWhy,
                      correctValue: correctPorque,
                      onSelect: (v) => selectedWhy = v,
                      accentColor: Colors.green,
                    ),
                    _buildQuestionSection(
                      icon: Icons.access_time_rounded,
                      title: "¿Cuándo?",
                      pairs: cuandoPairs,
                      selectedValue: selectedWhen,
                      correctValue: correctCuando,
                      onSelect: (v) => selectedWhen = v,
                      accentColor: Colors.purple,
                    ),
                  ],
                ),
              ),
              if (feedbackMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    feedbackMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: buildColoredSentence(),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
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
          ),
        ),
      ),
    );
  }
}
