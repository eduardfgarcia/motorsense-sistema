import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

// ¡Asegúrate de importar tu pantalla principal aquí!
// import 'pages/diagnostic_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.initAuth(); // Carga el token antes de arrancar

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroFit',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      // El "portero" inteligente
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Cambia 'DiagnosticPage()' por el nombre de tu clase principal real
          return auth.isAuthenticated
              ? const DashboardPage()
              : const LoginPage();
        },
      ),
    );
  }
}
