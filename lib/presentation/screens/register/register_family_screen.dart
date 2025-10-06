import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_viewmodel.dart';

class RegisterFamilyScreen extends StatefulWidget {
  const RegisterFamilyScreen({super.key});

  @override
  State<RegisterFamilyScreen> createState() => _RegisterFamilyScreenState();
}

class _RegisterFamilyScreenState extends State<RegisterFamilyScreen> {
  final TextEditingController _parejaCtrl = TextEditingController();

  // Lista dinámica de familiares
  List<Map<String, String>> familiares = [];

  final List<String> parentescos = [
    'Cónyuge/Pareja',
    'Hijo/a',
    'Padre/Madre',
    'Hermano/a',
    'Otro',
  ];

  void _agregarFamiliar() {
    setState(() {
      familiares.add({'nombre': '', 'parentesco': parentescos.first});
    });
  }

  void _eliminarFamiliar(int index) {
    setState(() {
      familiares.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final registerVM = Provider.of<RegisterViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Encabezado superior ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.grey.shade800,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.orange.shade700,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 40), // Espaciador
                ],
              ),
              const SizedBox(height: 16),

              // --- Título ---
              const Center(
                child: Text(
                  'Información Familiar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Cuéntanos sobre tu círculo familiar.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Campo pareja opcional ---
              TextField(
                controller: _parejaCtrl,
                decoration: InputDecoration(
                  labelText: 'Cónyuge / Pareja (opcional)',
                  filled: true,
                  fillColor: Colors.orange.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Lista dinámica de familiares ---
              Expanded(
                child: ListView.builder(
                  itemCount: familiares.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Nombre
                          Expanded(
                            flex: 2,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Nombre del familiar',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                familiares[index]['nombre'] = value;
                              },
                            ),
                          ),

                          // Parentesco
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: familiares[index]['parentesco'],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              items: parentescos.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Text(p),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  familiares[index]['parentesco'] = value!;
                                });
                              },
                            ),
                          ),

                          // Botón eliminar
                          IconButton(
                            onPressed: () => _eliminarFamiliar(index),
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- Botón agregar familiar ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _agregarFamiliar,
                  icon: Icon(Icons.add, color: Colors.orange.shade700),
                  label: Text(
                    'Agregar Familiar',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Botones inferiores ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Atrás',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Guardar en el ViewModel
                        registerVM.updateFamilia(
                          hijos: familiares
                              .where((f) => f['nombre']?.isNotEmpty ?? false)
                              .map((f) => f['nombre']!)
                              .toList(),
                          pareja: _parejaCtrl.text,
                        );

                        Navigator.pushNamed(context, '/register-routine');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Siguiente',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
