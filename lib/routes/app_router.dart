import 'package:flutter/material.dart';
import '../presentation/screens/register/register_main_screen.dart';
import '../presentation/screens/register/register_personal_screen.dart';
import '../presentation/screens/register/register_family_screen.dart';
import '../presentation/screens/register/register_routine_screen.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/menu/menu_screen.dart';
import '../presentation/screens/landing/landing_screen.dart';
import '../presentation/screens/sr/sr_exersices.dart';
import '../presentation/screens/vnest/vnest_conclusion.dart';
import '../presentation/screens/vnest/vnest_selectcontext.dart';
import '../presentation/screens/vnest/vnest_actionselection.dart';
import '../presentation/screens/vnest/vnest_sentenceevaluation.dart';
import '../presentation/screens/vnest/vnest_sentenceexpansion.dart'; // 👈 importar la nueva pantalla

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // --- Landing ---
      case '/landing':
        return MaterialPageRoute(builder: (_) => const LandingScreen());

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

    // --- Login y Menú ---
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/menu':
        return MaterialPageRoute(builder: (_) => const MenuScreen());

    // --- VNEST Fase 0: Selección de contexto ---
      case '/vnest':
        return MaterialPageRoute(builder: (_) => const VnestSelectContextScreen());

    // --- VNEST Fase 1: Selección de acción (¿quién? y ¿qué?) ---
      case '/vnest-action':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _errorRoute("FaltaRn los datos del ejercicio (args nulos)");
        }
        return MaterialPageRoute(
          builder: (_) => VnestActionSelectionScreen(exercise: args),
        );
    // --- VNEST Fase 2: Expansión de Oración) ---
      case '/vnest-phase2':
        final args = Map<String, dynamic>.from(settings.arguments as Map);
        return MaterialPageRoute(
          builder: (_) => VnestSentenceExpansionScreen(data: args),
        );

      case '/vnest-phase3':
        final args = Map<String, dynamic>.from(settings.arguments as Map);
        return MaterialPageRoute(
          builder: (_) => VnestSentenceEvaluationScreen(exercise: args),
        );

      case '/vnest-phase4':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VnestConclusionScreen(exercise: args),
        );

      case '/sr':
        return MaterialPageRoute(builder: (_) => const SRExercisesScreen());





    // --- Fallback (ruta no encontrada) ---
      default:
        return _errorRoute('Página no encontrada: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.redAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
