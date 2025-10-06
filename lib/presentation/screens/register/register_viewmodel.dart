import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel extends ChangeNotifier {
  // --- Control general del flujo ---
  bool isSaving = false;
  String? userId; // se define cuando el paciente elige o se registra con un ID

  // --- Datos personales ---
  String nombre = '';
  String fechaNacimiento = '';
  String lugarNacimiento = '';
  String direccion = '';

  // --- Familia ---
  List<String> hijos = [];
  String pareja = '';

  // --- Rutinas ---
  String comidaFavorita = '';
  String actividadFavorita = '';
  String mascota = '';

  // =====================================================
  //                 MÉTODOS DE ACTUALIZACIÓN
  // =====================================================

  void updatePersonal({
    required String nombre,
    required String fechaNacimiento,
    required String lugarNacimiento,
    required String direccion,
  }) {
    this.nombre = nombre;
    this.fechaNacimiento = fechaNacimiento;
    this.lugarNacimiento = lugarNacimiento;
    this.direccion = direccion;
    notifyListeners();
  }

  void updateFamilia({
    required List<String> hijos,
    required String pareja,
  }) {
    this.hijos = hijos;
    this.pareja = pareja;
    notifyListeners();
  }

  void updateRutinas({
    required String comidaFavorita,
    required String actividadFavorita,
    required String mascota,
  }) {
    this.comidaFavorita = comidaFavorita;
    this.actividadFavorita = actividadFavorita;
    this.mascota = mascota;
    notifyListeners();
  }

  // =====================================================
  //                    ESTRUCTURA JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      "personal": {
        "nombre": nombre,
        "fecha_nacimiento": fechaNacimiento,
        "lugar_nacimiento": lugarNacimiento,
        "direccion": direccion,
      },
      "familia": {
        "hijos": hijos,
        "pareja": pareja,
      },
      "rutinas": {
        "comida_favorita": comidaFavorita,
        "actividad_favorita": actividadFavorita,
      },
      "objetos": {
        "mascota": {"nombre": mascota},
      },
    };
  }

  // =====================================================
  //                  GUARDAR EN FIREBASE
  // =====================================================

  Future<void> saveToFirebase() async {
    if (userId == null || userId!.isEmpty) {
      throw Exception("userId no definido");
    }

    isSaving = true;
    notifyListeners();

    try {
      final profileData = toJson();

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .set(profileData);

      debugPrint("✅ Perfil de paciente guardado con éxito en Firebase.");
    } catch (e) {
      debugPrint("❌ Error al guardar paciente: $e");
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // =====================================================
  //                    REINICIAR ESTADO
  // =====================================================

  void reset() {
    nombre = '';
    fechaNacimiento = '';
    lugarNacimiento = '';
    direccion = '';
    hijos = [];
    pareja = '';
    comidaFavorita = '';
    actividadFavorita = '';
    mascota = '';
    userId = null;
    isSaving = false;
    notifyListeners();
  }
}
