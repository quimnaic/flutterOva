import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ova_se/screens/home.dart';
import 'package:ova_se/screens/profiler.dart';
import 'package:ova_se/screens/setting.dart';
import 'package:ova_se/screens/login.dart'; // 👈 Agrega este import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const OvaSeApp());
}

class OvaSeApp extends StatelessWidget {
  const OvaSeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainApp(),
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      secondary: const Color(0xFF0D9488),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        elevation: 3,
        shadowColor: Colors.black12,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SHELL — Splash → Login → App
// ─────────────────────────────────────────────

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  // 3 fases: splash → login → app
  _Fase _fase = _Fase.splash;
  int _indiceActual = 0;

  late AnimationController _splashController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  final List<Widget> _paginas = const [
    HomeScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeIn),
    );

    _splashController.forward();
    _iniciarAnimacion();
  }

  void _iniciarAnimacion() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      // Al terminar el splash, va al Login (no directo al Home)
      setState(() => _fase = _Fase.login);
    }
  }

  /// Callback que llama LoginScreen cuando el login es exitoso
  void _onLoginExitoso() {
    setState(() => _fase = _Fase.profiler);
  }

  /// Callback para cerrar sesión
  void _onLogout() {
    setState(() {
      _fase = _Fase.login;
      _indiceActual = 0; // Opcional: vuelve a la primera pestaña para la próxima vez
    });
  }

  void _onProfilerFinalizado() {
    setState(() => _fase = _Fase.app);
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (_fase) {
      case _Fase.splash:
        return _buildSplash(colorScheme);

      case _Fase.login:
        // Pasamos el callback para saber cuándo el login fue exitoso
        return LoginScreen(onLoginExitoso: _onLoginExitoso);

      case _Fase.profiler:
        return ProfilerScreen(onProfilerFinalizado: _onProfilerFinalizado);

      case _Fase.app:
        return _buildApp(colorScheme);
    }
  }

  // ── App principal con navbar ────────────────
  Widget _buildApp(ColorScheme colorScheme) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Hero(
              tag: 'logo_hero',
              child: Image.asset('assets/logo.png', height: 80),
            ),
            actions: [
              IconButton(onPressed: _onLogout, icon: const Icon(Icons.logout, color: Colors.white))
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(_indiceActual),
          child: _paginas[_indiceActual],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (index) =>
            setState(() => _indiceActual = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Config',
          ),
        ],
      ),
    );
  }

  // ── Pantalla de splash ──────────────────────
  Widget _buildSplash(ColorScheme colorScheme) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Hero(
                tag: 'logo_hero',
                child: Image.asset('assets/logo.png', height: 180),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enum para manejar las 3 fases de la app
enum _Fase { splash, login, profiler, app }