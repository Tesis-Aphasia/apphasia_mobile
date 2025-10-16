import 'package:aphasia_mobile/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../register/register_viewmodel.dart';

class VnestConclusionScreen extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const VnestConclusionScreen({super.key, required this.exercise});

  Future<void> _completeExercise(BuildContext context) async {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final apiService = ApiService();
    final email = registerVM.userEmail;

    final idEjercicio = exercise['id_ejercicio_general'] ?? "";
    final contexto = exercise['context'] ?? exercise['contexto'] ?? "";
    

    if (email == null || email.isEmpty || idEjercicio.isEmpty || contexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faltan datos para completar el ejercicio.")),
      );
      return;
    }

    try {
      final response = await apiService.post('/completar_ejercicio/', {
        "email": email,
        "id_ejercicio": idEjercicio,
        "contexto": contexto,
      });

      if (response.statusCode == 200 && response.data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Ejercicio completado con éxito")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ ${response.data["message"] ?? "Error al completar"}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al completar: $e")),
      );
    }
  }

  // ---------------- Funciones de conjugación y construcción ----------------
  String conjugatePresentIndicative(String sujeto, String verbo) {
    if (verbo.endsWith("ar")) return verbo.substring(0, verbo.length - 2) + "a";
    if (verbo.endsWith("er")) return verbo.substring(0, verbo.length - 2) + "e";
    if (verbo.endsWith("ir")) return verbo.substring(0, verbo.length - 2) + "e";
    return verbo; // fallback
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String decapitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  Widget buildColoredSentence(Map<String, dynamic> exerciseData) {
    final who = exerciseData['who'] ?? '';
    final what = exerciseData['what'] ?? '';
    final verbo = exerciseData['verbo'] ?? '';
    final where = exerciseData['where'] ?? '';
    final why = exerciseData['why'] ?? '';
    final when = exerciseData['when'] ?? '';

    final colorSujeto = Colors.black87;
    final colorVerbo = Colors.orange.shade700;
    final colorObjeto = Colors.black87;
    final colorDonde = Colors.blue.shade700;
    final colorPorque = Colors.green.shade700;
    final colorCuando = Colors.purple.shade700;

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
          if (where.isNotEmpty)
            TextSpan(
                text: "${decapitalize(where)} ",
                style: TextStyle(color: colorDonde, fontWeight: FontWeight.w600)),
          if (why.isNotEmpty)
            TextSpan(
                text: "${decapitalize(why)} ",
                style: TextStyle(color: colorPorque, fontWeight: FontWeight.w600)),
          if (when.isNotEmpty)
            TextSpan(
                text: "${decapitalize(when)}",
                style: TextStyle(color: colorCuando, fontWeight: FontWeight.w600)),
          const TextSpan(text: ".", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFFEF9F4);
    final orange = const Color(0xFFFF8A00);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
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

              // --- Resumen ---
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
                    _buildInfoRow("Contexto", exercise['context'] ?? exercise['contexto'] ?? "—"),
                    _buildInfoRow("Pareja", "${exercise['who'] ?? ""} + ${exercise['what'] ?? ""}"),
                    _buildInfoRow("Verbo trabajado", exercise['verbo'] ?? ""),
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
                    buildColoredSentence(exercise), // RichText con colores y conjugación
                  ],
                ),
              ),

              const Spacer(),

              // --- Botón CTA ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _completeExercise(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
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
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
