import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../register/register_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Encabezado ---
                  const Text(
                    '¡Hola de nuevo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tu identificador para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Campo de identificador ---
                  TextField(
                    controller: _idCtrl,
                    decoration: InputDecoration(
                      labelText: 'Identificador',
                      hintText: 'Escribe tu identificador',
                      filled: true,
                      fillColor: Colors.orange.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Botón de iniciar sesión ---
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final userId = _idCtrl.text.trim();
                            if (userId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Por favor ingresa tu identificador')),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);
                            registerVM.userId = userId;

                            // CAMBIAR CUANDO CONECTE CON FIRESTORE
                            // En este punto podrías validar en Firestore si existe el paciente
                            // Por ahora, simplemente navega al menú principal
                            await Future.delayed(const Duration(seconds: 1));

                            setState(() => _isLoading = false);
                            Navigator.pushReplacementNamed(context, '/menu');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // --- Texto secundario ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register-main');
                        },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
      ),
    );
  }
}
