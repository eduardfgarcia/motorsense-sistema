import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _loginUrl = 'http://127.0.0.1:8000/api/token/';

  // Retorna el mapa completo de la respuesta o lanza una excepción
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(
          response.body); // Devuelve {'access': '...', 'refresh': '...'}
    } else {
      throw Exception('Fallo en autenticación: ${response.statusCode}');
    }
  }
}
