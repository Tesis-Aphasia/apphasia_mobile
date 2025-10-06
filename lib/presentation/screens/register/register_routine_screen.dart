import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_viewmodel.dart';

class RegisterRoutineScreen extends StatefulWidget {
  const RegisterRoutineScreen({super.key});

  @override
  State<RegisterRoutineScreen> createState() => _RegisterRoutineScreenState();
}

class _RegisterRoutineScreenState extends State<RegisterRoutineScreen> {
  final TextEditingController _comidaCtrl = TextEditingController();
  final TextEditingController _actividadCtrl = TextEditingController();
  final TextEditingController _mascotaCtrl = TextEditingController();

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
              // --- Ícono superior ---
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_outline_rounded,
                    color: Colors.orange.shade700,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Título y subtítulo ---
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
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Esto nos ayudará a personalizar tu experiencia.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // --- Formulario ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _comidaCtrl,
                        label: 'Comida favorita',
                        placeholder: 'Escribe tu comida favorita',
                      ),
                      _buildInputField(
                        controller: _actividadCtrl,
                        label: 'Actividad favorita',
                        placeholder: 'Escribe tu actividad favorita',
                      ),
                      _buildInputField(
                        controller: _mascotaCtrl,
                        label: 'Nombre de tu mascota',
                        placeholder: 'Escribe el nombre de tu mascota',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Botones inferiores ---
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
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      onPressed: () async {
                        // Guardar datos en el ViewModel
                        registerVM.updateRutinas(
                          comidaFavorita: _comidaCtrl.text,
                          actividadFavorita: _actividadCtrl.text,
                          mascota: _mascotaCtrl.text,
                        );

                        // Navegar a la pantalla de éxito o guardar en Firebase
                        Navigator.pushReplacementNamed(
                            context, '/register-main-success');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Finalizar registro',
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

  // --- Widget auxiliar para campos de texto ---
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
