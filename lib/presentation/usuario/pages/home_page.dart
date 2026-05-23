import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/presentation/usuario/pages/add_transaction_page.dart';
import 'package:proyecto_movil/presentation/usuario/pages/history_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const primary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(transactionsControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionsControllerProvider);

    final income = txState.incomeMonth;
    final expense = txState.expenseMonth;
    final balance = txState.balanceMonth;

    final last = txState.items.take(3).toList();
    final donut = _buildDonut(txState.items, txState.monthRef);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTransactionPage()));
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Hola, Usuario! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Aquí está tu resumen financiero',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 14,
                          offset: Offset(0, 8),
                          color: Color(0x16000000),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Balance del mes',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const Spacer(),
                            Text(
                              _monthLabel(txState.monthRef),
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$ ${_money(balance)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: balance >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.arrow_upward,
                                iconBg: const Color(0xFFD1FAE5),
                                iconColor: const Color(0xFF10B981),
                                label: 'Ingresos',
                                value: '\$ ${_money(income)}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.arrow_downward,
                                iconBg: const Color(0xFFFEE2E2),
                                iconColor: const Color(0xFFEF4444),
                                label: 'Gastos',
                                value: '\$ ${_money(expense)}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Gastos por categoría',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 14,
                    offset: Offset(0, 8),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 170,
                    child: Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: _DonutChart(slices: donut.slices),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: donut.legend
                        .map((e) => _LegendItem(color: e.color, label: e.label))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Text(
                  'Últimos movimientos',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryPage()),
                    );
                  },
                  child: const Text('Ver todo'),
                ),
              ],
            ),

            if (last.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Color(0x14000000),
                    ),
                  ],
                ),
                child: const Text(
                  'Aún no tienes movimientos',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

            ...last.map((t) => _MoveCard(tx: t)).toList(),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  _DonutBundle _buildDonut(List<TransactionEntity> items, DateTime monthRef) {
    final map = <String, int>{};

    for (final t in items) {
      final sameMonth =
          t.date.year == monthRef.year && t.date.month == monthRef.month;
      if (!sameMonth) continue;
      if (t.type != TransactionType.expense) continue;

      final normalized = (t.category == 'Diversión')
          ? 'Entretenimiento'
          : t.category;
      map[normalized] = (map[normalized] ?? 0) + t.amount;
    }

    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(4).toList();

    const palette = <String, Color>{
      'Alimentación': Color(0xFFEF4444),
      'Café y Snacks': Color(0xFFF59E0B),
      'Transporte': Color.fromARGB(255, 12, 190, 142),
      'Vivienda': Color(0xFF8B5CF6),
      'Tecnología': Color(0xFF06B6D4),
      'Salud': Color(0xFFEC4899),
      'Entretenimiento': Color.fromARGB(255, 176, 235, 15),
      'Estudio': Color(0xFF2563EB),
      'Otros': Color.fromARGB(255, 197, 6, 235),
    };

    if (top.isEmpty) {
      return const _DonutBundle(
        slices: [_Slice(color: Color.fromARGB(255, 231, 231, 228), value: 1)],
        legend: [_Legend(color: Color(0xFFE5E7EB), label: 'Sin datos')],
      );
    }

    final slices = <_Slice>[];
    final legend = <_Legend>[];
    for (final e in top) {
      final c = palette[e.key] ?? palette['Otros']!;
      slices.add(_Slice(color: c, value: e.value.toDouble()));
      legend.add(_Legend(color: c, label: e.key));
    }

    return _DonutBundle(slices: slices, legend: legend);
  }
}

/* UI */

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoveCard extends StatelessWidget {
  final TransactionEntity tx;
  const _MoveCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final amountColor = isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final cat = tx.category == 'Diversión' ? 'Entretenimiento' : tx.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg(cat),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon(cat), color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  _fmtDateISO(tx.date),
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}\$ ${_money(tx.amount)}',
            style: TextStyle(fontWeight: FontWeight.w900, color: amountColor),
          ),
        ],
      ),
    );
  }

  IconData _icon(String c) {
    switch (c) {
      case 'Alimentación':
        return Icons.shopping_cart_outlined;
      case 'Transporte':
        return Icons.directions_car_outlined;
      case 'Entretenimiento':
        return Icons.videogame_asset_outlined;
      case 'Estudio':
        return Icons.school_outlined;
      case 'Hogar':
        return Icons.home_outlined;
      case 'Servicios':
        return Icons.bolt_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _iconBg(String c) {
    switch (c) {
      case 'Alimentación':
        return const Color.fromARGB(255, 233, 230, 231);
      case 'Transporte':
        return const Color(0xFFFFF7ED);
      case 'Entretenimiento':
        return const Color(0xFFF5F3FF);
      case 'Estudio':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFF6F7FB);
    }
  }
}

/* Donut */

class _DonutChart extends StatelessWidget {
  final List<_Slice> slices;
  const _DonutChart({required this.slices});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(slices),
      child: const SizedBox.expand(),
    );
  }
}

class _Slice {
  final Color color;
  final double value;
  const _Slice({required this.color, required this.value});
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final double total = slices.fold<double>(0.0, (p, e) => p + e.value);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.48
      ..strokeCap = StrokeCap.butt;

    double start = -math.pi / 2;

    for (final s in slices) {
      final double sweep = total == 0.0
          ? 0.0
          : (s.value / total) * (2 * math.pi);

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
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}

class _Legend {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12.5),
        ),
      ],
    );
  }
}

class _DonutBundle {
  final List<_Slice> slices;
  final List<_Legend> legend;
  const _DonutBundle({required this.slices, required this.legend});
}

/* Helpers */

String _fmtDateISO(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _money(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    b.write(s[i]);
    if (pos > 1 && pos % 3 == 1) b.write('.');
  }
  return b.toString();
}

String _monthLabel(DateTime monthRef) {
  const months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${months[monthRef.month - 1]} ${monthRef.year}';
}
