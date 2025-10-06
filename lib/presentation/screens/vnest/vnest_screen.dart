import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class VNeSTScreen extends StatefulWidget {
  const VNeSTScreen({super.key});

  @override
  State<VNeSTScreen> createState() => _VNeSTScreenState();
}

class _VNeSTScreenState extends State<VNeSTScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  String result = '';
  bool loading = false;

  Future<void> generateExercise() async {
    setState(() => loading = true);
    try {
      final response = await _api.post('/context/', {
        "context": _controller.text,
        "nivel": "facil"
      });
      setState(() => result = response.data.toString());
    } catch (e) {
      setState(() => result = 'Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VNeST Therapy")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Escribe un verbo o tema'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: generateExercise,
              child: const Text('Generar ejercicio'),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(result, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
