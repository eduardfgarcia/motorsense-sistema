from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer

class RegisterView(APIView):
    # Permite que usuarios sin loguearse (públicos) puedan acceder a este endpoint
    permission_classes = [AllowAny]

    def post(self, request):
        # Mapeamos 'tipo_usuario' si en el frontend mandas la variable como 'role'
        data = request.data.copy()
        if 'role' in data and 'tipo_usuario' not in data:
            data['tipo_usuario'] = data['role']

        serializer = RegisterSerializer(data=data)
        
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {
                    "status": "success",
                    "message": "Usuario registrado exitosamente.",
                    "user_id": user.id
                }, 
                status=status.HTTP_201_CREATED
            )
            
        # Si hay errores de validación (ej: campos vacíos, usuario o correo repetido)
        return Response(
            {
                "status": "error",
                "message": serializer.errors
            }, 
            status=status.HTTP_400_BAD_REQUEST
        )

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response(
                {"status": "error", "message": "Por favor, ingresa usuario y contraseña."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = authenticate(username=username, password=password)

        if user is not None:
            # --- AQUÍ ESTÁ EL CAMBIO ---
            refresh = RefreshToken.for_user(user)
            
            return Response({
                "status": "success",
                "message": "Inicio de sesión exitoso.",
                "token": str(refresh.access_token), # <--- ESTO ES LO QUE FLUTTER ESPERA
                "user": {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email
                }
            }, status=status.HTTP_200_OK)
        
        return Response(
            {"status": "error", "message": "Credenciales inválidas o cuenta inexistente."},
            status=status.HTTP_401_UNAUTHORIZED
        )