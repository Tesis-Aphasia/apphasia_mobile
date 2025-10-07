import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFFEF9F4); // beige suave de fondo
    final orange = const Color(0xFFFF8A00); // naranja principal

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Encabezado ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿Qué te gustaría practicar hoy?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.account_circle_outlined,
                      color: orange,
                      size: 32,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- Opción 1: Terapia de Verbos ---
              _buildCard(
                icon: Icons.record_voice_over_rounded,
                title: 'Terapia de Verbos',
                subtitle: 'Practica con VNeST',
                orange: orange,
                onTap: () => Navigator.pushNamed(context, '/vnest'),
              ),

              const SizedBox(height: 20),

              // --- Opción 2: Terapia de Memoria ---
              _buildCard(
                icon: Icons.psychology_alt_rounded,
                title: 'Terapia de Memoria',
                subtitle: 'Practica con Spaced Retrieval',
                orange: orange,
                onTap: () => Navigator.pushNamed(context, '/sr'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color orange,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono circular
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: orange, size: 28),
            ),
            const SizedBox(width: 18),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Flecha
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
