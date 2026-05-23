import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/application/providers/reports_providers.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  static const Color primary = Color(0xFF4F46E5);
  static const Color pageBg = Color(0xFFF6F7FB);

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(transactionsControllerProvider.notifier).load();
      final items = ref.read(transactionsControllerProvider).items;
      await ref.read(reportsControllerProvider.notifier).generarYGuardar(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(reportsSummaryProvider);
    final txState = ref.watch(transactionsControllerProvider);

    // Calcular datos de los dos últimos meses con transacciones
    final monthlyData = _calculateMonthlyData(txState.items);

    // Obtener los dos meses más recientes
    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final currentMonth = sortedMonths.isNotEmpty ? sortedMonths[0] : null;
    final previousMonth = sortedMonths.length > 1 ? sortedMonths[1] : null;

    final currentData = currentMonth != null ? monthlyData[currentMonth] : _MonthData.zero();
    final previousData = previousMonth != null ? monthlyData[previousMonth] : _MonthData.zero();

    // Usar datos reales para la gráfica
    final month1Income = previousData?.income ?? 0;
    final month1Expense = previousData?.expense ?? 0;
    final month2Income = currentData?.income ?? 0;
    final month2Expense = currentData?.expense ?? 0;

    final month1Label = previousMonth != null ? _formatMonth(previousMonth) : 'Mes 1';
    final month2Label = currentMonth != null ? _formatMonth(currentMonth) : 'Mes 2';

    return Scaffold(
      backgroundColor: ReportsPage.pageBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            const Text(
              'Reportes',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Análisis de tus finanzas',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),

            // KPIs
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    icon: Icons.trending_up_rounded,
                    iconBg: const Color(0xFFD1FAE5),
                    value: '${summary.savingRatePercent}%',
                    label: 'Tasa de ahorro',
                    valueColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    icon: Icons.show_chart_rounded,
                    iconBg: const Color(0xFFD1FAE5),
                    value: '${summary.vsLastMonthPercent.toStringAsFixed(0)}%',
                    label: 'vs. mes anterior',
                    valueColor: summary.vsLastMonthPercent >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Comparación mensual (card grande)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comparación mensual',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 180,
                    child: _BarComparison(
                      month1Label: month1Label,
                      month1Income: month1Income,
                      month1Expense: month1Expense,
                      month2Label: month2Label,
                      month2Income: month2Income,
                      month2Expense: month2Expense,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Leyenda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _LegendDot(color: Color(0xFF10B981), label: 'Ingresos'),
                      SizedBox(width: 16),
                      _LegendDot(color: Color(0xFFEF4444), label: 'Gastos'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Consejos financieros',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            _TipCard(
              icon: Icons.lightbulb_outline,
              iconBg: const Color(0xFFD1FAE5),
              title: '¡Excelente control!',
              text:
                  'Este mes has gastado 39% menos que el anterior.\nSigue así y alcanzarás tus metas de ahorro.',
            ),
            const SizedBox(height: 12),
            _TipCard(
              icon: Icons.help_outline_rounded,
              iconBg: const Color(0xFFEDE9FE),
              title: 'Consejo de ahorro',
              text:
                  'Intenta reducir tus gastos en entretenimiento en un 20% para aumentar tu capacidad de ahorro.',
            ),

            const SizedBox(height: 16),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de $month2Label',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _RowValue(
                    label: 'Total de ingresos',
                    value: _Money.format(summary.income),
                    valueColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  _RowValue(
                    label: 'Total de gastos',
                    value: _Money.format(summary.expense),
                    valueColor: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.black12),
                  const SizedBox(height: 12),
                  _RowValue(
                    label: 'Balance final',
                    value: _Money.format(summary.balance),
                    valueColor: const Color(0xFF10B981),
                    bold: true,
                  ),
                ],
              ),
            ),

            if (summary.historialReportes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Reportes guardados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...summary.historialReportes.take(6).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _Card(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.periodo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              _Money.format(r.balance),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: r.balance >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ---------------- Widgets UI ---------------- */

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String value;
  final String label;
  final Color valueColor;

  const _KpiCard({
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String text;

  const _TipCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowValue extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _RowValue({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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

/* --------------- Bar chart simple (sin librerías) --------------- */

class _BarComparison extends StatelessWidget {
  final String month1Label;
  final int month1Income;
  final int month1Expense;
  final String month2Label;
  final int month2Income;
  final int month2Expense;

  const _BarComparison({
    required this.month1Label,
    required this.month1Income,
    required this.month1Expense,
    required this.month2Label,
    required this.month2Income,
    required this.month2Expense,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      month1Income,
      month1Expense,
      month2Income,
      month2Expense,
    ].reduce((a, b) => a > b ? a : b);

    double h(int v) => maxValue == 0 ? 0 : (v / maxValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _MonthBars(
            label: month1Label,
            incomeP: h(month1Income),
            expenseP: h(month1Expense),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _MonthBars(
            label: month2Label,
            incomeP: h(month2Income),
            expenseP: h(month2Expense),
          ),
        ),
      ],
    );
  }
}

class _MonthBars extends StatelessWidget {
  final String label;
  final double incomeP;
  final double expenseP;

  const _MonthBars({
    required this.label,
    required this.incomeP,
    required this.expenseP,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Bar(heightFactor: incomeP, color: const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _Bar(heightFactor: expenseP, color: const Color(0xFFEF4444)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double heightFactor;
  final Color color;

  const _Bar({required this.heightFactor, required this.color});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor.clamp(0, 1),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 34,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/* --------------- Money format --------------- */

class _Money {
  static String format(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return '\$ ${buf.toString()}';
  }
}

/* --------------- Helper functions --------------- */

class _MonthData {
  final int income;
  final int expense;

  const _MonthData({required this.income, required this.expense});

  const _MonthData.zero() : income = 0, expense = 0;
}

Map<DateTime, _MonthData> _calculateMonthlyData(List<TransactionEntity> items) {
  final monthlyData = <DateTime, _MonthData>{};

  for (final t in items) {
    final monthKey = DateTime(t.date.year, t.date.month, 1);

    if (!monthlyData.containsKey(monthKey)) {
      monthlyData[monthKey] = _MonthData(income: 0, expense: 0);
    }

    final data = monthlyData[monthKey]!;
    if (t.type == TransactionType.income) {
      monthlyData[monthKey] = _MonthData(
        income: data.income + t.amount,
        expense: data.expense,
      );
    } else {
      monthlyData[monthKey] = _MonthData(
        income: data.income,
        expense: data.expense + t.amount,
      );
    }
  }

  return monthlyData;
}

String _formatMonth(DateTime month) {
  const monthNames = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  return '${monthNames[month.month - 1]} ${month.year}';
}
