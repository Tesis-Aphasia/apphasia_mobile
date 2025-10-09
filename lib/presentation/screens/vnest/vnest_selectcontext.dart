import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../data/services/api_service.dart';

class VnestSelectContextScreen extends StatefulWidget {
  const VnestSelectContextScreen({super.key});

  @override
  State<VnestSelectContextScreen> createState() => _VnestSelectContextScreenState();
}

class _VnestSelectContextScreenState extends State<VnestSelectContextScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  final ApiService apiService = ApiService();

  String? selectedContext;
  String customContext = "";
  bool loading = false;
  String? error;

  Future<void> sendRequest(String contextText) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await apiService.post(
        '/context/',
        {"context": contextText, "nivel": "facil"},
      );

      // ✅ Si la respuesta fue exitosa
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(response.data);

        Navigator.pushNamed(
          context,
          '/vnest-action',
          arguments: {
            ...data,
            'context': contextText, // ✅ ya no causa conflicto
          },
        );
      }
      else {
        throw Exception("Error HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Manejo más robusto de errores
      setState(() {
        if (e.response != null) {
          error = "Error ${e.response?.statusCode}: ${e.response?.data}";
        } else {
          error = "Error de conexión: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void handleNext() {
    final selected = selectedContext == "custom" ? customContext.trim() : selectedContext;
    if (selected == null || selected.isEmpty) return;
    sendRequest(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Selecciona un contexto",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: loading
              ? _buildLoading()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error != null) _buildError(),
              Expanded(
                child: ListView(
                  children: [
                    _buildOption(
                      id: "Ir a la tienda",
                      icon: Icons.local_grocery_store_rounded,
                      title: "Ir a la tienda",
                    ),
                    _buildOption(
                      id: "Cita médica",
                      icon: Icons.local_hospital_rounded,
                      title: "Cita médica",
                    ),
                    _buildOption(
                      id: "Reunión familiar",
                      icon: Icons.family_restroom_rounded,
                      title: "Reunión familiar",
                    ),
                    _buildCustomOption(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: orange, strokeWidth: 4),
        const SizedBox(height: 20),
        const Text(
          "Creando el ejercicio…",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Esto puede tardar unos segundos",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _buildError() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error ?? "Error enviando el contexto",
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: handleNext,
          child: const Text("Reintentar"),
        ),
      ],
    ),
  );

  Widget _buildOption({
    required String id,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedContext == id;

    return InkWell(
      onTap: () => setState(() => selectedContext = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? orange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? orange : Colors.grey.shade300,
            width: 2,
          ),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? orange : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomOption() {
    final isSelected = selectedContext == "custom";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? orange.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? orange : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, color: orange),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onTap: () => setState(() => selectedContext = "custom"),
              onChanged: (value) => setState(() => customContext = value),
              decoration: const InputDecoration(
                hintText: "Escribe tu propio contexto...",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = (selectedContext == "custom" && customContext.trim().isNotEmpty) ||
        (selectedContext != null && selectedContext != "custom");

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled && !loading ? handleNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: orange.withOpacity(0.4),
        ),
        child: Text(
          loading ? "Generando…" : "Siguiente",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
