import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/register/register_viewmodel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  // Ahora la primera pestaña es TERAPIAS
  int _currentIndex = 0;
  int completedCount = 0;
  String lastExercise = "-";

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final userId = registerVM.userId;

    try {
      final ref = FirebaseFirestore.instance
          .collection('pacientes')
          .doc(userId)
          .collection('ejercicios_asignados');

      final snap = await ref.get();
      final completed =
          snap.docs.where((d) => d['estado'] == 'completado').toList();

      setState(() {
        completedCount = completed.length;
        if (completed.isNotEmpty) {
          final last = completed.last.data();
          lastExercise = last['contexto'] ?? '-';
        }
      });
    } catch (e) {
      debugPrint("Error al cargar progreso: $e");
    }
  }

  // ====================================
  //            PÁGINAS
  // ====================================
  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _pages.clear();
    _pages.addAll([
      _buildTherapies(),
      _buildPersonalize(),
      _buildProfile(),
    ]);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: orange.withOpacity(0.15),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.psychology_rounded), label: "Terapias"),
          NavigationDestination(
              icon: Icon(Icons.build_rounded), label: "Personalizar"),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: "Perfil"),
        ],
      ),
    );
  }

  // ====================================
  //        HEADER REUSABLE
  // ====================================
  Widget _header(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ====================================
  //              TERAPIAS
  //  (Pantalla principal)
  // ====================================
  Widget _buildTherapies() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header("¡Bienvenido!",
                "Selecciona la terapia con la que quieres practicar hoy"),
            _therapyCard(
              title: "Terapia VNeST",
              description:
                  "Genera oraciones conectando sujeto, verbo y objeto para fortalecer la producción del lenguaje.",
              icon: Icons.hub_rounded,
              onTap: () => Navigator.pushNamed(context, '/vnest'),
            ),
            const SizedBox(height: 20),
            _therapyCard(
              title: "Recuperación Espaciada",
              description:
                  "Practica información importante en intervalos crecientes para fortalecer la memoria.",
              icon: Icons.access_time_rounded,
              onTap: () => Navigator.pushNamed(context, '/sr'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _therapyCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.blue.shade400, size: 30),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Comenzar",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  //         PERSONALIZAR
  // ====================================
Widget _buildPersonalize() {
    final orange = const Color(0xFFFF8A00);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Personaliza tu Práctica",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 40),
          ),
          const SizedBox(height: 30),
          const Text(
            "Crea ejercicios a tu medida",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "¡Queremos motivarte a que practiques más! La mejor manera de hacerlo es creando ejercicios a tu medida.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/personalize-exercises'),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Empezar a Personalizar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ====================================
  //         TARJETA DE PROGRESO
  // (se usa en Perfil)
  // ====================================
  Widget _progressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Progreso de ejercicios",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: completedCount > 0 ? 1.0 : 0.0,
                  color: orange,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              Text(
                completedCount.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Última terapia: $lastExercise",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  //              PERFIL
  // ====================================
  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Mi Perfil", "Tu progreso y configuración personal"),
          _progressCard(),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Más opciones de perfil próximamente",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
