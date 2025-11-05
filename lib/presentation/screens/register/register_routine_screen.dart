import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/api_service.dart';
import '../register/register_viewmodel.dart';

class RegisterRoutineScreen extends StatefulWidget {
  const RegisterRoutineScreen({super.key});

  @override
  State<RegisterRoutineScreen> createState() => _RegisterRoutineScreenState();
}

class _RegisterRoutineScreenState extends State<RegisterRoutineScreen> {
  final TextEditingController _infoIA = TextEditingController();
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  bool _showConfirmation = false;

  List<Map<String, String>> rutinas = [];
  List<Map<String, String>> objetos = [];

  // === SPEECH TO TEXT ===
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    Future.microtask(() async => await _initSpeech());
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _speech.initialize();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor habilita el micrófono para usar reconocimiento de voz.",
          ),
        ),
      );
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'es_ES',
        onResult: (result) {
          setState(() => _infoIA.text = result.recognizedWords);
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _processWithIA(String text, String userId) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingresa o graba información para procesar."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await apiService.post(
        "/profile/structure/",
        {"user_id": userId, "raw_text": text},
      );

      if (response.statusCode == 200) {
        final data = response.data["structured_profile"] ?? {};
        final rutinasData = data["rutinas"] ?? [];
        final objetosData = data["objetos"] ?? [];

        setState(() {
          rutinas = (rutinasData as List)
              .map((r) => {
                    "titulo": "${r["titulo"] ?? ""}",
                    "descripcion": "${r["descripcion"] ?? ""}",
                  })
              .toList();

          objetos = (objetosData as List)
              .map((o) => {
                    "nombre": "${o["nombre"] ?? ""}",
                    "descripcion": "${o["descripcion"] ?? ""}",
                    "tipo_relacion": "${o["tipo_relacion"] ?? ""}",
                  })
              .toList();

          _showConfirmation = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Información completada con IA ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error del servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error procesando con IA: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _agregarRutina() => setState(() => rutinas.add({"titulo": "", "descripcion": ""}));
  void _eliminarRutina(int index) => setState(() => rutinas.removeAt(index));

  void _agregarObjeto() =>
      setState(() => objetos.add({"nombre": "", "descripcion": "", "tipo_relacion": ""}));
  void _eliminarObjeto(int index) => setState(() => objetos.removeAt(index));

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final orange = Colors.orange.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Encabezado ===
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey.shade800,
                  ),
                  const Spacer(),
                  const Text(
                    'Rutinas y Objetos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 20),

              // === BLOQUE IA ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rellena automáticamente con IA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pulsa para grabar o escribe sobre tus rutinas y objetos para completar los campos de abajo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isListening ? _stopListening : _startListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isListening ? Colors.redAccent : Colors.orange.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: Icon(
                              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _infoIA,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'O escribe aquí tu información...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _processWithIA(_infoIA.text.trim(), registerVM.userId),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Procesar con IA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              if (_showConfirmation) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    "✅ Revisa que la información detectada sea correcta antes de continuar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // === Rutinas ===
              _buildSection("Rutinas", rutinas, _agregarRutina, _eliminarRutina, true),

              const SizedBox(height: 28),

              // === Objetos ===
              _buildSection("Objetos", objetos, _agregarObjeto, _eliminarObjeto, false),

              const SizedBox(height: 32),

              // === Botones Final ===
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Regresar",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);

                              registerVM.updateRutinas(rutinas: rutinas);
                              registerVM.updateObjetos(objetos: objetos);

                              final profileData = registerVM.buildProfileData();

                              if (mounted) {
                                setState(() => _isLoading = false);
                                Navigator.pushReplacementNamed(
                                    context, '/register-summary');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Finalizar registro",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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

  Widget _buildSection(String title, List<Map<String, String>> items,
      VoidCallback onAdd, Function(int) onDelete, bool isRutina) {
    final color = Colors.orange.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add, color: color),
              label: Text("Agregar",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text("No hay $title aún. Agrega uno nuevo abajo.",
              style: const TextStyle(color: Colors.black54)),
        ...items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                isRutina
                    ? "Rutina ${index + 1}: ${item["titulo"] ?? "Sin título"}"
                    : "Objeto ${index + 1}: ${item["nombre"] ?? "Sin nombre"}",
                style:
                    const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                if (isRutina) ...[
                  _buildEditableField(
                      label: "Título",
                      value: item["titulo"] ?? "",
                      onChanged: (v) => rutinas[index]["titulo"] = v),
                  _buildEditableField(
                      label: "Descripción",
                      value: item["descripcion"] ?? "",
                      onChanged: (v) => rutinas[index]["descripcion"] = v),
                ] else ...[
                  _buildEditableField(
                      label: "Nombre del objeto",
                      value: item["nombre"] ?? "",
                      onChanged: (v) => objetos[index]["nombre"] = v),
                  _buildEditableField(
                      label: "Tipo de relación",
                      value: item["tipo_relacion"] ?? "",
                      onChanged: (v) => objetos[index]["tipo_relacion"] = v),
                  _buildEditableField(
                      label: "Descripción",
                      value: item["descripcion"] ?? "",
                      onChanged: (v) => objetos[index]["descripcion"] = v),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => onDelete(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label:
                        const Text("Eliminar", style: TextStyle(color: Colors.red)),
                  ),
                )
              ],
            ),
          );
        })
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.orange.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
