import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../data/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../screens/register/register_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalizeExercisesScreen extends StatefulWidget {
  const PersonalizeExercisesScreen({super.key});

  @override
  State<PersonalizeExercisesScreen> createState() => _PersonalizeExercisesScreenState();
}

class _PersonalizeExercisesScreenState extends State<PersonalizeExercisesScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);
  final ApiService apiService = ApiService();

  List<String> contexts = [];
  String? selectedContext;

  List<Map<String, dynamic>> verbs = [];
  List<String> selectedVerbs = [];

  bool loading = false;
  String? feedback;

  @override
  void initState() {
    super.initState();
    fetchContexts();
  }

  // ===========================
  // 🔹 Obtener contextos de Firestore
  // ===========================
  Future<void> fetchContexts() async {
    setState(() {
      loading = true;
      feedback = null;
    });

    try {
      final response = await apiService.get("/contexts"); // ← Debes tener un endpoint que devuelva todos los contextos únicos
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["contexts"] ?? [];
        setState(() => contexts = List<String>.from(data));
      } else {
        setState(() => feedback = "Error al obtener contextos (${response.statusCode}).");
      }
    } on DioException catch (e) {
      setState(() {
        feedback = e.response?.data?.toString() ?? "Error de conexión con el servidor.";
      });
    } catch (e) {
      setState(() => feedback = "Error inesperado: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // ===========================
  // 🔹 Obtener verbos para un contexto
  // ===========================
  Future<void> fetchVerbsForContext(String context) async {
    setState(() {
      loading = true;
      feedback = null;
      verbs = [];
      selectedVerbs = [];
    });

    try {
      final response = await apiService.post(
        "/context/verbs/",
        {"context": context},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data["verbs"] ?? [];
        setState(() => verbs = List<Map<String, dynamic>>.from(data));
      } else {
        setState(() => feedback = "Error al obtener verbos (${response.statusCode}).");
      }
    } on DioException catch (e) {
      setState(() {
        feedback = e.response?.data?.toString() ?? "Error de conexión con el servidor.";
      });
    } catch (e) {
      setState(() => feedback = "Error inesperado: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // ===========================
  // 🔹 Generar ejercicios personalizados
  // ===========================
Future<void> generatePersonalized() async {
  if (selectedContext == null || selectedVerbs.isEmpty) {
    setState(() => feedback = "Selecciona un contexto y al menos un verbo.");
    return;
  }

  final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
  final userId = registerVM.userId;

  setState(() {
    loading = true;
    feedback = null;
  });

  try {
    // Cargar perfil completo del paciente desde Firestore
    final profileSnap = await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(userId)
        .get();
    final profileData = profileSnap.data() ?? {};

    // Personalizar por cada verbo seleccionado
    for (final verboData in verbs.where((v) => selectedVerbs.contains(v["verbo"]))) {
      final exerciseId = verboData["id_ejercicio_general"];

      if (exerciseId == null || (exerciseId is String && exerciseId.isEmpty)) {
        debugPrint("No se encontró id_ejercicio_general para ${verboData["verbo"]}");
        continue;
      }

      await apiService.post(
        "/personalize-exercise/",
        {
          "user_id": userId,
          "exercise_id": exerciseId,
          "profile": profileData,
        },
      );
    }

    setState(() {
      feedback =
          "Ejercicios personalizados creados en el contexto $selectedContext con los verbos: ${selectedVerbs.join(', ')}.";
      selectedVerbs.clear();
    });
  } catch (e) {
    setState(() => feedback = "Error al personalizar ejercicios: $e");
  } finally {
    setState(() => loading = false);
  }
}


  // ===========================
  // 🔹 Interfaz
  // ===========================
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
          "Personalizar Ejercicios",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contexto",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 12),

              // Contextos dinámicos
              if (loading && contexts.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (contexts.isEmpty)
                const Text("No hay contextos disponibles.")
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: contexts.map((ctx) {
                    final isSelected = selectedContext == ctx;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedContext = ctx);
                        fetchVerbsForContext(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? orange : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? orange : Colors.grey.shade300),
                        ),
                        child: Text(
                          ctx,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              Text("Verbos Disponibles",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 12),

              if (loading && verbs.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (verbs.isEmpty)
                const Text("Selecciona un contexto para ver los verbos.")
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: verbs.length,
                    itemBuilder: (context, index) {
                      final verboData = verbs[index];
                      final verbo = verboData["verbo"];
                      final highlight = verboData["highlight"] ?? false;
                      final isChecked = selectedVerbs.contains(verbo);

                      return CheckboxListTile(
                        activeColor: orange,
                        value: isChecked,
                        title: Row(
                          children: [
                            Text(verbo, style: const TextStyle(fontSize: 16)),
                            if (highlight)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                              ),
                          ],
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedVerbs.add(verbo);
                            } else {
                              selectedVerbs.remove(verbo);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              if (feedback != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    feedback!,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: loading ? null : generatePersonalized,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Generar Ejercicios",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
