 
from django.http import FileResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from apps.diagnostics.models import DiagnosticSession
from .report_generator import generate_session_report

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_report(request, session_id):
    session = DiagnosticSession.objects.get(pk=session_id)
    buffer = generate_session_report(session)
    return FileResponse(buffer, as_attachment=True, filename=f'reporte_sesion_{session_id}.pdf')