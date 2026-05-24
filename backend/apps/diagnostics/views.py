from django.db import OperationalError
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from rest_framework.views import APIView, csrf_exempt
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import ListAPIView
from .models import Sesion, ResultadoReflejo
from .serializers import SesionSerializer

class GuardarSesionView(APIView):
    # Protegemos el endpoint para que requiera inicio de sesión previo
    permission_classes = [IsAuthenticated]

    def post(self, request):
        tipo_prueba = request.data.get('tipo_prueba', 'Reflejos')
        puntaje_total = request.data.get('puntaje_total', 0.00)
        observaciones = request.data.get('observaciones', '')
        lista_resultados = request.data.get('resultados', [])

        try:
            # 1. Crear la sesión amarrada al usuario actual (request.user)
            sesion = Sesion.objects.create(
                usuario=request.user,
                tipo_prueba=tipo_prueba,
                puntaje_total=puntaje_total,
                observaciones=observaciones
            )

            # 2. Iterar e insertar cada intento/disparo detectado por la cámara
            for res in lista_resultados:
                ResultadoReflejo.objects.create(
                    sesion=sesion,
                    tiempo_reaccion_ms=res.get('tiempo_reaccion_ms'),
                    tipo_movimiento=res.get('tipo_movimiento', 'Extensión'),
                    precision_porcentaje=res.get('precision_porcentaje', 100.00),
                    latencia_registrada_ms=res.get('latencia_registrada_ms', 0)
                )

            # Serializamos la información completa para retornar la respuesta
            serializer = SesionSerializer(sesion)
            return Response({
                "status": "success",
                "message": "Resultados clínicos de la sesión almacenados correctamente.",
                "data": serializer.data
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({
                "status": "error",
                "message": f"No se pudo almacenar el diagnóstico: {str(e)}"
            }, status=status.HTTP_400_BAD_REQUEST)


class HistorialSesionesView(ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = SesionSerializer

    def get_queryset(self):
        # Filtramos para que el usuario solo vea SUS sesiones
        return Sesion.objects.filter(usuario=self.request.user).order_by('-fecha_hora_inicio')


class EliminarSesionView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            pk = int(pk)
        except (TypeError, ValueError):
            return Response(
                {"status": "error", "message": "ID de sesión inválido."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            sesion = Sesion.objects.get(pk=pk, usuario=request.user)
        except Sesion.DoesNotExist:
            return Response(
                {"status": "error", "message": "Sesión no encontrada."},
                status=status.HTTP_404_NOT_FOUND,
            )

        sesion.delete()
        return Response(
            {
                "status": "success",
                "message": "Sesión eliminada correctamente.",
                "deleted_id": pk,
            },
            status=status.HTTP_200_OK,
        )

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def eliminar_historial(request):
    print(f"Usuario autenticado: {request.user}")
    print(f"Auth header recibido: {request.META.get('HTTP_AUTHORIZATION')}")
    if not getattr(request, "user", None) or not request.user.is_authenticated:
        return JsonResponse(
            {
                "status": "error",
                "message": "No autenticado. Inicia sesión nuevamente.",
            },
            status=401,
        )

    try:
        deleted_count, _ = Sesion.objects.filter(usuario=request.user).delete()
        return JsonResponse(
            {
                "status": "success",
                "message": "Historial eliminado correctamente.",
                "deleted_count": deleted_count,
            },
            status=200,
        )
    except OperationalError as exc:
        return JsonResponse(
            {
                "status": "error",
                "message": "Error de base de datos al eliminar el historial.",
                "details": str(exc),
            },
            status=500,
        )
    except Exception as exc:
        return JsonResponse(
            {
                "status": "error",
                "message": "No se pudo eliminar el historial.",
                "details": str(exc),
            },
            status=500,
        )