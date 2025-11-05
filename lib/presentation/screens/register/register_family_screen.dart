import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../data/services/api_service.dart';
import 'register_viewmodel.dart';

class RegisterFamilyScreen extends StatefulWidget {
  const RegisterFamilyScreen({super.key});

  @override
  State<RegisterFamilyScreen> createState() => _RegisterFamilyScreenState();
}

class _RegisterFamilyScreenState extends State<RegisterFamilyScreen> {
  final TextEditingController _infoIA = TextEditingController();
  final ApiService apiService = ApiService();

  List<Map<String, String>> familiares = [];
  final List<String> parentescos = [
    'Cónyuge/Pareja',
    'Hijo/a',
    'Padre/Madre',
    'Hermano/a',
    'Otro',
  ];

  // === SPEECH TO TEXT ===
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  bool _showConfirmation = false;
  String recognizedText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    Future.microtask(() async => await _initSpeech());
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      await _speech.initialize(
        onStatus: (val) => print('Speech status: $val'),
        onError: (val) => print('Speech error: $val'),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Por favor habilita el micrófono para usar reconocimiento de voz.")),
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
          setState(() {
            recognizedText = result.recognizedWords;
            _infoIA.text = recognizedText;
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _agregarFamiliar() {
    setState(() {
      familiares.add({
        'nombre': '',
        'tipo_relacion': parentescos.first,
        'descripcion': '',
      });
    });
  }

  void _eliminarFamiliar(int index) {
    setState(() => familiares.removeAt(index));
  }

  Future<void> _processWithIA(String text, String userId) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor ingresa o graba información para procesar.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await apiService.post(
        "/profile/structure/",
        {
          "user_id": userId,
          "raw_text": text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data["structured_profile"] ?? {};
        final familiaData = data["familia"] ?? [];

        setState(() {
          familiares = (familiaData as List<dynamic>)
              .map<Map<String, String>>((f) {
            final Map<String, dynamic> item = f as Map<String, dynamic>;
            return {
              "nombre": item["nombre"]?.toString() ?? "",
              "tipo_relacion": item["tipo_relacion"]?.toString() ?? "Otro",
              "descripcion": item["descripcion"]?.toString() ?? "",
            };
          }).toList();
          _showConfirmation = true;
        });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Información familiar completada con IA ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error del servidor: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error procesando con IA: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Barra superior ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.grey.shade800,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      'Información Familiar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Icono central ---
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.orange.shade700,
                      size: 55,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Sección IA ---
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
                        'Pulsa para grabar o escribe un resumen sobre tus familiares para completar los campos de abajo.',
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
                              onPressed:
                                  _isListening ? _stopListening : _startListening,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isListening
                                    ? Colors.redAccent
                                    : Colors.orange.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                              ),
                              child: Icon(
                                _isListening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
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
                                hintText:
                                    'O escribe aquí tu información familiar...',
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
                          backgroundColor: Colors.orange.shade700,
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

                // --- Divider ---
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'O rellena manualmente',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Lista de familiares ---
                Column(
                  children: familiares.map((familiar) {
                    final index = familiares.indexOf(familiar);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              // Nombre
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Nombre del familiar',
                                    border: InputBorder.none,
                                  ),
                                  controller: TextEditingController(
                                      text: familiar['nombre']),
                                  onChanged: (value) =>
                                      familiares[index]['nombre'] = value,
                                ),
                              ),
                              // Tipo de relación
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: familiares[index]['tipo_relacion'] ??
                                      parentescos.first,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  items: parentescos.map((p) {
                                    return DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() =>
                                      familiares[index]['tipo_relacion'] =
                                          value!),
                                ),
                              ),
                              // Botón eliminar
                              IconButton(
                                onPressed: () => _eliminarFamiliar(index),
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red.shade400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Descripción
                          TextField(
                            controller: TextEditingController(
                                text: familiar['descripcion']),
                            decoration: const InputDecoration(
                              hintText:
                                  'Descripción (Ej: vive conmigo, me ayuda en terapias...)',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) =>
                                familiares[index]['descripcion'] = value,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // --- Botón agregar familiar ---
                OutlinedButton.icon(
                  onPressed: _agregarFamiliar,
                  icon: Icon(Icons.add, color: Colors.orange.shade700),
                  label: Text(
                    'Agregar Familiar',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Botones inferiores ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Atrás',
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
                        onPressed: () {
                          registerVM.updateFamilia(familiares: familiares);
                          Navigator.pushNamed(context, '/register-routine');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Siguiente',
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
      ),
    );
  }
}
