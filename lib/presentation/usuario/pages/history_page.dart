import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart'; 
import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/application/providers/home_derived_providers.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  static const primary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transactionsControllerProvider.notifier)
          .registrarConsultaHistorial(accion: 'visualizado');
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(historySelectedCategoryProvider);
    final grouped = ref.watch(groupedByDayProvider);
    final adminCategories = ref.watch(adminControllerProvider).categories;
    final baseCategories = <String>{
      'Todas',
      ...adminCategories.map((c) => c.name),
    }.toList();

    if (!baseCategories.contains(selected)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(historySelectedCategoryProvider.notifier).state = 'Todas';
      });
    }
    final iconByCategory = <String, IconData>{
      for (final c in adminCategories) c.name: c.icon,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            const Text(
              'Historial',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Todos tus movimientos',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            Row(
              children: const [
                Icon(Icons.filter_alt_outlined, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  'Filtrar por:',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: baseCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final c = baseCategories[i];
                  final isSel = c == selected;

                  return ChoiceChip(
                    label: Text(c),
                    selected: isSel,
                    selectedColor: primary,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (_) =>
                        ref
                                .read(historySelectedCategoryProvider.notifier)
                                .state =
                            c,
                    backgroundColor: const Color(0xFFF1F3F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide.none,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            if (grouped.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Aún no hay movimientos',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),

            ...grouped.entries.map((e) {
              final day = e.key;
              final items = e.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _fmtDateISO(day),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${items.length} movimiento',
                          style: const TextStyle(color: Colors.black38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...items.map(
                      (t) => _HistoryTile(
                        tx: t,
                        iconByCategory: iconByCategory,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final TransactionEntity tx;
  final Map<String, IconData> iconByCategory;

  const _HistoryTile({
    required this.tx,
    required this.iconByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final amountColor = isIncome
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
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
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconByCategory[tx.category] ?? Icons.receipt_long_outlined,
              color: amountColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  tx.note.isEmpty ? _fmtDate(tx.date) : tx.note,
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

}

/* helpers */
String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
