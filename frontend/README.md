# MotorSense 🛠️🧠

MotorSense es un sistema de ingeniería modular diseñado para el diagnóstico de motores mediante visión artificial. El proyecto integra un **Frontend** robusto desarrollado en Flutter (Dart) para la interfaz de usuario y visualización de datos, conectado a un **Backend** de alto rendimiento en Django (Python) que gestiona la lógica de negocio, la API REST, la autenticación segura y el procesamiento de imágenes/visión artificial de bajo nivel.

## Desarrolladores
* **Eduard García**
* **Eddy Gómez**

---

## 📊 Arquitectura del Proyecto y Lenguajes

El proyecto está estructurado de manera limpia y profesional bajo un modelo de **Monorepo**, separando el ciclo de vida del Frontend y del Backend para garantizar la escalabilidad y facilitar el despliegue.

* **Frontend (62.9%):** Desarrollado en **Dart** con el SDK de **Flutter** para lograr una experiencia nativa y fluida (soporte multiplataforma listo para Web, Escritorio y Móvil).
* **Backend & API (14.1%):** Construido en **Python** empleando **Django REST Framework**.
* **Visión Artificial & Compilación (18.7%):** Integración de módulos nativos en **C++** y **CMake** para interactuar con librerías de procesamiento de bajo nivel como MediaPipe, garantizando precisión y latencia mínima.

---

## 🛠️ Requisitos Previos

Antes de desplegar el proyecto en una nueva máquina, asegúrese de tener instalado:

1.  **Python** (Versión 3.11 recomendada).
2.  **Flutter SDK** (Configurado correctamente en las variables de entorno del sistema / `PATH`).
3.  **Git** (Para control de versiones).

---

## 🚀 Guía de Despliegue y Ejecución

Siga estos pasos en orden estricto para levantar el sistema completo en cualquier entorno de pruebas local.

### 1. Clonar el Repositorio
Abra una terminal y descargue el código fuente:
`
git clone <URL_DE_TU_REPOSITORIO_DE_GITHUB>
cd motorsense-sistema-main`

## 2. Configuración del Backend (Django)
Abra una ventana de la terminal y navegue hasta el directorio del servidor:

`cd backend`

## A. Crear y activar el Entorno Virtual (venv)

# Crear entorno virtual
`python -m venv venv`

# Activar en Windows (PowerShell / CMD)
`venv\Scripts\activate`

# Activar en Linux / macOS
`source venv/bin/activate`

## B. Instalación de Dependencias Críticas
Es obligatorio instalar los paquetes en el orden verificado durante las pruebas de portabilidad para evitar conflictos de importación:

`python -m pip install django djangorestframework django-cors-headers djangorestframework-simplejwt opencv-python pillow mediapipe`

## C. Aplicar Migraciones y Arrancar el Servidor
Prepare la base de datos local y levante el servicio de la API:
`
python manage.py migrate
python manage.py runserver`

## 3. Configuración del Frontend (Flutter)
Abra una nueva ventana de la terminal (sin cerrar el backend) y navegue a la carpeta correspondiente:

`cd frontend`

## A. Descargar Paquetes de Dart
Instale todas las dependencias declaradas en el pubspec.yaml:

`flutter pub get`

## B. Verificar Dispositivos Disponibles
Consulte las pantallas o entornos listos para renderizar la aplicación:

`flutter devices`

## C. Ejecutar la Aplicación
Inicie el Frontend. Si se despliega para entorno Web o escritorio en la misma máquina, se conectará de inmediato a la dirección local del backend:

`flutter run -d chrome --dart-define=FLUTTER_WEB_RENDERER=canvaskit`


## 🗄️ Panel Administrativo de la Base de Datos (Django Admin)
El backend incluye un panel de administración integrado para inspeccionar y gestionar de forma visual las tablas de la base de datos (usuarios registrados, historiales de diagnóstico, tokens, etc.).

## Acceso al Panel Visual
Por defecto para acceder al panel visual con el servidor corriendo (`python manage.py runserver`), abra cualquier navegador web e ingrese a la siguiente dirección URL: 

👉 `http://127.0.0.1:8000/admin/`

el superusuario predeterminado es:

`usuario: admin123
contraseña: 123456`

Para poder ingresar al panel en una máquina nueva, es necesario generar credenciales de acceso. En la terminal del backend (con el entorno virtual activo), ejecute el siguiente comando:

`python manage.py createsuperuser`

El sistema le solicitará interactivamente los siguientes datos:

Username: Ingrese un nombre de usuario (ej. `admin`).

- Email address: Puede dejarlo en blanco y presionar Enter.

- Password: Ingrese una contraseña (por seguridad de la terminal, los caracteres no se mostrarán mientras escribe, digítela y presione Enter).

- Password (again): Confirme la contraseña.

Introduzca el usuario y la contraseña recién creados para visualizar, editar o auditar el estado actual de la base de datos del sistema.


