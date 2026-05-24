import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // Variable nombre de usuario para mostrar en el dashboard
  String get username {
    if (_token == null) return 'Usuario';
    try {
      final payload = _token!.split('.')[1];
      final decoded =
          utf8.decode(base64Url.decode(base64Url.normalize(payload)));
      final Map<String, dynamic> data = jsonDecode(decoded);
      return data['user']?['username'] ?? 'Usuario';
    } catch (e) {
      return 'Usuario';
    }
  }

  final String _baseUrl = 'http://127.0.0.1:8000/api/users';

  Future<void> initAuth() async {
    _token = html.window.localStorage['access_token'];
    notifyListeners();
  }

  // --- MÉTODO DE LOGIN ---
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? tokenRecibido = data['token'];

        if (tokenRecibido != null) {
          _token = tokenRecibido;
          html.window.localStorage['access_token'] = _token!;

          // --- LOG PROFESIONAL ---
          debugPrint('=========================================');
          debugPrint('✅ AUTHENTICATION SUCCESSFUL');
          debugPrint('👤 User: ${data['user']?['username'] ?? 'Unknown'}');
          debugPrint('🔑 Token: $_token');
          debugPrint('=========================================');

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error de conexión (login): $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // --- NUEVO MÉTODO DE REGISTRO ---
  Future<bool> registrarUsuario(
      String username, String email, String password, String rol) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/register/'), // Asegúrate que tu ruta en Django sea esta
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'rol': rol
        }),
      );

      debugPrint("DEBUG: Respuesta Registro. Status: ${response.statusCode}");

      // La mayoría de APIs REST devuelven 201 Created para registros exitosos
      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error de conexión (registro): $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    html.window.localStorage.remove('access_token');
    notifyListeners();
  }
}
