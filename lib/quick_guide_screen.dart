import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'profile_widgets.dart';

class QuickGuideScreen extends StatefulWidget {
  const QuickGuideScreen({super.key});

  @override
  State<QuickGuideScreen> createState() => _QuickGuideScreenState();
}

class _QuickGuideScreenState extends State<QuickGuideScreen> {
  final _controller = PageController();
  int _currentStep = 0;

  static const _steps = [
    (
      icon: Icons.restaurant_menu,
      title: 'Explora nuestro menú',
      description: 'Descubre hamburguesas, acompañamientos y bebidas. Elige lo que más te provoque.',
    ),
    (
      icon: Icons.add_shopping_cart_outlined,
      title: 'Personaliza y agrega productos',
      description: 'Elige tus ingredientes favoritos y agrega productos a tu carrito cuando el módulo de menú esté disponible.',
    ),
    (
      icon: Icons.receipt_long_outlined,
      title: 'Confirma tu pedido',
      description: 'Revisa tus productos y el total antes de confirmar. En este proyecto no se realizan pedidos ni cobros reales.',
    ),
    (
      icon: Icons.workspace_premium_outlined,
      title: 'Acumula coronas y disfruta beneficios',
      description: 'Conoce la experiencia de coronas y promociones. Todos los puntos y beneficios del prototipo son demostrativos.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Guía rápida')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        'Paso ${_currentStep + 1} de ${_steps.length}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      backgroundColor: AppColors.beige,
                      color: AppColors.red,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  children: [
                    for (final step in _steps)
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ProfileIntro(
                          icon: step.icon,
                          title: step.title,
                          description: step.description,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: _currentStep == 0
                              ? null
                              : () => _goTo(_currentStep - 1),
                          child: const Text('Anterior'),
                        ),
                        ElevatedButton(
                          style: ProfileStyles.primaryButton,
                          onPressed: () {
                            if (_currentStep == _steps.length - 1) {
                              Navigator.of(context).pop();
                            } else {
                              _goTo(_currentStep + 1);
                            }
                          },
                          child: Text(
                            _currentStep == _steps.length - 1
                                ? 'Finalizar'
                                : 'Siguiente',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DemoNotice(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
