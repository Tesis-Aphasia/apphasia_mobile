import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/api_service.dart';
import '../register/register_viewmodel.dart';

class RegisterRoutineScreen extends StatefulWidget {
  const RegisterRoutineScreen({super.key});

  @override
  State<RegisterRoutineScreen> createState() => _RegisterRoutineScreenState();
}

class _RegisterRoutineScreenState extends State<RegisterRoutineScreen> {
  final TextEditingController _comidaCtrl = TextEditingController();
  final TextEditingController _actividadCtrl = TextEditingController();
  final TextEditingController _mascotaCtrl = TextEditingController();

  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_outline_rounded,
                      color: Colors.orange.shade700, size: 42),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Cuéntanos un poco más sobre ti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInputField(
                          controller: _comidaCtrl,
                          label: 'Comida favorita',
                          placeholder: 'Escribe tu comida favorita'),
                      _buildInputField(
                          controller: _actividadCtrl,
                          label: 'Actividad favorita',
                          placeholder: 'Escribe tu actividad favorita'),
                      _buildInputField(
                          controller: _mascotaCtrl,
                          label: 'Nombre de tu mascota',
                          placeholder: 'Escribe el nombre de tu mascota'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Atrás',
                        style: TextStyle(
                          color: Colors.orange.shade800,
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

                        // 1️⃣ Construir perfil
                        final profileData = {
                          "personal": {
                            "nombre": registerVM.nombre,
                            "fecha_nacimiento": registerVM.fechaNacimiento,
                            "lugar_nacimiento": registerVM.lugarNacimiento,
                            "direccion": registerVM.direccion,
                          },
                          "familia": {
                            "hijos": registerVM.hijos,
                            "pareja": registerVM.pareja,
                          },
                          "rutinas": {
                            "comida_favorita": _comidaCtrl.text.trim(),
                            "actividad_favorita":
                            _actividadCtrl.text.trim(),
                          },
                          "objetos": {
                            "mascota": {
                              "nombre": _mascotaCtrl.text.trim(),
                            },
                          },
                        };

                        // 2️⃣ Guardar paciente en Firestore
                        await FirebaseFirestore.instance
                            .collection("patients")
                            .doc(registerVM.userId)
                            .set({
                          "user_id": registerVM.userId,
                          "created_at":
                          DateTime.now().millisecondsSinceEpoch,
                          ...profileData,
                        });

                        // 3️⃣ Llamar al backend (para generar tarjetas SR)
                        try {
                          final response = await apiService.post(
                            "/spaced-retrieval/",
                            {
                              "user_id": registerVM.userId,
                              "profile": profileData,
                            },
                          );

                          if (response.statusCode == 200) {
                            debugPrint("✅ SR cards creadas correctamente");
                          } else {
                            debugPrint(
                                "⚠️ Backend respondió con ${response.statusCode}");
                          }
                        } catch (e) {
                          debugPrint("❌ Error al llamar al backend: $e");
                        }

                        // 4️⃣ Continuar al éxito
                        if (mounted) {
                          setState(() => _isLoading = false);
                          Navigator.pushReplacementNamed(
                              context, '/register-main-success');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text(
                        'Finalizar registro',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.orange.shade300),
          filled: true,
          fillColor: Colors.orange.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
