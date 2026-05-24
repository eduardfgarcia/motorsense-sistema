import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/diagnostics_services.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DiagnosticsService _diagnosticService = DiagnosticsService();
  late Future<List<dynamic>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  void _loadHistorial() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _historialFuture = _diagnosticService.obtenerHistorial(auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Historial Clínico"),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error al cargar el historial:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No hay registros.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final sesiones = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sesiones.length,
            itemBuilder: (context, index) {
              final sesion = sesiones[index] as Map<String, dynamic>;
              final fecha = sesion['fecha_hora_inicio'] ??
                  sesion['fecha_creacion'] ??
                  'N/A';
              final observaciones = sesion['observaciones'] as String?;
              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.cyanAccent),
                  title: Text(
                    sesion['tipo_prueba'] ?? 'Prueba',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fecha: ${fecha.toString().split('T').first}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      if (observaciones != null && observaciones.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            observaciones,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${sesion['puntaje_total']} pts",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
