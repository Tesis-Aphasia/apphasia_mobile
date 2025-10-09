import 'package:flutter/material.dart';

class VnestConclusionScreen extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const VnestConclusionScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFFEF9F4); // beige suave
    final orange = const Color(0xFFFF8A00); // naranja principal

    final verbo = exercise['verbo'] ?? "—";
    final who = exercise['who'] ?? "—";
    final what = exercise['what'] ?? "—";
    final where = exercise['where'] ?? "—";
    final why = exercise['why'] ?? "—";
    final when = exercise['when'] ?? "—";
    final contextText = exercise['context'] ?? "—";

    final sentence = exercise['sentence'] ??
        "$who $verbo $what $where $why $when.".replaceAll(RegExp(r'\s+\.'), ".");

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // 🎉 Encabezado animado
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 600),
                child: Column(
                  children: [
                    Icon(Icons.celebration_rounded, color: orange, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      "¡Felicidades!",
                      style: TextStyle(
                        color: orange,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Has completado el ejercicio de VNeST.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- Sección resumen general ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resumen del ejercicio",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow("Contexto", contextText),
                    _buildInfoRow("Pareja", "$who + $what"),
                    _buildInfoRow("Verbo trabajado", verbo),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Oración final destacada ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: orange.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Oración final",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: orange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sentence,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- Botón CTA ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Reinicia el flujo completo:
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/menu', (route) => false);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    "Empezar de nuevo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
