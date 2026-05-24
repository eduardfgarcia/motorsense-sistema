# MotorSense 🧠✋

Sistema de evaluación de coordinación motriz fina basado en visión artificial.

## Descripción
MotorSense es una aplicación web desarrollada en Flutter que utiliza MediaPipe para el seguimiento de manos en tiempo real. La aplicación evalúa la precisión y velocidad de respuesta del usuario mediante pruebas interactivas de puntería con los dedos, proporcionando métricas precisas sobre el desempeño neurológico y motor.

## Desarrolladores
- **Eduard García**
- **Eddy Gómez**

## Características
- **Seguimiento en tiempo real:** Detección de 21 puntos clave de la mano mediante visión computacional.
- **Evaluación dinámica:** Pruebas cronometradas de 30 segundos con objetivos aleatorios.
- **Análisis de datos:** Cálculo automático de tiempos de reacción, precisión y consistencia.
- **Interfaz intuitiva:** Visualización clara de objetivos, cuenta regresiva y estado de la prueba.

## Requisitos Previos
- Flutter SDK (versión 3.x o superior)
- Navegador web compatible (Google Chrome recomendado)
- Cámara web habilitada

## Instalación
1. Clona el repositorio:
   `git clone https://github.com/tu_usuario/motorsense-sistema.git`
2. Instala las dependencias:
   `flutter pub get`
3. Ejecuta la aplicación:
   `flutter run -d chrome --dart-define=FLUTTER_WEB_RENDERER=canvaskit`

## Tecnologías Utilizadas
- **Frontend:** Flutter Web
- **Visión Artificial:** MediaPipe Hands (JS Interop)
- **Gestión de estado:** Provider
- **Servicios:** API de Diagnósticos / Firebase

## Licencia
Este proyecto es desarrollado como parte de las soluciones tecnológicas de evaluación motriz.
