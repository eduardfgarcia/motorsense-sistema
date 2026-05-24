from django.urls import path
from . import views

urlpatterns = [
    path('reports/<int:session_id>/', views.download_report, name='download_report'),
]