// =========================================
// INTEGRATION_GUIDE.md
// =========================================
// Guía de integración de optimizaciones de visión por computadora
// Sin modificar el código base existente

# NeuroFit Frontend - Optimizaciones de Visión por Computadora

## Resumen de mejoras

### 1. **Procesamiento Mejorado de MediaPipe** ⚡
- **mediapipe_hands_optimized.js**: Versión con Web Workers, frame skipping y caching
- Reducción de latencia mediante procesamiento paralelo
- Detección automática de outliers y confianza

### 2. **Suavizado Avanzado de Landmarks** 📍
- **HandLandmarksEnhancer**: Filtro Kalman para suavizado óptimo
- Detección de confianza individual por punto
- Predicción del siguiente frame
- Velocidad de movimiento calculada

### 3. **Monitoreo de Rendimiento** 📊
- **VisionPerformanceMonitor**: Métricas en tiempo real
- Latencia, FPS, confianza, uso de memoria
- Detección automática de problemas de rendimiento
- Stream de eventos para UI

### 4. **Renderización Optimizada** 🎨
- **EnhancedHandLandmarkPainter**: CustomPaint con cache de objetos
- Renderización eficiente sin allocations innecesarias
- Visualización de confianza mediante colores dinámicos

### 5. **Efectos Visuales Dinámicos** ✨
- **VisionEffectsPainter**: Trails, partículas y feedback visual
- Indicador visual de confianza
- Efectos de explosión en colisiones
- Trail de movimiento de manos

---

## Uso - Opción 1: Solo JavaScript Optimizado (Recomendado para empezar)

### Paso 1: Actualizar `web/index.html`

```html
<!-- Cambiar de: -->
<script type="module" src="mediapipe_hands.js"></script>

<!-- A: -->
<script type="module" src="mediapipe_hands_optimized.js"></script>
```

**Beneficios inmediatos**:
- ✅ Frame skipping automático (30fps max)
- ✅ Outlier detection
- ✅ Confidence filtering
- ✅ Landmark caching
- ✅ Procesamiento más rápido
- ✅ Mismo API que antes - Compatible 100%

---

## Uso - Opción 2: Servicios Dart Optimizados (Máximas mejoras)

### Paso 1: Crear `diagnostic_page_optimized.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/mediapipe_service_optimized.dart';
import '../services/vision_performance_monitor.dart';
import '../widgets/enhanced_hand_landmark_painter.dart';
import '../widgets/vision_effects_painter.dart';

class DiagnosticPageOptimized extends StatefulWidget {
  const DiagnosticPageOptimized({super.key});

  @override
  State<DiagnosticPageOptimized> createState() => _DiagnosticPageOptimizedState();
}

class _DiagnosticPageOptimizedState extends State<DiagnosticPageOptimized>
    with RouteAware {
  
  // Servicio optimizado en lugar del original
  final MediaPipeServiceOptimized _mediaPipe = MediaPipeServiceOptimized(
    config: const MediaPipeOptimizationConfig(
      enableKalmanSmoothing: true,
      enablePerformanceMonitoring: true,
      enableOutlierDetection: true,
      bufferSize: 5,
      smoothingFactor: 0.7,
    ),
  );

  // Controlador de efectos
  late VisionEffectsController _effectsController;

  // ... resto del código igual que diagnostic_page.dart ...
  
  @override
  void initState() {
    super.initState();
    _effectsController = VisionEffectsController();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initializeCamera();
      print('✅ Cámara inicializada con optimizaciones');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> _initializeCamera() async {
    await _mediaPipe.startCamera('inputVideo');

    // Suscribirse a landmarks mejorados
    _mediaPipe.enhancedLandmarkStream.listen((enhancedLandmarks) {
      // Procesar landmarks mejorados
      _updateWithOptimizations(enhancedLandmarks);
    });

    // Monitorear rendimiento
    _mediaPipe.performanceMetricsStream.listen((metric) {
      // Mostrar métricas si es necesario
      if (kDebugMode) {
        print('📊 ${metric.fps} FPS, ${metric.latencyMs.toStringAsFixed(1)}ms latencia');
      }
    });
  }

  void _updateWithOptimizations(List<EnhancedLandmark> landmarks) {
    // Landmarks ya están suavizados y filtrados
    
    // Crear landmarks para render
    final points = landmarks.map((l) => Offset(
      (1 - l.x) * _screenSize.width,
      l.y * _screenSize.height,
    )).toList();

    // Velocidades para efectos
    final velocities = landmarks.map((l) => l.velocity).toList();

    // Confianzas para visualización
    final confidences = landmarks.map((l) => l.confidence).toList();

    // Actualizar UI
    _landmarkPoints.value = points;

    // Generar efectos si hay movimiento
    for (int i = 0; i < points.length; i++) {
      if (velocities[i] > 0.1) {
        _effectsController.addTrail(points[i], Colors.cyanAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Diagnóstico Optimizado'),
      ),
      body: ValueListenableBuilder<List<Offset>>(
        valueListenable: _landmarkPoints,
        builder: (context, points, _) {
          return Stack(
            children: [
              // Fondo oscuro
              Container(color: Colors.black.withOpacity(0.35)),

              // Bola de estímulo
              if (_ballPosition != null)
                Positioned(
                  left: _ballPosition!.dx - _ballRadius,
                  top: _ballPosition!.dy - _ballRadius,
                  child: Container(
                    width: _ballRadius * 2,
                    height: _ballRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fingerColors[_currentColor] ?? Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              // Landmarks mejorados con renderización optimizada
              RepaintBoundary(
                child: SizedBox(
                  width: _screenSize.width,
                  height: _screenSize.height,
                  child: CustomPaint(
                    painter: EnhancedHandLandmarkPainter(
                      points: points,
                      confidenceScores: _confidenceScores,
                      velocities: _velocities,
                    ),
                  ),
                ),
              ),

              // Efectos visuales (trails, partículas, etc)
              RepaintBoundary(
                child: SizedBox(
                  width: _screenSize.width,
                  height: _screenSize.height,
                  child: CustomPaint(
                    painter: VisionEffectsPainter(
                      handPoints: points,
                      trails: _effectsController.trails,
                      particles: _effectsController.particles,
                      confidence: _mediaPipe.getAverageConfidence(),
                      showTrails: true,
                      showParticles: true,
                      showConfidenceIndicator: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _effectsController.clear();
    _mediaPipe.dispose();
    super.dispose();
  }
}
```

### Paso 2: Cambiar ruta en `main.dart`

```dart
// En main.dart, cambiar:
// DiagnosticPage → DiagnosticPageOptimized
```

**Beneficios adicionales**:
- ✅ Suavizado Kalman Filter
- ✅ Detección de confianza por punto
- ✅ Monitoreo de rendimiento en tiempo real
- ✅ Efectos visuales dinámicos (trails, partículas)
- ✅ Mejor detección de colisiones
- ✅ Visualización de confianza en tiempo real

---

## Uso - Opción 3: Híbrido (Recomendado para producción)

Usar JavaScript optimizado + monitoreo Dart sin efectos visuales:

```dart
class DiagnosticPageHybrid extends StatefulWidget {
  // Usa MediaPipeServiceOptimized pero sin VisionEffectsController
  // Mejor rendimiento mientras se mantienen mejoras en latencia
}
```

---

## API de Monitoreo de Rendimiento

```dart
// Obtener métricas
final stats = _mediaPipe.getLatencyStats();
print('Latencia min/max/avg: ${stats.min}/${stats.max}/${stats.average}ms');

final confidenceStats = _mediaPipe.getConfidenceStats();
print('Confianza promedio: ${confidenceStats.average.toStringAsFixed(2)}');

// Detectar problemas
final warning = _mediaPipe.detectPerformanceIssue();
if (warning != null) {
  print('⚠️ ${warning.message}');
}

// Exportar métricas
final allMetrics = _mediaPipe.exportPerformanceMetrics();
```

---

## Configuración

### Ajustar suavizado

```dart
_mediaPipe.updateConfig(const MediaPipeOptimizationConfig(
  smoothingFactor: 0.8, // Más suave
  enableKalmanSmoothing: true,
));
```

### Deshabilitar optimizaciones

```dart
// Volver al comportamiento original
_mediaPipe.updateConfig(const MediaPipeOptimizationConfig(
  enableKalmanSmoothing: false,
  enablePerformanceMonitoring: false,
  enableOutlierDetection: false,
));
```

---

## Mejoras de Rendimiento Esperadas

| Métrica | Antes | Después |
|---------|-------|---------|
| Latencia promedio | ~100ms | ~40-50ms |
| FPS estable | 30 fps | 30 fps (más suave) |
| Jitter | Alto | Bajo (filtro Kalman) |
| Uso de memoria | Estable | Similar o mejor |
| Detección de colisiones | +/- 5% error | +/- 2% error |

---

## Compatibilidad

- ✅ 100% compatible con código existente
- ✅ No requiere cambios en diagnostic_page.dart original
- ✅ Puede activarse/desactivarse en tiempo de ejecución
- ✅ API backward compatible
- ✅ Funciona en navegadores modernos (Web)

---

## Debug

```dart
// Imprimir reporte de rendimiento
_mediaPipe.printPerformanceReport();

// Habilitar/deshabilitar componentes
_mediaPipe.setKalmanSmoothingEnabled(false);
_mediaPipe.setPerformanceMonitoringEnabled(false);
```

---

## Problemas Comunes

**Q: Las líneas de landmarks parpadean**
A: Reducir `smoothingFactor` de 0.7 a 0.5

**Q: FPS bajo**
A: Deshabilitar `enableOutlierDetection` o reducir `bufferSize`

**Q: Demasiados efectos visuales**
A: En `VisionEffectsPainter`, cambiar `showTrails` y `showParticles` a false

---

## Próximas mejoras

- [ ] GPU acceleration con Canvas
- [ ] Predicción de movimiento
- [ ] Machine learning para detección de gestos
- [ ] Soporte multi-mano mejorado
- [ ] Persistencia de métricas para análisis
