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
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _showPassword = false;

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
  //              REGISTRO CON EMAIL Y CONTRASEÑA
  // ===========================================================
  Widget _buildIntroContent(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
          'Completa tu correo y contraseña para continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 40),

        // --- Campo de correo ---
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'ejemplo@correo.com',
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // --- Campo de contraseña ---
        TextField(
          controller: _passwordCtrl,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Mínimo 6 caracteres',
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.orange.shade700,
              ),
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Botón principal ---
        ElevatedButton(
          onPressed: () {
            final email = _emailCtrl.text.trim();
            final password = _passwordCtrl.text.trim();

            if (email.isEmpty || !emailRegex.hasMatch(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor ingresa un correo válido.')),
              );
              return;
            }
            if (password.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres.')),
              );
              return;
            }

            // ✅ Guardar datos en el ViewModel
            registerVM.setAuthData(email: email, password: password);

            // Ir a la pantalla de datos personales
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
            'Continuar',
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
            'Cancelar',
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
      ],
    );
  }
}
