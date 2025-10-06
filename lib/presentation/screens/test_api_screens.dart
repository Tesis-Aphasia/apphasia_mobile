import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final ApiService _api = ApiService();
  String responseText = '';

  Future<void> sendContext() async {
    try {
      final data = {"context": "comer", "nivel": "facil"};
      final response = await _api.post('/context/', data);
      setState(() => responseText = response.data.toString());
    } catch (e) {
      setState(() => responseText = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test API")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: sendContext, child: const Text("Enviar contexto")),
            const SizedBox(height: 20),
            Text(responseText),
          ],
        ),
      ),
    );
  }
}
