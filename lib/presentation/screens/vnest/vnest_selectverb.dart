import 'package:aphasia_mobile/presentation/screens/register/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../data/services/api_service.dart';

class VnestSelectVerbScreen extends StatefulWidget {
  final String context; // Contexto seleccionado desde la pantalla anterior

  const VnestSelectVerbScreen({super.key, required this.context});

  @override
  State<VnestSelectVerbScreen> createState() => _VnestSelectVerbScreenState();
}

class _VnestSelectVerbScreenState extends State<VnestSelectVerbScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  final ApiService apiService = ApiService();

  bool loading = false;
  bool loadingExercise = false;
  String? error;
  List<Map<String, dynamic>> verbs = []; // ✅ verbo + highlight
  String? selectedVerb;

  @override
  void initState() {
    super.initState();
    fetchVerbs();
  }

  // ============================
  // 🔹 OBTENER VERBOS DEL CONTEXTO
  // ============================
  Future<void> fetchVerbs() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
      final email = registerVM.userEmail; // ✅ obtenemos el correo del paciente

      final response = await apiService.post(
        '/context/verbs/',
        {
          "context": widget.context,
          "email": email, // ✅ ahora se envía al backend
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['verbs'] ?? [];

        final parsed = data.map<Map<String, dynamic>>((v) {
          if (v is Map) {
            return {
              "verbo": v["verbo"],
              "highlight": v["highlight"] ?? false,
            };
          }
          return {"verbo": v.toString(), "highlight": false};
        }).toList();

        final unique = {
          for (var v in parsed) v["verbo"]: v,
        }.values.toList();

        setState(() {
          verbs = unique;
        });
      } else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      setState(() {
        error = e.response != null
            ? "Error ${e.response?.statusCode}: ${e.response?.data}"
            : "Error de conexión: ${e.message}";
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => loading = false);
    }
  }


  // ============================
  // 🔹 PEDIR EJERCICIO DEL VERBO
  // ============================
  Future<void> requestExercise(String verbo) async {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final email = registerVM.userEmail;

    setState(() {
      loadingExercise = true;
      error = null;
    });

    try {
      final response = await apiService.post(
        '/get_exercise_context/',
        {
          "context": widget.context,
          "nivel": "facil",
          "verbo": verbo,
          "email": email,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

        Navigator.pushNamed(
          context,
          '/vnest-action',
          arguments: {
            ...data,
            'context': widget.context,
            'verbo': verbo,
          },
        );
      } else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      setState(() {
        error = e.response != null
            ? "Error ${e.response?.statusCode}: ${e.response?.data}"
            : "Error de conexión: ${e.message}";
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => loadingExercise = false);
    }
  }

  // ============================
  // 🔹 INTERFAZ
  // ============================
  @override
  Widget build(BuildContext context) {
    final isLoading = loading || loadingExercise;
    final loadingText = loading
        ? "Cargando verbos…"
        : (loadingExercise ? "Cargando ejercicio…" : "");

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
          "Selecciona un verbo",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isLoading
              ? _buildLoading(loadingText)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null) _buildError(),
                    Expanded(
                      child: verbs.isEmpty
                          ? const Center(child: Text("No hay verbos disponibles"))
                          : ListView.builder(
                              itemCount: verbs.length,
                              itemBuilder: (context, index) =>
                                  _buildVerbOption(verbs[index]),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoading(String text) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: orange, strokeWidth: 4),
            const SizedBox(height: 20),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildError() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error ?? "Error cargando verbos",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: fetchVerbs,
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );

  // ============================
  // 🔹 OPCIÓN DE VERBO
  // ============================
  Widget _buildVerbOption(Map<String, dynamic> verbData) {
    final verbo = verbData["verbo"] ?? "";
    final highlight = verbData["highlight"] ?? false;
    final isSelected = selectedVerb == verbo;

    return InkWell(
      onTap: () async {
        setState(() => selectedVerb = verbo);
        await requestExercise(verbo);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? orange.withOpacity(0.1)
              : highlight
                  ? Colors.yellow.shade50
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? orange
                : highlight
                    ? Colors.amber
                    : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono (bombillo o play)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: highlight
                    ? Colors.amber.withOpacity(0.15)
                    : orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                highlight ? Icons.lightbulb_rounded : Icons.play_arrow_rounded,
                color: highlight ? Colors.amber.shade700 : orange,
                size: highlight ? 28 : 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                verbo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: highlight ? Colors.amber.shade800 : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? orange : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
