import 'dart:math';
import 'package:flutter/material.dart';

class VnestActionSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const VnestActionSelectionScreen({super.key, required this.exercise});

  @override
  State<VnestActionSelectionScreen> createState() => _VnestActionSelectionScreenState();
}

class _VnestActionSelectionScreenState extends State<VnestActionSelectionScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);
  final darkText = const Color(0xFF222222);

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
      "id_ejercicio_general": widget.exercise["id_ejercicio_general"],
    };

    Navigator.pushNamed(context, '/vnest-phase2', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Elige ¿Quién y Qué?",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progreso
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Paso 1 de 5",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.2,
                  backgroundColor: Colors.grey.shade200,
                  color: orange,
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // Verbo central
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  verbo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Columnas de selección
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildColumnSelector(
                        title: "¿Quién?",
                        options: sujetos,
                        selectedValue: selectedWho,
                        onSelect: (s) => setState(() => selectedWho = s),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildColumnSelector(
                        title: "¿Qué?",
                        options: objetos,
                        selectedValue: selectedWhat,
                        onSelect: (s) => setState(() => selectedWhat = s),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Error message
              if (selectedWho != null &&
                  selectedWhat != null &&
                  !pairIsValid)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Combinación inválida. Por favor, intenta de nuevo.",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Anterior",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pairIsValid ? handleNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pairIsValid
                            ? const Color(0xFFFF8A00)
                            : const Color(0xFFFF8A00).withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Siguiente",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
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
    return GestureDetector(
      onTap: () => onSelect(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 56, 
        alignment: Alignment.center, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8A00) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF8A00) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
            height: 1.1, 
          ),
        ),
      ),
    );
  }
}
