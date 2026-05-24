import 'package:flutter_test/flutter_test.dart';
import 'package:neurofit_frontend/models/reflex_assessment.dart';
import 'package:neurofit_frontend/models/result_model.dart';

void main() {
  test('construye una evaluación detallada para trials válidos', () {
    final assessment = ReflexAssessment.fromTrials(
      [
        {
          'reaction_time_ms': 180.0,
          'is_correct': true,
        },
        {
          'reaction_time_ms': 240.0,
          'is_correct': true,
        },
        {
          'reaction_time_ms': 320.0,
          'is_correct': false,
        },
      ],
      totalScore: 8,
    );

    expect(assessment.reactionTimeAvg, closeTo(246.6667, 0.01));
    expect(assessment.reactionTimeMin, 180.0);
    expect(assessment.reactionTimeMax, 320.0);
    expect(assessment.totalTrials, 3);
    expect(assessment.correctTrials, 2);
    expect(assessment.accuracyPercent, closeTo(66.6667, 0.01));
    expect(assessment.reflexLevel, ReflexLevel.good);
    expect(assessment.reflexDescription, 'Reflejos rápidos y precisos');
    expect(assessment.neuroScore, greaterThan(0));
  });

  test('devuelve una evaluación pobre cuando no hay tiempos válidos', () {
    final assessment = ReflexAssessment.fromTrials(
      [
        {
          'reaction_time_ms': 0,
          'is_correct': false,
        },
        {
          'reaction_time_ms': 0,
          'is_correct': false,
        },
      ],
      totalScore: 0,
    );

    expect(assessment.reflexLevel, ReflexLevel.poor);
    expect(assessment.reflexDescription,
        'Aún no hay respuestas válidas registradas. Repite la prueba para obtener una evaluación.');
    expect(assessment.reactionTimeAvg, 0);
    expect(assessment.accuracyPercent, 0);
  });

  test('mapea los resultados al esquema esperado por el backend', () {
    final assessment = ReflexAssessment.fromTrials(
      [
        {
          'reaction_time_ms': 180.0,
          'precision_porcentaje': 100.0,
          'latencia_registrada_ms': 180,
          'tipo_movimiento': 'Índice',
          'is_correct': true,
        },
      ],
      totalScore: 4,
    );

    final payload = assessment.toSavePayload('Coordinación Motriz Fina');
    final resultado = payload['resultados'] as List<dynamic>;

    expect(resultado.first['tiempo_reaccion_ms'], 180);
    expect(resultado.first['precision_porcentaje'], 100.0);
    expect(resultado.first['latencia_registrada_ms'], 180);
    expect(resultado.first.containsKey('reaction_time_ms'), isFalse);
  });
}
