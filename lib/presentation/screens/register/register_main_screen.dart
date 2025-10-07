import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_viewmodel.dart';

class RegisterMainScreen extends StatefulWidget {
  final bool showSuccess;
  const RegisterMainScreen({super.key, this.showSuccess = false});

  @override
  State<RegisterMainScreen> createState() => _RegisterMainScreenState();
}

class _RegisterMainScreenState extends State<RegisterMainScreen> {
  final TextEditingController _idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Logo Rehabilita ---
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                child: Center(
                  child: Text(
                    '🧠 Rehabilita',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 26,
                      color: Colors.orange.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: widget.showSuccess
                    ? _buildSuccessContent(context)
                    : _buildIntroContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  //             INICIO DE REGISTRO CON ID PACIENTE
  // ===========================================================
  Widget _buildIntroContent(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Registro de paciente',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Completa la información con ayuda de tu cuidador si lo necesitas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 40),

        // --- Campo de Identificador ---
        TextField(
          controller: _idCtrl,
          decoration: InputDecoration(
            labelText: 'Identificador de paciente',
            hintText: 'Ejemplo: paciente001',
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Botón principal ---
        ElevatedButton(
          onPressed: () {
            if (_idCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor ingresa un identificador.')),
              );
              return;
            }

            // Guardar ID en el ViewModel
            registerVM.userId = _idCtrl.text.trim();

            // Ir a pantalla de datos personales
            Navigator.pushNamed(context, '/register-personal');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Comenzar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),
        // --- Botón secundario ---
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar / Volver',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  //               CONFIRMACIÓN DE REGISTRO EXITOSO
  // ===========================================================
  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícono circular
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: Colors.orange.shade700,
            size: 60,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Registro completado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu cuenta ha sido creada con éxito.\nYa puedes comenzar tus ejercicios.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),

        // --- Botón principal ---
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Ir a ejercicios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- Botón secundario ---
        OutlinedButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/landing'));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.orange.shade50,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Volver al inicio',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
