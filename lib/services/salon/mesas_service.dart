import 'dart:convert';
import 'package:http/http.dart' as http;

class MesasService {
  final String baseUrl = 'http://200.7.100.146/api-restaurante_flor_de_liz/meseros';

  Future<Map<String, dynamic>> obtenerMesas() async {
    try {
      final response =
      await http.get(Uri.parse('$baseUrl/get_mesas_estado.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final mesas = data
            .where((m) =>
        int.tryParse(m['es_domicilio'].toString()) == 0)
            .toList();

        final domicilios = data
            .where((m) =>
        int.tryParse(m['es_domicilio'].toString()) == 1 &&
            [2, 3].contains(
                int.tryParse(m['estado_pedido'].toString())))
            .toList();

        return {
          "success": true,
          "mesas": mesas,
          "domicilios": domicilios,
        };
      } else {
        return {"success": false};
      }
    } catch (e) {
      return {"success": false};
    }
  }

  Future<Map<String, dynamic>> crearDomicilio({
    required String direccion,
    required int idEmpleado,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/crear_domicilio_y_pedido.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "direccion": direccion,
          "id_empleado": idEmpleado,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": "Error servidor"};
      }
    } catch (e) {
      return {"success": false, "message": "Error conexión"};
    }
  }
}