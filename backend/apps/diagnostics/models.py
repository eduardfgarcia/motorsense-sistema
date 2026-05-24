from django.db import models
from django.contrib.auth.models import User

class Sesion(models.Model):
    # Relación de 1 a Muchos: Un usuario tiene muchas sesiones
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sesiones')
    fecha_hora_inicio = models.DateTimeField(auto_now_add=True)
    fecha_hora_fin = models.DateTimeField(null=True, blank=True)
    tipo_prueba = models.CharField(max_length=100) # Ej: "Rapidez Mental", "Reflejos"
    puntaje_total = models.DecimalField(max_length=5, max_digits=5, decimal_places=2, default=0.00)
    observaciones = models.TextField(null=True, blank=True)

    def __str__(self):
        return f"Sesión {self.id} - {self.usuario.username} ({self.tipo_prueba})"

class ResultadoReflejo(models.Model):
    # Relación de 1 a Muchos: Una sesión contiene múltiples resultados/intentos
    sesion = models.ForeignKey(Sesion, on_delete=models.CASCADE, related_name='resultados_reflejo')
    tiempo_reaccion_ms = models.IntegerField()
    tipo_movimiento = models.CharField(max_length=100) # Ej: "Extensión", "Flexión"
    precision_porcentaje = models.DecimalField(max_digits=5, decimal_places=2)
    latencia_registrada_ms = models.IntegerField() # Vital para tu motor de compensación de lag

    def __str__(self):
        return f"Resultado {self.id} de la Sesión {self.sesion.id}"