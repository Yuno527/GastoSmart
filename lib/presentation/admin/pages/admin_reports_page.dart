import 'dart:math' as math;
import 'package:flutter/material.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  static const pageBg = Color(0xFFF6F7FB);
  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _AdminHeader(
            title: 'Reportes Globales',
            subtitle: 'Análisis del sistema',
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exportar reportes (demo)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text(
                'Exportar Reportes',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Pie chart
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorías Más Utilizadas',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                SizedBox(height: 230, child: _PieChartWithLegend()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Comparación mensual
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparación Mensual',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                SizedBox(height: 180, child: _ComparisonBars()),
                SizedBox(height: 10),
                _LegendRow(),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Crecimiento
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crecimiento de Usuarios',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                SizedBox(height: 180, child: _GrowthLine()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Resumen general
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen General',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                _RowValue(
                  label: 'Volumen Total de Transacciones',
                  value: '3,567',
                ),
                _RowValue(label: 'Promedio por Usuario', value: '2.86'),
                _RowValue(
                  label: 'Tasa de Retención',
                  value: '78.5%',
                  green: true,
                ),
                _RowValue(
                  label: 'Crecimiento Mensual',
                  value: '+8.5%',
                  green: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Header ---------------- */

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

/* ---------------- Card base ---------------- */

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

class _RowValue extends StatelessWidget {
  final String label;
  final String value;
  final bool green;
  const _RowValue({
    required this.label,
    required this.value,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: green ? const Color(0xFF10B981) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Pie chart + legend ---------------- */

class _PieChartWithLegend extends StatelessWidget {
  const _PieChartWithLegend();

  @override
  Widget build(BuildContext context) {
    const slices = <_Slice>[
      _Slice('Alimentación', 35, Color(0xFF22C55E)),
      _Slice('Transporte', 25, Color(0xFF2563EB)),
      _Slice('Vivienda', 18, Color(0xFF8B5CF6)),
      _Slice('Tecnología', 12, Color(0xFF06B6D4)),
      _Slice('Otros', 10, Color(0xFFF59E0B)),
    ];

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: CustomPaint(
            painter: _PiePainter(slices),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(flex: 5, child: _PieLegend(slices: slices)),
      ],
    );
  }
}

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class _PiePainter extends CustomPainter {
  final List<_Slice> slices;
  _PiePainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (p, e) => p + e.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.34;

    // donut
    final paint = Paint()..style = PaintingStyle.stroke;
    paint.strokeWidth = radius * 0.45;
    paint.strokeCap = StrokeCap.butt;

    double start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * (2 * math.pi);
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => false;
}

class _PieLegend extends StatelessWidget {
  final List<_Slice> slices;
  const _PieLegend({required this.slices});

  @override
  Widget build(BuildContext context) {
    // valores ejemplo como en la imagen (puedes cambiarlos luego)
    const counts = {
      'Alimentación': 1245,
      'Transporte': 892,
      'Vivienda': 678,
      'Tecnología': 445,
      'Otros': 307,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...slices.map((s) {
          final count = counts[s.label] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${s.label}: $count',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

/* ---------------- Comparison monthly bars ---------------- */

class _ComparisonBars extends StatelessWidget {
  const _ComparisonBars();

  @override
  Widget build(BuildContext context) {
    // ejemplo (ene..jun)
    const tx = [210, 260, 310, 380, 450, 520];
    const users = [120, 140, 160, 190, 220, 250];
    const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return CustomPaint(
      painter: _GroupedBarsPainter(tx: tx, users: users, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _GroupedBarsPainter extends CustomPainter {
  final List<int> tx;
  final List<int> users;
  final List<String> labels;

  _GroupedBarsPainter({
    required this.tx,
    required this.users,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const bottomPad = 26.0;
    const topPad = 10.0;
    const rightPad = 10.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final maxTx = tx.reduce((a, b) => a > b ? a : b);
    final maxU = users.reduce((a, b) => a > b ? a : b);
    final maxV = math.max(maxTx, maxU).toDouble();

    // grid horizontal
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    const textStyle = TextStyle(color: Colors.black45, fontSize: 11);

    const steps = 3; // 0, mid, max
    for (int i = 0; i <= steps; i++) {
      final v = (maxV / steps) * i;
      final y = topPad + chartH - (v / maxV) * chartH;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );

      tp.text = TextSpan(text: v.round().toString(), style: textStyle);
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // bars
    final n = labels.length;
    final groupW = chartW / n;
    final barW = groupW * 0.22;
    final gap = groupW * 0.10;

    final txPaint = Paint()..color = const Color(0xFF4F46E5);
    final uPaint = Paint()..color = const Color(0xFF93C5FD);

    for (int i = 0; i < n; i++) {
      final baseX = leftPad + i * groupW;

      final txH = (tx[i] / maxV) * chartH;
      final uH = (users[i] / maxV) * chartH;

      final txX = baseX + groupW * 0.26;
      final uX = txX + barW + gap;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(txX, topPad + chartH - txH, barW, txH),
          const Radius.circular(8),
        ),
        txPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(uX, topPad + chartH - uH, barW, uH),
          const Radius.circular(8),
        ),
        uPaint,
      );

      // label
      tp.text = TextSpan(text: labels[i], style: textStyle);
      tp.layout();
      tp.paint(
        canvas,
        Offset(baseX + (groupW - tp.width) / 2, topPad + chartH + 6),
      );
    }

    // axis
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
  bool shouldRepaint(covariant _GroupedBarsPainter oldDelegate) => false;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Dot(color: Color(0xFF4F46E5)),
        SizedBox(width: 6),
        Text(
          'transacciones',
          style: TextStyle(color: Colors.black54, fontSize: 12.5),
        ),
        SizedBox(width: 14),
        _Dot(color: Color(0xFF93C5FD)),
        SizedBox(width: 6),
        Text(
          'usuarios',
          style: TextStyle(color: Colors.black54, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/* ---------------- Growth line ---------------- */

class _GrowthLine extends StatelessWidget {
  const _GrowthLine();

  @override
  Widget build(BuildContext context) {
    const values = [850, 920, 980, 1050, 1180, 1320];
    const labels = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return CustomPaint(
      painter: _LinePainter(values: values, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<int> values;
  final List<String> labels;

  _LinePainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const bottomPad = 26.0;
    const topPad = 10.0;
    const rightPad = 10.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    // horizontal grid
    for (int i = 0; i <= 3; i++) {
      final y = topPad + (chartH / 3) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );
    }

    // line path
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (i / (values.length - 1)) * chartW;
      final t = (values[i] - minV) / ((maxV - minV) == 0 ? 1 : (maxV - minV));
      final y = topPad + chartH - (t * chartH);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // dots
    final dotPaint = Paint()..color = const Color(0xFF22C55E);
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (i / (values.length - 1)) * chartW;
      final t = (values[i] - minV) / ((maxV - minV) == 0 ? 1 : (maxV - minV));
      final y = topPad + chartH - (t * chartH);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    // labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    const textStyle = TextStyle(color: Colors.black45, fontSize: 11);
    for (int i = 0; i < labels.length; i++) {
      final x = leftPad + (i / (labels.length - 1)) * chartW;
      tp.text = TextSpan(text: labels[i], style: textStyle);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, topPad + chartH + 6));
    }

    // axis
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
  bool shouldRepaint(covariant _LinePainter oldDelegate) => false;
}
