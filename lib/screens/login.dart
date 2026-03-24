import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  /// Callback que se ejecuta cuando el login es exitoso.
  /// MainApp lo usa para cambiar de fase sin Navigator.
  final VoidCallback onLoginExitoso;

  const LoginScreen({super.key, required this.onLoginExitoso});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final usuario = _usuarioController.text.trim();
    final clave = _claveController.text.trim();

    // ── CREDENCIALES ─────────────────────────────────────────────────
    // Cambia 'admin' / 'admin' por las credenciales que necesites.
    if (usuario == 'admin' && clave == 'admin') {
      widget.onLoginExitoso(); // 👈 Le avisa al MainApp para cambiar de fase
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // ── HEADER CON GRADIENTE ──────────────────────────────
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.psychology_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 24),
                      const Text('Bienvenido',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 4),
                      const Text('Sistemas Expertos',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar tu aprendizaje',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // ── FORMULARIO ───────────────────────────────────────
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(colorScheme, 'Usuario'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _usuarioController,
                              colorScheme: colorScheme,
                              hint: 'Ingresa tu usuario',
                              icon: Icons.person_outline_rounded,
                              validator: (val) => (val == null || val.trim().isEmpty)
                                  ? 'El usuario es requerido'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            _buildLabel(colorScheme, 'Contraseña'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _claveController,
                              colorScheme: colorScheme,
                              hint: 'Ingresa tu contraseña',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (val) => (val == null || val.trim().isEmpty)
                                  ? 'La contraseña es requerida'
                                  : null,
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded,
                                        color: colorScheme.onErrorContainer,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const Spacer(),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    const Color(0xFF7C3AED),
                                    colorScheme.primary,
                                  ]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _iniciarSesion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white),
                                        )
                                      : const Text('Iniciar sesión',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ColorScheme colorScheme, String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ColorScheme colorScheme,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
          fontSize: 15,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: colorScheme.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error, width: 1.8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}