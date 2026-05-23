import 'dart:math' as math;
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  final void Function(int index)? onNavigate;
  const AdminDashboardPage({super.key, this.onNavigate});

  static const primary = Color(0xFF4F46E5);
  static const pageBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _AdminHeader(
            title: 'Dashboard',
            subtitle: 'Vista general del sistema',
          ),
          const SizedBox(height: 14),

          // 4 stats
          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  iconBg: Color(0xFFEDE9FE),
                  icon: Icons.people_outline,
                  title: 'Usuarios Totales',
                  value: '1,248',
                  delta: '+12%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  iconBg: Color(0xFFD1FAE5),
                  icon: Icons.trending_up_rounded,
                  title: 'Usuarios Activos',
                  value: '894',
                  delta: '+8%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  iconBg: Color(0xFFEDE9FE),
                  icon: Icons.receipt_long_outlined,
                  title: 'Transacciones',
                  value: '3,567',
                  delta: '+15%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  iconBg: Color(0xFFFFEDD5),
                  icon: Icons.folder_open_outlined,
                  title: 'Categorías',
                  value: '24',
                  delta: '+5%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Chart card
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad Mensual',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                SizedBox(height: 190, child: _MonthlyBarChart()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Accesos rápidos',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.people_outline,
                  title: 'Gestionar\nUsuarios',
                  onTap: () => onNavigate?.call(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.folder_open_outlined,
                  title: 'Ver Categorías',
                  onTap: () => onNavigate?.call(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _AdminHeader({required this.title, required this.subtitle});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, Color(0xFF6D5EF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PANEL ADMIN',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String value;
  final String delta;

  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.value,
    required this.delta,
  });

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      delta,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart();

  @override
  Widget build(BuildContext context) {
    // valores como el diseño (Ene..Jun)
    const values = [240, 310, 290, 380, 470, 520];
    const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return CustomPaint(
      painter: _BarChartPainter(values: values, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> values;
  final List<String> labels;

  _BarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    // paddings internos
    const leftPad = 34.0;
    const bottomPad = 26.0;
    const topPad = 8.0;
    const rightPad = 10.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // max value
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();

    // grid lines (0..600 como tu diseño)
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(color: Colors.black45, fontSize: 11);
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Eje Y con 0..600 (6 pasos)
    final yMax = math.max(600.0, maxV);
    const steps = 4; // 0,150,300,450,600
    for (int i = 0; i <= steps; i++) {
      final v = (yMax / steps) * i;
      final y = topPad + chartH - (v / yMax) * chartH;

      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );

      tp.text = TextSpan(text: v.round().toString(), style: textStyle);
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final barCount = values.length;
    final gap = chartW * 0.06;
    final barW = (chartW - gap * (barCount - 1)) / barCount;

    final barPaint = Paint()
      ..color = const Color(0xFF2563EB); // azul tipo diseño
    final barRadius = const Radius.circular(10);

    for (int i = 0; i < barCount; i++) {
      final x = leftPad + i * (barW + gap);
      final h = (values[i] / yMax) * chartH;
      final y = topPad + chartH - h;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, h),
        barRadius,
      );
      canvas.drawRRect(rrect, barPaint);

      // label X
      tp.text = TextSpan(text: labels[i], style: textStyle);
      tp.layout();
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, topPad + chartH + 6));
    }

    // eje vertical (opcional suave)
    final axisPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(leftPad, topPad),
      Offset(leftPad, topPad + chartH),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => false;
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.title, this.onTap});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: child,
    );
  }
}
