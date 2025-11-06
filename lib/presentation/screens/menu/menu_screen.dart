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
      final completed = snap.docs
          .where((d) => d['estado'] == 'completado')
          .toList();

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

  // =========================
  // --- Páginas principales ---
  // =========================
  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    _pages.clear();
    _pages.addAll([
      _buildHome(),
      _buildTherapies(),
      _buildPersonalize(),
      _buildProfile(),
    ]);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: "Terapias"),
          BottomNavigationBarItem(icon: Icon(Icons.build_rounded), label: "Personalizar"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Perfil"),
        ],
      ),
    );
  }

  // =========================
  // 🏠 Página: Inicio
  // =========================
  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            "¡Hola!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            "¡Sigue practicando, lo estás haciendo genial!",
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Ejercicios completados",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: completedCount > 0 ? 1.0 : 0.0,
                        color: orange,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    Text(
                      completedCount.toString(),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Última terapia: $lastExercise",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/vnest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text(
                    "Continuar práctica",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Tarjetas inferiores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallCard(
                icon: Icons.psychology_alt_rounded,
                title: "Explorar Terapias",
                subtitle: "Encuentra nuevos ejercicios",
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _smallCard(
                icon: Icons.build_rounded,
                title: "Personaliza tus ejercicios",
                subtitle: "Crea tus propios desafíos",
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _smallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: orange, size: 30),
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 🎯 Página: Terapias
  // =========================
  Widget _buildTherapies() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Seleccionar Terapia",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Card 1: Terapia VNeST ---
            _therapyCardModern(
              icon: Icons.hub_rounded,
              title: "Terapia VNeST",
              description:
                  "Este método se enfoca en conectar verbos con sujetos y objetos para mejorar la formación de oraciones.",
              buttonText: "Comenzar VNeST",
              onTap: () => Navigator.pushNamed(context, '/vnest'),
            ),
            const SizedBox(height: 20),

            // --- Card 2: Recuperación Espaciada ---
            _therapyCardModern(
              icon: Icons.access_time_rounded,
              title: "Recuperación Espaciada",
              description:
                  "Este método se enfoca en la memorización de información importante a través de la repetición en intervalos crecientes.",
              buttonText: "Comenzar Recuperación Espaciada",
              onTap: () => Navigator.pushNamed(context, '/sr'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _therapyCardModern({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final orange = const Color(0xFFFF8A00);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                child: Icon(icon, color: Colors.blue.shade400, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
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
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // =========================
  // 🧩 Página: Personalizar
  // =========================
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


  // =========================
  // 👤 Página: Perfil
  // =========================
  Widget _buildProfile() {
    return Center(
      child: Text(
        "Perfil del usuario próximamente",
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
