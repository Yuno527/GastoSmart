import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/presentation/routes.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _primary = Color(0xFF4F46E5);

  final List<_OnbItem> _items = const [
    _OnbItem(
      icon: Icons.savings_outlined,
      title: 'Controla tus gastos',
      subtitle:
          'Registra tus ingresos y gastos de forma rápida\ny sencilla. Mantén todo organizado en un solo\nlugar.',
    ),
    _OnbItem(
      icon: Icons.show_chart_rounded,
      title: 'Visualiza tu dinero',
      subtitle:
          'Gráficos claros y simples te muestran en qué\ngastas tu dinero y cómo mejorar tus finanzas.',
    ),
    _OnbItem(
      icon: Icons.adjust_rounded,
      title: 'Alcanza tus metas',
      subtitle:
          'Define presupuestos y metas de ahorro. Te\nayudamos a construir hábitos financieros\nsaludables.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() async {
    final session = ref.read(sessionServiceProvider);
    final ds = ref.read(supabaseDataSourceProvider);

    if (session.isLoggedIn) {
      await ds.completarOnboarding(session.currentUserId);
    } else {
      await session.markDeviceOnboardingDone();
      ref.read(showOnboardingProvider.notifier).state = false;
    }

    if (!mounted) return;
    if (session.isLoggedIn) {
      context.go(session.isAdmin ? Routes.admin : Routes.home);
    } else {
      context.go(Routes.login);
    }
  }

  void _next() {
    if (_index == _items.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    final session = ref.read(sessionServiceProvider);
    if (session.isLoggedIn) {
      ref.read(supabaseDataSourceProvider).setOnboardingPaso(
            session.currentUserId,
            i + 1,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _items.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // SALTAR (arriba derecha)
            Positioned(
              top: 8,
              right: 12,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Saltar',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            // CONTENIDO
            Column(
              children: [
                const SizedBox(height: 70),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _items.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // Icono en círculo (como el diseño)
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, size: 44, color: _primary),
                            ),

                            const SizedBox(height: 34),

                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Colors.black54,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // DOTS
                _Dots(
                  count: _items.length,
                  index: _index,
                  activeColor: _primary,
                ),

                const SizedBox(height: 18),

                // BOTÓN INFERIOR
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        isLast ? 'Comenzar' : 'Siguiente',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnbItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final Color activeColor;

  const _Dots({
    required this.count,
    required this.index,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.black12,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
