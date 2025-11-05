import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  // --- Usuario / Autenticación ---
  String userId = '';
  String userEmail = '';
  String email = '';
  String password = '';

  // --- Datos personales ---
  String nombre = '';
  String fechaNacimiento = '';
  String lugarNacimiento = '';
  String ciudadResidencia = '';

  // --- Familia ---
  List<Map<String, String>> familiares = [];

  // --- Rutinas ---
  List<Map<String, String>> rutinas = [];

  // --- Objetos ---
  List<Map<String, String>> objetos = [];

  // =============================================================
  // ==================== MÉTODOS DE ACTUALIZACIÓN ===============
  // =============================================================

  void setAuthData({required String email, required String password}) {
    this.email = email.trim();
    this.password = password.trim();
    userEmail = email.trim(); // mantener consistencia con otros usos
    notifyListeners();
  }

  void updatePersonal({
    required String nombre,
    required String fechaNacimiento,
    required String lugarNacimiento,
    required String ciudadResidencia,
  }) {
    this.nombre = nombre.trim();
    this.fechaNacimiento = fechaNacimiento.trim();
    this.lugarNacimiento = lugarNacimiento.trim();
    this.ciudadResidencia = ciudadResidencia.trim();
    notifyListeners();
  }

  void updateFamilia({
    required List<Map<String, String>> familiares,
  }) {
    this.familiares = familiares;
    notifyListeners();
  }

  void updateRutinas({
    required List<Map<String, String>> rutinas,
  }) {
    this.rutinas = rutinas;
    notifyListeners();
  }

  void updateObjetos({
    required List<Map<String, String>> objetos,
  }) {
    this.objetos = objetos;
    notifyListeners();
  }

  void reset() {
    email = '';
    password = '';
    userEmail = '';
    nombre = '';
    fechaNacimiento = '';
    lugarNacimiento = '';
    ciudadResidencia = '';
    familiares = [];
    rutinas = [];
    objetos = [];
    notifyListeners();
  }

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }


  // =============================================================
  // ===================== CONSTRUCCIÓN PERFIL ===================
  // =============================================================

  Map<String, dynamic> buildProfileData() {
    return {
      "email": email,
      "password": password,
      "nombre": nombre,
      "fecha_nacimiento": fechaNacimiento,
      "lugar_nacimiento": lugarNacimiento,
      "ciudad_residencia": ciudadResidencia,
      "familia": familiares.map((f) {
        return {
          "nombre": f["nombre"] ?? "",
          "tipo_relacion": f["tipo_relacion"] ?? "",
          "descripcion": f["descripcion"] ?? "",
        };
      }).toList(),
      "rutinas": rutinas.map((r) {
        return {
          "titulo": r["titulo"] ?? "",
          "descripcion": r["descripcion"] ?? "",
        };
      }).toList(),
      "objetos": objetos.map((o) {
        return {
          "nombre": o["nombre"] ?? "",
          "descripcion": o["descripcion"] ?? "",
          "tipo_relacion": o["tipo_relacion"] ?? "",
        };
      }).toList(),
    };
  }
}
