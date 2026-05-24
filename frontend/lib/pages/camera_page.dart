import 'dart:async';
import 'dart:math' as math;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../models/reflex_assessment.dart';
import '../models/result_model.dart';
import '../providers/auth_provider.dart';
import 'history_page.dart';
import '../services/diagnostics_services.dart';

enum GameState { idle, playing, finished }

class TargetBall {
  final Offset normalizedPosition;
  final double radius;
  final Color color;
  final int targetFingerIndex;
  final String fingerName;

  TargetBall({
    required this.normalizedPosition,
    required this.radius,
    required this.color,
    required this.targetFingerIndex,
    required this.fingerName,
  });
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  late AnimationController _scanController;
  List<Offset>? _currentLandmarks;
  final String _viewType = 'mediapipe-hand-tracker';
  double _finalScore = 0.0;
  List<Map<String, dynamic>> _resultsList = [];
  ReflexAssessment? _latestAssessment;

  GameState _gameState = GameState.idle;
  int _score = 0;
  final int _totalTime = 30;
  int _currentTime = 30;
  Timer? _gameTimer;
  DateTime? _currentTrialStartedAt;
  int _currentTrialIndex = -1;

  TargetBall? _currentTarget;
  final math.Random _random = math.Random();

  Size _cameraAreaSize = Size.zero;
  bool _isViewCreated = false;
  Rect? _videoRect;

  // Matriz de transformación que mapea coordenadas normalizadas a píxeles del área visible del vídeo
  Matrix4 get _videoTransformMatrix {
    final rect = _videoRect;
    if (rect == null || rect.width <= 0 || rect.height <= 0) {
      // Fallback: usar todo el contenedor
      return Matrix4.identity()
        ..scale(_cameraAreaSize.width, _cameraAreaSize.height);
    }
    return Matrix4.identity()
      ..translate(rect.left, rect.top)
      ..scale(rect.width, rect.height);
  }

  // Aplica la matriz a un punto normalizado (0..1) devolviendo píxeles
  Offset _applyMatrix(Matrix4 matrix, Offset point) {
    final storage = matrix.storage;
    final x = storage[0] * point.dx + storage[4] * point.dy + storage[12];
    final y = storage[1] * point.dx + storage[5] * point.dy + storage[13];
    return Offset(x, y);
  }

  final Map<int, Map<String, dynamic>> _interactableFingers = {
    4: {'name': 'Pulgar', 'color': Colors.pinkAccent},
    8: {'name': 'Índice', 'color': Colors.cyanAccent},
    12: {'name': 'Medio', 'color': Colors.purpleAccent},
    16: {'name': 'Anular', 'color': Colors.orangeAccent},
    20: {'name': 'Meñique', 'color': Colors.yellowAccent},
  };

  void _finalizarPrueba(ReflexAssessment assessment) {
    setState(() {
      _finalScore = assessment.totalScore;
      _resultsList = assessment.trialRecords;
      _latestAssessment = assessment;
      _gameState = GameState.finished;
    });
  }

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final web.HTMLDivElement divContainer =
            web.document.createElement('div') as web.HTMLDivElement;
        divContainer.id = 'mediapipe-camera-container';
        divContainer.style.width = '100%';
        divContainer.style.height = '100%';
        divContainer.style.backgroundColor = 'black';
        divContainer.style.display = 'block';

        if (!_isViewCreated) {
          _isViewCreated = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _triggerJavaScriptStart();
          });
        }

        return divContainer;
      },
    );

    final JSObject unsafeWindow = web.window as JSObject;

    unsafeWindow['onLandmarksReceived'] = (JSArray? landmarks) {
      if (!mounted || _gameState != GameState.playing) {
        if (_currentLandmarks != null) {
          setState(() => _currentLandmarks = null);
        }
        return;
      }

      if (landmarks == null) {
        setState(() => _currentLandmarks = null);
      } else {
        try {
          final List<Offset> points = [];
          final List<JSAny?> dartList = landmarks.toDart;
          for (final item in dartList) {
            if (item != null) {
              final JSObject landmarkObj = item as JSObject;
              final double x =
                  (landmarkObj.getProperty('x'.toJS) as JSNumber).toDartDouble;
              final double y =
                  (landmarkObj.getProperty('y'.toJS) as JSNumber).toDartDouble;
              points.add(Offset(x, y));
            }
          }

          if (mounted) {
            setState(() {
              _currentLandmarks = points;
              if (points.length >= 21 && _currentTarget != null) {
                _checkCollision(points);
              }
            });
          }
        } catch (e) {
          debugPrint('[MotorSense] Excepción en flujo visual: $e');
        }
      }
    }.toJS;

    unsafeWindow['onVideoRectChanged'] = (JSObject rect) {
      if (!mounted) return;
      try {
        final double offsetX =
            (rect.getProperty('offsetX'.toJS) as JSNumber).toDartDouble;
        final double offsetY =
            (rect.getProperty('offsetY'.toJS) as JSNumber).toDartDouble;
        final double displayedWidth =
            (rect.getProperty('displayedWidth'.toJS) as JSNumber).toDartDouble;
        final double displayedHeight =
            (rect.getProperty('displayedHeight'.toJS) as JSNumber).toDartDouble;

        if (displayedWidth > 0 && displayedHeight > 0) {
          setState(() {
            _videoRect = Rect.fromLTWH(
                offsetX, offsetY, displayedWidth, displayedHeight);
          });
        }
      } catch (e) {
        debugPrint('[MotorSense] Error al recibir videoRect: $e');
      }
    }.toJS;
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _currentTime = _totalTime;
      _resultsList = [];
      _latestAssessment = null;
      _currentTrialStartedAt = null;
      _currentTrialIndex = -1;
      _gameState = GameState.playing;
      _spawnNewTarget();
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentTime > 0) {
          _currentTime--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    final assessment = ReflexAssessment.fromTrials(
      _resultsList,
      totalScore: _score.toDouble(),
    );
    _finalizarPrueba(assessment);
    debugPrint('Juego terminado. Score final: $_score');
  }

  void _spawnNewTarget() {
    final int randomFingerKey = _interactableFingers.keys
        .elementAt(_random.nextInt(_interactableFingers.length));
    final fingerData = _interactableFingers[randomFingerKey]!;
    final now = DateTime.now();

    _currentTarget = TargetBall(
      normalizedPosition: Offset(
        0.20 + _random.nextDouble() * 0.60,
        0.25 + _random.nextDouble() * 0.50,
      ),
      radius: 35.0,
      color: fingerData['color'] as Color,
      targetFingerIndex: randomFingerKey,
      fingerName: fingerData['name'] as String,
    );

    _currentTrialStartedAt = now;
    _currentTrialIndex = _resultsList.length;
    _resultsList.add({
      'trial_index': _currentTrialIndex,
      'tipo_movimiento': _currentTarget!.fingerName,
      'reaction_time_ms': 0,
      'precision_porcentaje': 0.0,
      'latencia_registrada_ms': 0,
      'is_correct': false,
      'capturado_en': now.toIso8601String(),
    });
  }

  void _checkCollision(List<Offset> points) {
    if (_currentTarget == null || _currentTrialStartedAt == null) return;
    final matrix = _videoTransformMatrix;
    final fingerTipNorm = points[_currentTarget!.targetFingerIndex];
    final targetNorm = _currentTarget!.normalizedPosition;

    final fingerPixel = _applyMatrix(matrix, fingerTipNorm);
    final targetPixel = _applyMatrix(matrix, targetNorm);

    final double distance = (fingerPixel - targetPixel).distance;
    if (distance <= _currentTarget!.radius) {
      final reactionMs = DateTime.now()
          .difference(_currentTrialStartedAt!)
          .inMilliseconds
          .toDouble();

      setState(() {
        _score++;
        _resultsList[_currentTrialIndex] = {
          ..._resultsList[_currentTrialIndex],
          'reaction_time_ms': reactionMs.round(),
          'precision_porcentaje': 100.0,
          'latencia_registrada_ms': reactionMs.round(),
          'is_correct': true,
        };
        _spawnNewTarget();
      });
    }
  }

  void _triggerJavaScriptStart() {
    try {
      final JSObject unsafeWindow = web.window as JSObject;
      if (unsafeWindow.hasProperty('startMediaPipe'.toJS).toDart) {
        unsafeWindow.callMethod(
            'startMediaPipe'.toJS, _viewType.toJS, 'onLandmarksReceived'.toJS);
      }
    } catch (e) {
      debugPrint('Error iniciando JS: $e');
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('MotorSense - Evaluación Técnica',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          if (_gameState == GameState.playing)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '⏱️ ${_currentTime}s',
                  style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            )
        ],
      ),
      body: _buildBodyByState(),
    );
  }

  Widget _buildBodyByState() {
    switch (_gameState) {
      case GameState.idle:
        return _buildIdleScreen();
      case GameState.playing:
        return _buildPlayingScreen();
      case GameState.finished:
        return _buildResultsDashboard();
    }
  }

  Widget _buildIdleScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 80, color: Colors.cyanAccent),
          const SizedBox(height: 20),
          const Text('Test de Coordinación Motriz Fina',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'El sistema evaluará la velocidad de respuesta y precisión neurológica al presionar los objetivos con los dedos indicados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Prueba (30s)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            icon: const Icon(Icons.bar_chart, color: Colors.cyanAccent),
            label: const Text('Ver Estadísticas y Sesiones',
                style: TextStyle(color: Colors.cyanAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.cyanAccent),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingScreen() {
    return LayoutBuilder(builder: (context, constraints) {
      // Definimos la relación de aspecto de la cámara.
      // Si tu cámara es 16:9, esto hará que el video y el lienzo sean idénticos.
      const double aspectRatio = 16 / 9;

      return Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            children: [
              // El video siempre ocupa el 100% del AspectRatio
              Positioned.fill(
                child: HtmlElementView(viewType: _viewType),
              ),
              // El lienzo se pinta sobre el mismo AspectRatio
              Positioned.fill(
                child: CustomPaint(
                  painter: GameMeshPainter(
                    landmarks: _currentLandmarks ?? [],
                    targetBall: _currentTarget,
                    // Pasamos el tamaño del constraint para que el painter sepa la escala
                    containerSize:
                        Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
              // Overlay de UI
              Positioned(
                  top: 20, left: 20, right: 20, child: _buildGameOverlay()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGameOverlay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _currentTarget != null ? _currentTarget!.color : Colors.cyan,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _currentTarget != null
                  ? 'Usa el dedo: ${_currentTarget!.fingerName.toUpperCase()}'
                  : 'Cargando...',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          Text('Puntos: $_score',
              style: const TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultsDashboard() {
    final assessment = _latestAssessment;
    final currentAssessment = assessment;
    final scoreText = currentAssessment?.totalScore.toStringAsFixed(0) ??
        _finalScore.toStringAsFixed(0);
    final precisionText = currentAssessment == null
        ? 'N/A'
        : '${currentAssessment.accuracyPercent.toStringAsFixed(1)}%';
    final reactionText = currentAssessment?.formattedAverageReaction ?? 'N/A';
    final reflexLevelText = currentAssessment?.reflexLevel.displayName ?? 'N/A';
    final neuroScoreText = currentAssessment == null
        ? 'N/A'
        : currentAssessment.neuroScore.toStringAsFixed(1);
    final consistencyText = currentAssessment == null
        ? 'N/A'
        : '${currentAssessment.consistencyScore.toStringAsFixed(1)}%';
    final reflexDescription = currentAssessment?.reflexDescription ??
        'Aún no hay datos suficientes para describir tus reflejos.';
    final fastestReactionText =
        currentAssessment?.formattedFastestReaction ?? 'N/A';
    final slowestReactionText =
        currentAssessment?.formattedSlowestReaction ?? 'N/A';
    final attemptsText = currentAssessment == null
        ? '0/0'
        : '${currentAssessment.correctTrials}/${currentAssessment.totalTrials}';
    final focusText = currentAssessment == null
        ? 'N/A'
        : '${currentAssessment.focusScore.toStringAsFixed(1)}%';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text('¡Prueba Finalizada!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetricCard('Puntaje Total', scoreText, 'Mayor es mejor',
                    Colors.greenAccent, Icons.star),
                const SizedBox(width: 20),
                _buildMetricCard(
                    'Precisión',
                    precisionText,
                    'Aciertos / intentos',
                    Colors.orangeAccent,
                    Icons.check_circle),
                _buildMetricCard('Tiempo Promedio', reactionText,
                    'Menor es mejor', Colors.blueAccent, Icons.access_time),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetricCard(
                    'Nivel de Reflejos',
                    //validar nivel de reflejos según el nivel calculado
                    reflexLevelText,
                    'Clasificación automática',
                    Colors.cyanAccent,
                    Icons.auto_awesome),
                const SizedBox(width: 20),
                _buildMetricCard(
                    'Puntaje Neurológico',
                    neuroScoreText,
                    'Velocidad + precisión',
                    Colors.purpleAccent,
                    Icons.psychology),
                _buildMetricCard(
                    'Consistencia',
                    consistencyText,
                    'Menos variación es mejor',
                    Colors.limeAccent,
                    Icons.show_chart),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Descripción de tus reflejos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(reflexDescription,
                      style:
                          const TextStyle(color: Colors.white70, height: 1.5)),
                  const SizedBox(height: 18),
                  _buildDetailRow('Tiempo más rápido', fastestReactionText),
                  _buildDetailRow('Tiempo más lento', slowestReactionText),
                  _buildDetailRow('Intentos registrados', attemptsText),
                  _buildDetailRow('Enfoque', focusText),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Guardar en Historial"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                final payload = (currentAssessment ??
                        ReflexAssessment.fromTrials(_resultsList,
                            totalScore: _finalScore))
                    .toSavePayload('Coordinación Motriz Fina');
                try {
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  await DiagnosticsService().sincronizarSesion(auth, payload);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("✅ Diagnóstico guardado exitosamente"),
                        backgroundColor: Colors.green),
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage()));
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Error al guardar: $e")));
                  }
                }
              },
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => setState(() => _gameState = GameState.idle),
              child: const Text("Volver al Inicio",
                  style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String description,
      Color color, IconData iconr) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(description,
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}

// =========================================================================
// CUSTOM PAINTER CORREGIDO SIN Vector3
// =========================================================================
class GameMeshPainter extends CustomPainter {
  final List<Offset> landmarks;
  final TargetBall? targetBall;
  final Size containerSize;

  GameMeshPainter({
    required this.landmarks,
    required this.targetBall,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dibujar el objetivo (TargetBall) si existe
    if (targetBall != null) {
      final targetPixel = Offset(
        targetBall!.normalizedPosition.dx * size.width,
        targetBall!.normalizedPosition.dy * size.height,
      );

      final targetPaint = Paint()
        ..color = targetBall!.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      // Dibujar borde del objetivo
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(targetPixel, targetBall!.radius, targetPaint);
      canvas.drawCircle(targetPixel, targetBall!.radius, borderPaint);
    }

    if (landmarks.isEmpty) return;

    // 2. Colores específicos por punta de dedo
    final Map<int, Color> fingerTipColors = {
      4: Colors.pinkAccent, // Pulgar
      8: Colors.cyanAccent, // Índice
      12: Colors.purpleAccent, // Medio
      16: Colors.orangeAccent, // Anular
      20: Colors.yellowAccent, // Meñique
    };

    final linePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final scaledPoints = landmarks
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    // 3. Dibujar conexiones de la mano
    const List<List<int>> connections = [
      [0, 1, 2, 3, 4],
      [0, 5, 6, 7, 8],
      [9, 10, 11, 12],
      [13, 14, 15, 16],
      [0, 17, 18, 19, 20],
      [5, 9, 13, 17]
    ];

    for (var path in connections) {
      for (int i = 0; i < path.length - 1; i++) {
        canvas.drawLine(
            scaledPoints[path[i]], scaledPoints[path[i + 1]], linePaint);
      }
    }

    // 4. Dibujo de nodos (puntos de la mano)
    for (int i = 0; i < scaledPoints.length; i++) {
      Paint pointPaint = Paint()..style = PaintingStyle.fill;
      pointPaint.color = fingerTipColors.containsKey(i)
          ? fingerTipColors[i]!
          : Colors.white.withValues(alpha: 0.7);

      canvas.drawCircle(scaledPoints[i],
          fingerTipColors.containsKey(i) ? 8.0 : 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GameMeshPainter oldDelegate) => true;
}
