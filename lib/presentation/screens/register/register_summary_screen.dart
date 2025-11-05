import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aphasia_mobile/presentation/screens/register/register_viewmodel.dart';
import 'package:aphasia_mobile/data/services/api_service.dart';

class RegisterSummaryScreen extends StatefulWidget {
  const RegisterSummaryScreen({super.key});

  @override
  State<RegisterSummaryScreen> createState() => _RegisterSummaryScreenState();
}

class _RegisterSummaryScreenState extends State<RegisterSummaryScreen> {
  bool _isLoading = false;
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    final data = registerVM.buildProfileData();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Revisar información"),
        backgroundColor: Colors.orange.shade700,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Por favor verifica que tus datos estén correctos antes de finalizar el registro:",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // --- Secciones visuales ---
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                      title: "🧍 Datos personales",
                      children: [
                        _buildRow("Nombre", data["nombre"]),
                        _buildRow("Fecha de nacimiento", data["fecha_nacimiento"]),
                        _buildRow("Lugar de nacimiento", data["lugar_nacimiento"]),
                        _buildRow("Ciudad de residencia", data["ciudad_residencia"]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if ((data["familia"] as List).isNotEmpty)
                      _buildSection(
                        title: "👨‍👩‍👧‍👦 Familia",
                        children: (data["familia"] as List).map<Widget>((f) {
                          return _buildCardItem(
                            title: f["nombre"] ?? "",
                            subtitle: f["tipo_relacion"] ?? "",
                            description: f["descripcion"] ?? "",
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),

                    if ((data["rutinas"] as List).isNotEmpty)
                      _buildSection(
                        title: "⏰ Rutinas",
                        children: (data["rutinas"] as List).map<Widget>((r) {
                          return _buildCardItem(
                            title: r["titulo"] ?? "",
                            description: r["descripcion"] ?? "",
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),

                    if ((data["objetos"] as List).isNotEmpty)
                      _buildSection(
                        title: "🪄 Objetos importantes",
                        children: (data["objetos"] as List).map<Widget>((o) {
                          return _buildCardItem(
                            title: o["nombre"] ?? "",
                            subtitle: o["tipo_relacion"] ?? "",
                            description: o["descripcion"] ?? "",
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  setState(() => _isLoading = true);

                  try {
                    // 1️⃣ Crear usuario en FirebaseAuth
                    final userCredential =
                    await auth.createUserWithEmailAndPassword(
                      email: registerVM.email.trim(),
                      password: registerVM.password.trim(),
                    );
                    final user = userCredential.user!;
                    registerVM.setUserId(user.uid);

                    // 2️⃣ Guardar paciente en Firestore
                    data.remove("password");
                    data["uid"] = user.uid;
                    await firestore
                        .collection("pacientes")
                        .doc(user.uid)
                        .set(data);

                    debugPrint("✅ Paciente registrado en Firestore");

                    // 3️⃣ Crear ejercicios SR en backend
                    try {
                      final response = await apiService.post(
                        "/spaced-retrieval/",
                        {"user_id": user.uid, "profile": data},
                      );
                      if (response.statusCode == 200) {
                        debugPrint("✅ SR cards creadas correctamente");
                      } else {
                        debugPrint(
                            "⚠️ Backend respondió con ${response.statusCode}");
                      }
                    } catch (e) {
                      debugPrint("❌ Error al crear SR: $e");
                    }

                    // 4️⃣ Redirigir a pantalla de éxito
                    if (mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/register-main-success',
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
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
                  "Finalizar registro",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets auxiliares visuales ---
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value ?? "-", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCardItem(
      {required String title, String? subtitle, String? description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
          if (subtitle != null && subtitle.isNotEmpty)
            Text(subtitle,
                style: const TextStyle(color: Colors.orange, fontSize: 14)),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
