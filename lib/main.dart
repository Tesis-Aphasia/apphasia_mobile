import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_router.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/register/register_viewmodel.dart';

void main() { 
  runApp(
      ChangeNotifierProvider(
        create: (_) => RegisterViewModel(),
        child: const AphasiaApp(),
      ),
  );
}

class AphasiaApp extends StatelessWidget {
  const AphasiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aphasia Therapy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/register-main',
    );
  }
}
