from django.contrib.auth.models import User
from rest_framework import serializers
from .models import PerfilClinico

class PerfilClinicoSerializer(serializers.ModelSerializer):
    class Meta:
        model = PerfilClinico
        fields = ['fecha_nacimiento', 'genero', 'observaciones_medicas', 'edad']

class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True)
    
    # Recibimos el rol/tipo desde el formulario de Flutter
    tipo_usuario = serializers.CharField(write_only=True, required=False) 

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'first_name', 'last_name', 'tipo_usuario']

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Este correo ya está registrado.")
        return value

    def create(self, validated_data):
        tipo_usuario = validated_data.pop('tipo_usuario', 'paciente')
        
        # Crear el usuario base de Django
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        
        # Crear automáticamente su perfil clínico asociado
        PerfilClinico.objects.create(
            usuario=user,
            observaciones_medicas=f"Rol inicial: {tipo_usuario.capitalize()}"
        )
        
        return user