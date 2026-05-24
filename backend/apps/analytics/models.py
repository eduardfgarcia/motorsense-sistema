 
from django.db import models
from django.contrib.auth.models import User
from apps.diagnostics.models import Sesion

class ReporteClinico(models.Model):
    # Relaciones tal como se plasman en tu diagrama
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reportes_clinicos')
    sesion = models.ForeignKey(Sesion, on_delete=models.CASCADE, related_name='reportes_asociados')
    fecha_generacion = models.DateTimeField(auto_now_add=True)
    ruta_archivo_pdf = models.CharField(max_length=255) # Dirección física o URL en el servidor
    generado_por = models.CharField(max_length=150) # Nombre del Especialista o sistema autónomo

    def __str__(self):
        return f"Reporte PDF {self.id} - Usuario: {self.usuario.username}"