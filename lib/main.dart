import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'presentation/screens/register/register_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const RehabilitaApp(),
    ),
  );
}

class RehabilitaApp extends StatelessWidget {
  const RehabilitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehabilita',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (por compatibilidad)
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        fontFamily: 'Poppins',
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/landing',
    );
  }
}
