// =========================================
// models/result_model.dart
// =========================================
// Modelo de datos para resultados de diagnóstico

import 'package:intl/intl.dart';
import 'dart:math' as math;

/// Niveles de reflejos
enum ReflexLevel {
  excellent, // Excelente (< 200ms)
  good, // Bueno (200-300ms)
  fair, // Regular (300-450ms)
  poor, // Pobre (> 450ms)

  // Validar rangos específicos según datos reales
}

/// Extensión para niveles de reflejos
extension ReflexLevelExtension on ReflexLevel {
  String get displayName {
    switch (this) {
      case ReflexLevel.excellent:
        return 'Excelente';
      case ReflexLevel.good:
        return 'Bueno';
      case ReflexLevel.fair:
        return 'Regular';
      case ReflexLevel.poor:
        return 'Pobre';
    }
  }

  String get description {
    switch (this) {
      case ReflexLevel.excellent:
        return 'Reflejos muy rápidos y precisos';
      case ReflexLevel.good:
        return 'Reflejos rápidos y precisos';
      case ReflexLevel.fair:
        return 'Reflejos dentro de lo normal';
      case ReflexLevel.poor:
        return 'Reflejos lentos, se recomienda evaluación';
    }
  }

  double get score {
    switch (this) {
      case ReflexLevel.excellent:
        return 100;
      case ReflexLevel.good:
        return 75;
      case ReflexLevel.fair:
        return 50;
      case ReflexLevel.poor:
        return 25;
    }
  }
}

/// Modelo de resultados de diagnóstico
class DiagnosticResult {
  final int? id;
  final int sessionId;
  final int userId;
  final DateTime timestamp;

  // Métricas de tiempo de reacción
  final double reactionTimeAvg; // ms
  final double reactionTimeMin; // ms
  final double reactionTimeMax; // ms

  // Métricas de precisión
  final int totalTrials;
  final int correctTrials;
  final double accuracyPercent; // 0-100

  // Métricas neurológicas
  final ReflexLevel reflexLevel;
  final double neuroScore; // 0-100 (Puntuación neurológica)
  final double focusScore; // 0-100 (Concentración)
  final double consistencyScore; // 0-100 (Consistencia)

  // Datos adicionales
  final String? notes;
  final String? pdfReportPath;

  DiagnosticResult({
    this.id,
    required this.sessionId,
    required this.userId,
    required this.timestamp,
    required this.reactionTimeAvg,
    required this.reactionTimeMin,
    required this.reactionTimeMax,
    required this.totalTrials,
    required this.correctTrials,
    required this.accuracyPercent,
    required this.reflexLevel,
    required this.neuroScore,
    required this.focusScore,
    required this.consistencyScore,
    this.notes,
    this.pdfReportPath,
  });

  /// Crear resultado a partir de datos de intentos
  factory DiagnosticResult.fromTrials({
    required int sessionId,
    required int userId,
    required List<Map<String, dynamic>> trials,
  }) {
    if (trials.isEmpty) {
      throw Exception(
          'Se requieren datos de intentos para calcular resultados');
    }

    // Calcular tiempos de reacción
    final reactionTimes = trials
        .map((t) => (t['reaction_time_ms'] as num?)?.toDouble() ?? 0.0)
        .where((t) => t > 0)
        .toList();

    final reactionTimeAvg = reactionTimes.isNotEmpty
        ? reactionTimes.reduce((a, b) => a + b) / reactionTimes.length
        : 0.0;

    final reactionTimeMin = reactionTimes.isNotEmpty
        ? reactionTimes.reduce((a, b) => a < b ? a : b)
        : 0.0;

    final reactionTimeMax = reactionTimes.isNotEmpty
        ? reactionTimes.reduce((a, b) => a > b ? a : b)
        : 0.0;

    // Calcular precisión
    final correctTrials = trials.where((t) => t['is_correct'] == true).length;
    final accuracyPercent = (correctTrials / trials.length) * 100;

    // Determinar nivel de reflejos
    final reflexLevel = _calculateReflexLevel(reactionTimeAvg);

    // Calcular puntuación neurológica
    final neuroScore = _calculateNeuroScore(
      reactionTimeAvg,
      accuracyPercent,
      trials.length,
    );

    // Calcular otros scores
    final focusScore = _calculateFocusScore(
      reactionTimeMax - reactionTimeMin,
      accuracyPercent,
    );

    final consistencyScore = _calculateConsistencyScore(
      reactionTimes,
    );

    return DiagnosticResult(
      sessionId: sessionId,
      userId: userId,
      timestamp: DateTime.now(),
      reactionTimeAvg: reactionTimeAvg,
      reactionTimeMin: reactionTimeMin,
      reactionTimeMax: reactionTimeMax,
      totalTrials: trials.length,
      correctTrials: correctTrials,
      accuracyPercent: accuracyPercent,
      reflexLevel: reflexLevel,
      neuroScore: neuroScore,
      focusScore: focusScore,
      consistencyScore: consistencyScore,
    );
  }

  /// Calcular nivel de reflejos basado en tiempo promedio
  static ReflexLevel _calculateReflexLevel(double avgReactionTime) {
    if (avgReactionTime < 200) {
      return ReflexLevel.excellent;
    } else if (avgReactionTime < 300) {
      return ReflexLevel.good;
    } else if (avgReactionTime < 450) {
      return ReflexLevel.fair;
    } else {
      return ReflexLevel.poor;
    }
  }

  /// Calcular puntuación neurológica (0-100)
  static double _calculateNeuroScore(
    double reactionTimeAvg,
    double accuracyPercent,
    int trialCount,
  ) {
    // Componentes:
    // - Velocidad (40%): Basado en tiempo de reacción
    // - Precisión (40%): Basado en accuracy
    // - Consistencia (20%): Basado en número de intentos

    // Velocidad: Invertir escala (menos tiempo = más score)
    final speedScore = (200 - reactionTimeAvg.clamp(0, 200)) / 200 * 40;

    // Precisión
    final accuracyScore = (accuracyPercent / 100) * 40;

    // Consistencia
    final consistencyBase = (trialCount / 10).clamp(0, 1) * 20;

    final neuroScore = speedScore + accuracyScore + consistencyBase;

    return neuroScore.clamp(0, 100);
  }

  /// Calcular puntuación de enfoque (0-100)
  static double _calculateFocusScore(
    double reactionTimeVariance,
    double accuracyPercent,
  ) {
    // Menos varianza = más enfoque
    final varianceScore = (300 - reactionTimeVariance.clamp(0, 300)) / 300 * 50;

    // Más precisión = más enfoque
    final accuracyScore = (accuracyPercent / 100) * 50;

    final focusScore = varianceScore + accuracyScore;

    return focusScore.clamp(0, 100);
  }

  /// Calcular puntuación de consistencia (0-100)
  static double _calculateConsistencyScore(List<double> reactionTimes) {
    if (reactionTimes.length < 2) return 100;

    // Calcular desviación estándar
    final mean = reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
    final variance = reactionTimes
            .map((t) => (t - mean) * (t - mean))
            .reduce((a, b) => a + b) /
        reactionTimes.length;
    final standardDeviation = math.sqrt(variance);

    // Menos desviación = más consistencia
    final consistencyScore =
        (100 - (standardDeviation / 50).clamp(0, 100)) * 100 / 100;

    return consistencyScore.clamp(0, 100);
  }

  /// Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() => {
        'session': sessionId,
        'user': userId,
        'reaction_time_avg': reactionTimeAvg,
        'reaction_time_min': reactionTimeMin,
        'reaction_time_max': reactionTimeMax,
        'total_trials': totalTrials,
        'correct_trials': correctTrials,
        'accuracy_percent': accuracyPercent,
        'reflex_level': reflexLevel.toString().split('.').last,
        'neuro_score': neuroScore,
        'focus_score': focusScore,
        'consistency_score': consistencyScore,
        'notes': notes,
      };

  /// Crear desde JSON
  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      id: json['id'] as int?,
      sessionId: json['session_id'] as int,
      userId: json['user_id'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reactionTimeAvg: (json['reaction_time_avg'] as num).toDouble(),
      reactionTimeMin: (json['reaction_time_min'] as num).toDouble(),
      reactionTimeMax: (json['reaction_time_max'] as num).toDouble(),
      totalTrials: json['total_trials'] as int,
      correctTrials: json['correct_trials'] as int,
      accuracyPercent: (json['accuracy_percent'] as num).toDouble(),
      reflexLevel: ReflexLevel.values.firstWhere(
        (level) => level.toString().split('.').last == json['reflex_level'],
        orElse: () => ReflexLevel.fair,
      ),
      neuroScore: (json['neuro_score'] as num).toDouble(),
      focusScore: (json['focus_score'] as num).toDouble(),
      consistencyScore: (json['consistency_score'] as num).toDouble(),
      notes: json['notes'] as String?,
      pdfReportPath: json['pdf_report_path'] as String?,
    );
  }

  /// Formato fecha localizado
  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(timestamp);
  }

  /// Resumen de resultados como string
  String get summary {
    return '''
Diagnóstico de Reflejos y Capacidad Motora
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Nivel de Reflejos: ${reflexLevel.displayName}
Puntuación Neurológica: ${neuroScore.toStringAsFixed(1)}/100
Precisión: ${accuracyPercent.toStringAsFixed(1)}%
Tiempo Reacción Promedio: ${reactionTimeAvg.toStringAsFixed(0)}ms
Enfoque: ${focusScore.toStringAsFixed(1)}/100
Consistencia: ${consistencyScore.toStringAsFixed(1)}/100
Intentos: $correctTrials/$totalTrials correctos
Fecha: $formattedDate
    ''';
  }
}
