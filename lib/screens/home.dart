import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;

  // Simulated study progress
  final double _progreso = 0.35;
  final int _leccionesCompletadas = 4;
  final int _totalLecciones = 12;
  final int _racha = 3; // días de racha

  final List<Map<String, dynamic>> _modulos = [
    {
      'titulo': 'Introducción a SE',
      'descripcion': 'Conceptos fundamentales',
      'icono': Icons.lightbulb_outline_rounded,
      'progreso': 0.8,
      'color': Color(0xFF4F46E5),
    },
    {
      'titulo': 'Lógica y Reglas',
      'descripcion': 'Motor de inferencia',
      'icono': Icons.account_tree_outlined,
      'progreso': 0.4,
      'color': Color(0xFF0D9488),
    },
    {
      'titulo': 'Base de Conocimiento',
      'descripcion': 'Representación del conocimiento',
      'icono': Icons.storage_rounded,
      'progreso': 0.1,
      'color': Color(0xFF7C3AED),
    },
    {
      'titulo': 'Incertidumbre',
      'descripcion': 'Razonamiento bajo incertidumbre',
      'icono': Icons.psychology_outlined,
      'progreso': 0.0,
      'color': Color(0xFFDB2777),
    },
  ];

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardsController, curve: Curves.easeOut));

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  String _getSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return '¡Buenos días! 🌤️';
    if (hora < 18) return '¡Buenas tardes! ☀️';
    return '¡Buenas noches! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO HEADER ──────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: SlideTransition(
                position: _headerSlide,
                child: _buildHeader(colorScheme),
              ),
            ),

            const SizedBox(height: 24),

            // ── STATS ROW ────────────────────────────
            SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStatsRow(colorScheme),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── CUESTIONARIO CTA ─────────────────────
            SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCuestionarioCTA(colorScheme),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── MÓDULOS ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Módulos de estudio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 14),

            SlideTransition(
              position: _cardsSlide,
              child: FadeTransition(
                opacity: _cardsFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildModulosGrid(colorScheme),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── HEADER con gradiente ────────────────────
  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getSaludo(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sistemas Expertos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso general',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '${(_progreso * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progreso,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATS ────────────────────────────────────
  Widget _buildStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatCard(
          colorScheme,
          icon: Icons.check_circle_outline_rounded,
          valor: '$_leccionesCompletadas/$_totalLecciones',
          label: 'Lecciones',
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          colorScheme,
          icon: Icons.local_fire_department_rounded,
          valor: '$_racha días',
          label: 'Racha',
          color: const Color(0xFFEA580C),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          colorScheme,
          icon: Icons.emoji_events_outlined,
          valor: '120 pts',
          label: 'Puntos',
          color: const Color(0xFFCA8A04),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme, {
    required IconData icon,
    required String valor,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CTA CUESTIONARIO ─────────────────────────
  Widget _buildCuestionarioCTA(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navegar al cuestionario
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF7C3AED),
                colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cuestionario diagnóstico',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crea tu plan de estudio personalizado',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GRID DE MÓDULOS ──────────────────────────
  Widget _buildModulosGrid(ColorScheme colorScheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _modulos.length,
      itemBuilder: (context, index) {
        final modulo = _modulos[index];
        return _buildModuloCard(colorScheme, modulo);
      },
    );
  }

  Widget _buildModuloCard(ColorScheme colorScheme, Map<String, dynamic> modulo) {
    final color = modulo['color'] as Color;
    final progreso = modulo['progreso'] as double;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(modulo['icono'] as IconData, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                modulo['titulo'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              Text(
                modulo['descripcion'],
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        minHeight: 5,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progreso * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}