from rest_framework import serializers
from .models import Sesion, ResultadoReflejo

class ResultadoReflejoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ResultadoReflejo
        fields = ['id', 'sesion', 'tiempo_reaccion_ms', 'tipo_movimiento', 'precision_porcentaje', 'latencia_registrada_ms']

class SesionSerializer(serializers.ModelSerializer):
    # Usamos 'resultados_reflejo' porque es el related_name que definiste en tu ForeignKey
    resultados_reflejo = ResultadoReflejoSerializer(many=True, read_only=True)

    class Meta:
        model = Sesion
        fields = ['id', 'usuario', 'fecha_hora_inicio', 'fecha_hora_fin', 'tipo_prueba', 'puntaje_total', 'observaciones', 'resultados_reflejo']
        read_only_fields = ['usuario', 'fecha_hora_inicio']