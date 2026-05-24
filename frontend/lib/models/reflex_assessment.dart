import 'result_model.dart';

class ReflexAssessment {
  final double totalScore;
  final double reactionTimeAvg;
  final double reactionTimeMin;
  final double reactionTimeMax;
  final int totalTrials;
  final int correctTrials;
  final double accuracyPercent;
  final ReflexLevel reflexLevel;
  final String reflexDescription;
  final double neuroScore;
  final double focusScore;
  final double consistencyScore;
  final List<Map<String, dynamic>> trialRecords;

  ReflexAssessment({
    required this.totalScore,
    required this.reactionTimeAvg,
    required this.reactionTimeMin,
    required this.reactionTimeMax,
    required this.totalTrials,
    required this.correctTrials,
    required this.accuracyPercent,
    required this.reflexLevel,
    required this.reflexDescription,
    required this.neuroScore,
    required this.focusScore,
    required this.consistencyScore,
    required this.trialRecords,
  });

  factory ReflexAssessment.fromTrials(
    List<Map<String, dynamic>> trialRecords, {
    required double totalScore,
  }) {
    final totalTrials = trialRecords.length;
    final correctTrials =
        trialRecords.where((trial) => trial['is_correct'] == true).length;
    final accuracyPercent =
        totalTrials == 0 ? 0.0 : (correctTrials / totalTrials) * 100;

    final reactionTimes = trialRecords
        .map((trial) => (trial['reaction_time_ms'] as num?)?.toDouble() ?? 0.0)
        .where((value) => value > 0)
        .toList();

    if (reactionTimes.isEmpty) {
      return ReflexAssessment(
        totalScore: totalScore,
        reactionTimeAvg: 0,
        reactionTimeMin: 0,
        reactionTimeMax: 0,
        totalTrials: totalTrials,
        correctTrials: correctTrials,
        accuracyPercent: accuracyPercent,
        reflexLevel:
            ReflexLevel.poor, // Asumir el peor nivel si no hay datos válidos
        reflexDescription:
            'Aún no hay respuestas válidas registradas. Repite la prueba para obtener una evaluación.',
        neuroScore: 0,
        focusScore: 0,
        consistencyScore: 100,
        trialRecords: trialRecords,
      );
    }

    final diagnostic = DiagnosticResult.fromTrials(
      sessionId: 1,
      userId: 0,
      trials: trialRecords,
    );

    return ReflexAssessment(
      totalScore: totalScore,
      reactionTimeAvg: diagnostic.reactionTimeAvg,
      reactionTimeMin: diagnostic.reactionTimeMin,
      reactionTimeMax: diagnostic.reactionTimeMax,
      totalTrials: diagnostic.totalTrials,
      correctTrials: diagnostic.correctTrials,
      accuracyPercent: diagnostic.accuracyPercent,
      reflexLevel: diagnostic.reflexLevel,
      reflexDescription: diagnostic.reflexLevel.description,
      neuroScore: diagnostic.neuroScore,
      focusScore: diagnostic.focusScore,
      consistencyScore: diagnostic.consistencyScore,
      trialRecords: trialRecords,
    );
  }

  String get formattedAverageReaction => '${reactionTimeAvg.round()} ms';

  String get formattedFastestReaction => '${reactionTimeMin.round()} ms';

  String get formattedSlowestReaction => '${reactionTimeMax.round()} ms';

  String get detailedObservation =>
      'Nivel: ${reflexLevel.displayName}. $reflexDescription '
      'Promedio: $formattedAverageReaction, precisión: ${accuracyPercent.toStringAsFixed(1)}%, '
      'intentos: $correctTrials/$totalTrials correctos.';

  Map<String, dynamic> toSavePayload(String tipoPrueba) {
    return {
      'tipo_prueba': tipoPrueba,
      'puntaje_total': totalScore.toStringAsFixed(0),
      'observaciones': detailedObservation,
      'resultados': trialRecords
          .map((trial) => {
                'tiempo_reaccion_ms':
                    (trial['reaction_time_ms'] as num?)?.round() ?? 0,
                'tipo_movimiento': trial['tipo_movimiento'] ?? 'Extensión',
                'precision_porcentaje':
                    (trial['precision_porcentaje'] as num?)?.toDouble() ??
                        100.0,
                'latencia_registrada_ms':
                    (trial['latencia_registrada_ms'] as num?)?.round() ?? 0,
              })
          .toList(),
    };
  }
}
