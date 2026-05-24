from reportlab.pdfgen import canvas
from io import BytesIO

def generate_session_report(session):
    buffer = BytesIO()
    p = canvas.Canvas(buffer)
    p.drawString(100, 750, f"Reporte de Sesión #{session.id}")
    p.drawString(100, 730, f"Paciente: {session.patient.username}")
    y = 700
    trials = session.trials.order_by('trial_number')
    for trial in trials:
        estado = "OK" if trial.is_correct else "FALLO"
        p.drawString(100, y, f"Intento {trial.trial_number}: {trial.reaction_time_ms:.1f} ms - {estado}")
        y -= 20
    p.showPage()
    p.save()
    buffer.seek(0)
    return buffer