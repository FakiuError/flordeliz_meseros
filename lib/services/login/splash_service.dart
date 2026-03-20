import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplashService {
  final String baseUrl = 'http://200.7.100.146/api-restaurante_flor_de_liz/meseros';

  Future<Map<String, dynamic>?> getSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('idUsuario');
    final nombreUsuario = prefs.getString('nombreUsuario');

    if (idUsuario == null || nombreUsuario == null) {
      return null;
    }

    return {
      "idUsuario": idUsuario,
      "nombreUsuario": nombreUsuario,
    };
  }

  Future<Map<String, dynamic>> verificarUsuario(int idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verificar_usuario.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_usuario": idUsuario}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {"success": false, "message": "Error del servidor"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}