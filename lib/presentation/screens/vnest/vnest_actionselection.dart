import 'dart:math';
import 'package:flutter/material.dart';

class VnestActionSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> exercise; // viene del contexto anterior

  const VnestActionSelectionScreen({super.key, required this.exercise});

  @override
  State<VnestActionSelectionScreen> createState() => _VnestActionSelectionScreenState();
}

class _VnestActionSelectionScreenState extends State<VnestActionSelectionScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  late String verbo;
  late List<String> sujetos;
  late List<String> objetos;
  late Set<String> validPairs;

  String? selectedWho;
  String? selectedWhat;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    verbo = exercise['verbo'] ?? 'Acción';
    final pares = (exercise['pares'] as List?) ?? [];

    // Extraer y barajar sujetos y objetos únicos
    final s = <String>{};
    final o = <String>{};
    final vp = <String>{};
    for (final p in pares) {
      final sujeto = p['sujeto'];
      final objeto = p['objeto'];
      if (sujeto != null) s.add(sujeto);
      if (objeto != null) o.add(objeto);
      if (sujeto != null && objeto != null) vp.add('$sujeto|||$objeto');
    }

    sujetos = _shuffle(s.toList());
    objetos = _shuffle(o.toList());
    validPairs = vp;
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

  bool get pairIsValid {
    if (selectedWho == null || selectedWhat == null) return false;
    return validPairs.contains('$selectedWho|||$selectedWhat');
  }

  void handleNext() {
    if (!pairIsValid) return;

    final Map<String, dynamic> args = {
      "who": selectedWho ?? "",
      "what": selectedWhat ?? "",
      "verbo": verbo,
      "pares": widget.exercise["pares"],
      "oraciones": widget.exercise["oraciones"],
      "context": widget.exercise["context"],
    };

    Navigator.pushNamed(
      context,
      '/vnest-phase2',
      arguments: args,
    );
  }



  @override
  Widget build(BuildContext context) {
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
          "Elige ¿quién? y ¿qué?",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // --- Verbo central ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  verbo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Advertencia si combinación inválida ---
              if (selectedWho != null &&
                  selectedWhat != null &&
                  !pairIsValid)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Esa combinación no va junta. Intenta con otro sujeto u objeto.",
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              Expanded(
                child: Row(
                  children: [
                    // --- Columna Izquierda (¿Quién?) ---
                    Expanded(
                      child: _buildColumnSelector(
                        title: "¿QUIÉN?",
                        options: sujetos,
                        selectedValue: selectedWho,
                        onSelect: (s) => setState(() => selectedWho = s),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // --- Columna Derecha (¿Qué?) ---
                    Expanded(
                      child: _buildColumnSelector(
                        title: "¿QUÉ?",
                        options: objetos,
                        selectedValue: selectedWhat,
                        onSelect: (s) => setState(() => selectedWhat = s),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Progreso + Botones ---
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnSelector({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final item = options[index];
              final isSelected = selectedValue == item;
              return _buildOptionButton(item, isSelected, onSelect);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, Function(String) onSelect) {
    final baseColor = isSelected ? orange : Colors.white;
    final borderColor = isSelected ? orange : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => onSelect(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(isSelected ? 0.1 : 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: orange.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? orange : Colors.black87,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Fase 1", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text("1/4", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        // Progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.25,
            backgroundColor: Colors.grey.shade200,
            color: orange,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Anterior",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: pairIsValid ? handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  disabledBackgroundColor: orange.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Siguiente",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
