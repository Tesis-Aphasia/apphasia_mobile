import 'package:flutter/material.dart';
import '../presentation/screens/register/register_main_screen.dart';
import '../presentation/screens/register/register_personal_screen.dart';
import '../presentation/screens/register/register_family_screen.dart';
import '../presentation/screens/register/register_routine_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // --- Registro ---
      case '/register-main':
        return MaterialPageRoute(builder: (_) => const RegisterMainScreen());

      case '/register-personal':
        return MaterialPageRoute(builder: (_) => const RegisterPersonalScreen());

      case '/register-family':
        return MaterialPageRoute(builder: (_) => const RegisterFamilyScreen());

      case '/register-routine':
        return MaterialPageRoute(builder: (_) => const RegisterRoutineScreen());

      case '/register-main-success':
        return MaterialPageRoute(
          builder: (_) => const RegisterMainScreen(showSuccess: true),
        );

      // --- Fallback (ruta no encontrada) ---
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
    }
  }
}