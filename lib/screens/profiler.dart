import 'package:flutter/material.dart';

class ProfilerScreen extends StatefulWidget {

  final VoidCallback onProfilerFinalizado;

  const ProfilerScreen({super.key, required this.onProfilerFinalizado});

  @override
  State<ProfilerScreen> createState() => _ProfilerScreenState();
}

class _ProfilerScreenState extends State<ProfilerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Estructura de las preguntas basada en tu prompt
  final List<Map<String, dynamic>> _preguntas = [
    {
      'bloque': 'Fundamentos y Conceptos',
      'pregunta': '¿Alguna vez has escuchado hablar de cómo "aprende" una máquina?',
      'opciones': [
        'Nunca, creo que es magia.',
        'He escuchado algo, pero no sé cómo funciona.',
        'Sé que usan datos para encontrar patrones.',
      ],
    },
    {
      'bloque': 'Fundamentos y Conceptos',
      'pregunta': 'Si tuvieras que explicar qué es un "Sistema Experto", ¿qué dirías?',
      'opciones': [
        'No tengo ni idea.',
        'Es un programa que toma decisiones como un humano.',
        'Es una base de conocimientos con reglas lógicas.',
      ],
    },
    {
      'bloque': 'Percepción y Barreras',
      'pregunta': '¿Crees que para crear una IA es obligatorio saber programar complejo?',
      'opciones': [
        'Sí, definitivamente.',
        'Creo que ayuda, pero debe haber otras formas.',
        'No, se pueden usar herramientas visuales o "sin código".',
      ],
    },
    {
      'bloque': 'Intereses',
      'pregunta': '¿En qué área te gustaría ver cómo la IA toma decisiones?',
      'opciones': [
        'Videojuegos y Entretenimiento.',
        'Salud y Medicina (diagnósticos).',
        'Medio ambiente y Ciencia.',
        'Redes sociales y recomendación.',
      ],
    },
  ];

  void _nextPage() {
    if (_currentPage < _preguntas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Aquí manejarías el final del quiz (ej. enviar a API o volver al home)
      widget.onProfilerFinalizado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double progreso = (_currentPage + 1) / _preguntas.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario Diagnóstico', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Barra de progreso animada al estilo de tu Home
          _buildCustomProgress(colorScheme, progreso),
          
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Evita scroll manual
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: _preguntas.length,
              itemBuilder: (context, index) {
                final item = _preguntas[index];
                return _buildQuestionPage(colorScheme, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomProgress(ColorScheme colorScheme, double value) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pregunta ${_currentPage + 1} de ${_preguntas.length}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
              Text('${(value * 100).toInt()}%',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(ColorScheme colorScheme, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['bloque'].toUpperCase(),
              style: TextStyle(color: colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item['pregunta'],
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 32),
          ...List.generate(item['opciones'].length, (index) {
            return _buildOptionCard(colorScheme, item['opciones'][index]);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard(ColorScheme colorScheme, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _nextPage, // Al seleccionar, avanza
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surface,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}