from django.urls import path
from .views import GuardarSesionView
from .views import HistorialSesionesView
from .views import EliminarSesionView
from .views import eliminar_historial

urlpatterns = [
    path('guardar/', GuardarSesionView.as_view(), name='guardar_sesion'),
    path('historial/', HistorialSesionesView.as_view(), name='historial_sesiones'),
    path('eliminar/<int:pk>/', EliminarSesionView.as_view(), name='eliminar_sesion'),
    path('eliminar_historial/', eliminar_historial, name='eliminar_historial'),
]