import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/transaction_entity.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  static const primary = Color(0xFF4F46E5);
  static const expenseRed = Color(0xFFEF4444);
  static const incomeGreen = Color(0xFF10B981);
  static const softBg = Color(0xFFF6F7FB);

  bool isExpense = true;

  final amountCtrl = TextEditingController(text: '0');
  final noteCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();

  // ===== GASTOS =====
  String expenseCategory = 'Alimentación';

  // ===== INGRESOS (pantalla que faltaba) =====
  String incomeType = 'Mesada';
  final incomeTypes = const [
    _Pick('Mesada', Icons.trending_up),
    _Pick('Trabajo', Icons.trending_up),
    _Pick('Otro', Icons.trending_up),
  ];

  @override
  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _sanitizeAmount(String v) {
    final parsed = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final text = parsed.toString();
    if (amountCtrl.text != text) {
      amountCtrl.text = text;
      amountCtrl.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  Future<void> _save() async {
    final monto = int.tryParse(amountCtrl.text) ?? 0;
    final expenseCategories = ref.read(adminControllerProvider).categories;

    // ✅ si no escribió nada, no guarda
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un monto mayor a 0'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }

    if (isExpense && expenseCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay categorías de gasto configuradas'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    // ✅ para ingreso usamos "Mesada/Trabajo/Otro"
    final category = isExpense ? expenseCategory : incomeType;
    final sessionService = ref.read(sessionServiceProvider);
    final userId = sessionService.currentUserId;

    final tx = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      amount: monto,
      category: category,
      date: selectedDate, // ✅ por defecto HOY
      note: noteCtrl.text.trim(),
    );

    // ✅ importante: usar EL provider del DI
    await ref.read(transactionsControllerProvider.notifier).add(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isExpense ? 'Gasto guardado ✅' : 'Ingreso guardado ✅'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isExpense ? expenseRed : incomeGreen;
    final expensePicks = ref
        .watch(adminControllerProvider)
        .categories
        .map((c) => _Pick(c.name, c.icon))
        .toList();

    if (expensePicks.isNotEmpty &&
        !expensePicks.any((p) => p.name == expenseCategory)) {
      expenseCategory = expensePicks.first.name;
    }

    final picks = isExpense ? expensePicks : incomeTypes;
    final title = isExpense ? 'Categoría' : 'Tipo de ingreso';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Agregar movimiento',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // Toggle (pill)
          Row(
            children: [
              Expanded(
                child: _Pill(
                  text: 'Gasto',
                  selected: isExpense,
                  color: expenseRed,
                  onTap: () => setState(() => isExpense = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Pill(
                  text: 'Ingreso',
                  selected: !isExpense,
                  color: incomeGreen,
                  onTap: () => setState(() => isExpense = false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Monto',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Monto grande (editable) como tu imagen
          Center(
            child: SizedBox(
              width: 240,
              child: TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.black26,
                ),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  border: InputBorder.none,
                ),
                onChanged: _sanitizeAmount,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          // Grid de categorías/tipos
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: picks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (_, i) {
              final p = picks[i];
              final selected = isExpense
                  ? (p.name == expenseCategory)
                  : (p.name == incomeType);

              return _PickCard(
                name: p.name,
                icon: p.icon,
                selected: selected,
                selectedColor: activeColor,
                onTap: () => setState(() {
                  if (isExpense) {
                    expenseCategory = p.name;
                  } else {
                    incomeType = p.name;
                  }
                }),
              );
            },
          ),

          const SizedBox(height: 18),

          const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: softBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                _fmt(selectedDate),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Nota (opcional)',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: TextField(
              controller: noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Agrega una descripción...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Guardar movimiento',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Widgets ---------------- */

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Pill({
    required this.text,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _PickCard({
    required this.name,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withOpacity(0.12)
              : const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? selectedColor.withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pick {
  final String name;
  final IconData icon;
  const _Pick(this.name, this.icon);
}

/* helpers */
String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
