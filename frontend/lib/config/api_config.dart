class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // usa tu IP real;
  static const String loginEndpoint = '/auth/login/';
  static const String tokenRefreshEndpoint = '/auth/token/refresh/';
  static const String sessionsEndpoint = '/diagnostics/sessions/';
  static const String resultsEndpoint = '/diagnostics/results/';
  static const String analyticsEndpoint = '/analytics/';
  // WebSocket (aún no implementado en backend, pero necesario para compilación)
  static const String wsUrl = 'ws://127.0.0.1:8000/ws/diagnostics/stream/';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
