from django.db import models
from django.contrib.auth.models import User

class PerfilClinico(models.Model):
    GENERO_CHOICES = [
        ('M', 'Masculino'),
        ('F', 'Femenino'),
        ('O', 'Otro'),
    ]

    # Relación 1 a 1 con el usuario de Django (id_Usuario)
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil_clinico')
    fecha_nacimiento = models.DateField(null=True, blank=True)
    genero = models.CharField(max_length=1, choices=GENERO_CHOICES, null=True, blank=True)
    observaciones_medicas = models.TextField(null=True, blank=True)
    edad = models.IntegerField(null=True, blank=True)

    def __str__(self):
        return f"Perfil de {self.usuario.username}"