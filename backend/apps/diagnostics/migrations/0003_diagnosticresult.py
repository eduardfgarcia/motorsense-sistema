# Generated migration for DiagnosticResult model

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('diagnostics', '0002_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='DiagnosticResult',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('reaction_time_avg', models.FloatField(help_text='Promedio de tiempo de reacción en ms')),
                ('reaction_time_min', models.FloatField(help_text='Tiempo de reacción mínimo en ms')),
                ('reaction_time_max', models.FloatField(help_text='Tiempo de reacción máximo en ms')),
                ('total_trials', models.IntegerField(default=10)),
                ('correct_trials', models.IntegerField()),
                ('accuracy_percent', models.FloatField(help_text='Porcentaje de precisión 0-100')),
                ('reflex_level', models.CharField(choices=[('excellent', 'Excelente'), ('good', 'Bueno'), ('fair', 'Regular'), ('poor', 'Pobre')], default='fair', max_length=20)),
                ('neuro_score', models.FloatField(help_text='Puntuación neurológica 0-100')),
                ('focus_score', models.FloatField(help_text='Puntuación de enfoque/concentración 0-100')),
                ('consistency_score', models.FloatField(help_text='Puntuación de consistencia 0-100')),
                ('notes', models.TextField(blank=True, null=True)),
                ('pdf_report_path', models.CharField(blank=True, max_length=500, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('session', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='result', to='diagnostics.diagnosticsession')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='diagnostic_results', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'verbose_name': 'Resultado de Diagnóstico',
                'verbose_name_plural': 'Resultados de Diagnóstico',
                'ordering': ['-created_at'],
            },
        ),
        migrations.AddIndex(
            model_name='diagnosticresult',
            index=models.Index(fields=['user', '-created_at'], name='diagnostics_user_id_c7f8a9_idx'),
        ),
        migrations.AddIndex(
            model_name='diagnosticresult',
            index=models.Index(fields=['session'], name='diagnostics_session_d3c4e5_idx'),
        ),
    ]
