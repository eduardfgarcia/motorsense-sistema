from django.contrib import admin
from .models import Sesion, ResultadoReflejo

@admin.register(Sesion)
class SesionAdmin(admin.ModelAdmin):
    list_display = ('id', 'usuario', 'tipo_prueba', 'puntaje_total', 'fecha_hora_inicio')
    list_filter = ('tipo_prueba', 'fecha_hora_inicio')
    search_fields = ('usuario__username', 'tipo_prueba')

@admin.register(ResultadoReflejo)
class ResultadoReflejoAdmin(admin.ModelAdmin):
    list_display = ('id', 'sesion', 'tipo_movimiento', 'tiempo_reaccion_ms', 'precision_porcentaje')