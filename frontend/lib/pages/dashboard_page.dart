import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'camera_page.dart';
import 'history_page.dart';
import 'login_page.dart';

const Color dashboardBackground = Color(0xFF0A0F21);
const Color dashboardPrimary = Color(0xFF00FFFF);
const Color dashboardAccent = Color(0xFF007BFF);
const Color dashboardTileBackground = Color(0xFF141C31);
const Color dashboardSurface = Color(0xFF18213A);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final AnimationController _backgroundController;

  final GlobalKey _testSectionKey = GlobalKey();
  final GlobalKey _featuresSectionKey = GlobalKey();
  final GlobalKey _riskSectionKey = GlobalKey();
  final GlobalKey _teamSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  Future<void> _openCamera() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  Future<void> _logoutAndGoToLogin() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _handleTabTap(int index) {
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }

    switch (index) {
      case 0:
        _openCamera();
        break;
      case 1:
        _scrollToSection(_featuresSectionKey);
        break;
      case 2:
        _scrollToSection(_riskSectionKey);
        break;
      case 3:
        _scrollToSection(_teamSectionKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthProvider>().username;

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, _) {
        final pulse = _backgroundController.value;
        final glowColor = Color.lerp(
          dashboardBackground,
          dashboardPrimary,
          pulse * 0.24,
        )!;
        final tintColor = Color.lerp(
          dashboardBackground,
          dashboardAccent,
          pulse * 0.12,
        )!;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.7),
                radius: 1.3,
                colors: [glowColor, tintColor, dashboardBackground],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderSection(
                        username: username,
                        onLogout: _logoutAndGoToLogin,
                      ),
                      const SizedBox(height: 24),
                      QuickActionsCard(
                        key: _testSectionKey,
                        onStartTest: _openCamera,
                        onHistory: _openHistory,
                      ),
                      const SizedBox(height: 20),
                      SectionNavigation(
                        tabController: _tabController,
                        onTap: _handleTabTap,
                      ),
                      const SizedBox(height: 24),
                      FeatureGrid(key: _featuresSectionKey),
                      const SizedBox(height: 24),
                      RiskMatrixSection(key: _riskSectionKey),
                      const SizedBox(height: 24),
                      TeamSection(key: _teamSectionKey),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeaderSection extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const HeaderSection({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        color: dashboardSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: dashboardPrimary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIENVENIDO :D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'MotorSense',
                      style: TextStyle(
                        color: dashboardPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\n\nEn la vida cotidiana, los reflejos no solo importan en el deporte; también son clave al conducir, al reaccionar ante un imprevisto o incluso durante un proceso de rehabilitación física. Este vacío tecnológico —herramientas costosas vs. necesidad de medición accesible— constituye el núcleo del problema que MotorSense busca resolver. \n\nMotorSense es una plataforma web orientada al análisis clínico de coordinación motriz fina mediante técnicas de visión artificial y procesamiento de movimiento en tiempo real. La solución fue concebida como una herramienta tecnológica capaz de capturar, interpretar y registrar patrones de interacción motriz utilizando una cámara convencional y modelos de detección de landmarks de mano.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Volver al login',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  backgroundColor: dashboardAccent.withValues(alpha: 0.18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onStartTest;
  final VoidCallback onHistory;

  const QuickActionsCard({
    super.key,
    required this.onStartTest,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dashboardSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: dashboardAccent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inicio rápido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Inicia una evaluación, revisa el historial clínico y accede a las secciones clave del producto desde aquí.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ExplorerButton(onPressed: onStartTest),
              SecondaryActionButton(
                icon: Icons.history,
                label: 'VER HISTORIAL',
                onPressed: onHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionNavigation extends StatelessWidget {
  final TabController tabController;
  final ValueChanged<int> onTap;

  const SectionNavigation({
    super.key,
    required this.tabController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelPadding: EdgeInsets.zero,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: [
        TabItem(
            icon: Icons.code,
            label: 'PROBAR',
            isActive: tabController.index == 0),
        TabItem(
            icon: Icons.hub,
            label: 'FUNCIONES',
            isActive: tabController.index == 1),
        TabItem(
            icon: Icons.security,
            label: 'RIESGO',
            isActive: tabController.index == 2),
        TabItem(
            icon: Icons.people,
            label: 'EQUIPO',
            isActive: tabController.index == 3),
      ],
      onTap: onTap,
    );
  }
}

class TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const TabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? dashboardAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.hub,
        'name': 'Detección Landmark',
        'gradient': const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
        ),
      },
      {
        'icon': Icons.speed,
        'name': 'Análisis Latencia',
        'gradient': const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
      },
      {
        'icon': Icons.security,
        'name': 'Cifrado TLS/SSL',
        'gradient': const LinearGradient(
          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
        ),
      },
      {
        'icon': Icons.show_chart,
        'name': 'Filtro Gaussiano',
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
      },
      {
        'icon': Icons.camera_alt,
        'name': 'Calibración Real',
        'gradient': const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
      },
      {
        'icon': Icons.picture_as_pdf,
        'name': 'Reportes PDF',
        'gradient': const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        ),
      },
      {
        'icon': Icons.access_time,
        'name': 'Historial Clínico',
        'gradient': const LinearGradient(
          colors: [Color(0xFFF9D423), Color(0xFFF83600)],
        ),
      },
      {
        'icon': Icons.supervised_user_circle,
        'name': 'Multifactorial',
        'gradient': const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        ),
      },
      {
        'icon': Icons.dns,
        'name': 'Persistencia DB',
        'gradient': const LinearGradient(
          colors: [Color(0xFFDBE6FD), Color(0xFFB4C6FC)],
        ),
      },
      {
        'icon': Icons.cloud_sync,
        'name': 'Cloud Sync',
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
        ),
      },
    ];

    return _SectionCard(
      title: 'FUNCIONALIDADES',
      subtitle:
          'Capas visuales, métricas y analítica avanzada con colores dinámicos.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final feature = features[index];
          return FeatureTile(
            icon: feature['icon'] as IconData,
            name: feature['name'] as String,
            gradient: feature['gradient'] as LinearGradient,
            delay: index * 0.06,
          );
        },
      ),
    );
  }
}

class FeatureTile extends StatefulWidget {
  final IconData icon;
  final String name;
  final LinearGradient gradient;
  final double delay;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.name,
    required this.gradient,
    required this.delay,
  });

  @override
  State<FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final float =
              Curves.easeOutBack.transform(_controller.value.clamp(0.0, 1.0));
          final scale = _hovered ? 1.03 : 1.0;

          return Transform.scale(
            scale: 0.92 + (float * 0.08) * scale,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withValues(alpha: 0.32),
                    blurRadius: _hovered ? 18 : 8,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 34),
                  const SizedBox(height: 12),
                  Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RiskMatrixSection extends StatelessWidget {
  const RiskMatrixSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cells = [
      {
        'title': 'Latencia crítica',
        'severity': 'ALTO',
        'description': 'Sobra de respuesta y regresión visual',
        'color': const Color(0xFFFF5C5C),
      },
      {
        'title': 'Falsos positivos',
        'severity': 'MEDIO',
        'description': 'Ajustes finos de umbral',
        'color': const Color(0xFFFFC857),
      },
      {
        'title': 'Pérdida de señal',
        'severity': 'BAJO',
        'description': 'Recalibración de cámara y foco',
        'color': const Color(0xFF57D9A3),
      },
      {
        'title': 'Carga de datos',
        'severity': 'MEDIO',
        'description': 'Optimización de almacenamiento',
        'color': const Color(0xFF7B8CFF),
      },
    ];

    return _SectionCard(
      title: 'MATRIZ DE RIESGO',
      subtitle:
          'Identifica nivel de exposición y prioriza acciones con una vista rápida.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cells.map((cell) {
          final color = cell['color'] as Color;
          return Container(
            width: 230,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: dashboardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    cell['severity'] as String,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cell['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cell['description'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final developers = [
      {
        'name': 'Eduard Garcia',
        'role': 'Programador y desarrollador de código',
        'detail':
            'Desarrollo técnico, integración de funcionalidades y lógica del producto.',
      },
      {
        'name': 'Eddy Gomez',
        'role': 'Análisis y documentación',
        'detail':
            'Documentación técnica, análisis del proyecto y soporte de contenido.',
      },
    ];

    return _SectionCard(
      title: 'DESARROLLADORES',
      subtitle:
          'Equipo técnico alineado para entregar una experiencia segura y usable.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: developers.map((developer) {
          return Container(
            width: 280,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: dashboardSurface,
              borderRadius: BorderRadius.circular(22),
              border:
                  Border.all(color: dashboardAccent.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: dashboardPrimary.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            developer['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            developer['role'] as String,
                            style: const TextStyle(
                              color: dashboardPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  developer['detail'] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dashboardSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: dashboardPrimary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class ExplorerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExplorerButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: dashboardAccent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: dashboardAccent.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'EXPLORAR TECNOLOGÍA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SecondaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: dashboardAccent),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: dashboardPrimary),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
