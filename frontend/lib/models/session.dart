import 'trial.dart';

class DiagnosticSession {
  final int id;
  final int patient;
  final String status;
  final DateTime startTime;
  final List<ReactionTrial>? trials; // se cargan aparte

  DiagnosticSession(
      {required this.id,
      required this.patient,
      required this.status,
      required this.startTime,
      this.trials});

  factory DiagnosticSession.fromJson(Map<String, dynamic> json) {
    return DiagnosticSession(
      id: json['id'],
      patient: json['patient'],
      status: json['status'],
      startTime: DateTime.parse(json['start_time']),
    );
  }
}

class Sesion {
  final int id;
  final String tipoPrueba;
  final String puntajeTotal;
  final String fecha;

  Sesion(
      {required this.id,
      required this.tipoPrueba,
      required this.puntajeTotal,
      required this.fecha});

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      id: json['id'],
      tipoPrueba: json['tipo_prueba'],
      puntajeTotal: json['puntaje_total'].toString(),
      fecha: json['fecha_hora_inicio'],
    );
  }
}
