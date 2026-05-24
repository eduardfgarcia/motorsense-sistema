from django.contrib import admin
from django.urls import path, include  # Asegúrate de importar 'include'

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Al usar include, todas las rutas de la app 'users' se colgarán de 'users/'
    path('api/users/', include('apps.users.urls')),
    path('api/diagnostics/', include('apps.diagnostics.urls')),  # Rutas para la app de diagnósticos
]