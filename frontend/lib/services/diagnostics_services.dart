import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class DiagnosticsService {
  String get _baseUrl => ApiConfig.baseUrl;

  Map<String, String> _getHeaders(AuthProvider auth) {
    final token = auth.token?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Inicia sesión nuevamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _extractErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'No se pudo completar la operación. Código ${response.statusCode}.';
    }

    try {
      final payload = json.decode(response.body);
      if (payload is Map<String, dynamic>) {
        final message =
            payload['message'] ?? payload['detail'] ?? payload['error'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Si el cuerpo no es JSON, se usa el texto plano.
    }

    return response.body;
  }

  Future<void> sincronizarSesion(
      AuthProvider auth, Map<String, dynamic> datos) async {
    final headers = _getHeaders(auth);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/diagnostics/guardar/'),
        headers: headers,
        body: json.encode(datos),
      );

      if (response.statusCode == 401) {
        auth.logout();
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = response.body.isNotEmpty ? response.body : 'Sin detalle';
        throw Exception('No se pudo guardar la sesión: $body');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de red al guardar la sesión: $e');
    }
  }

  Future<List<dynamic>> obtenerHistorial(AuthProvider auth) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/diagnostics/historial/'),
        headers: _getHeaders(auth),
      );
      return response.statusCode == 200 ? json.decode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  Future<void> eliminarSesion(AuthProvider auth, int sesionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/diagnostics/eliminar/$sesionId/'),
        headers: _getHeaders(auth),
      );

      if (response.statusCode == 401) {
        auth.logout();
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de red al eliminar la sesión: $e');
    }
  }

  Future<void> eliminarHistorial(AuthProvider auth) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/diagnostics/eliminar_historial/'),
        headers: _getHeaders(auth),
      );

      if (response.statusCode == 401) {
        auth.logout();
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de red al eliminar el historial: $e');
    }
  }
}
