import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _AdminHeader(
            title: 'Categorías',
            subtitle: '${state.categories.length} categorías disponibles',
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                final newCat = AdminCategoryEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: 'Nueva categoría',
                  icon: Icons.category_outlined,
                  color: const Color(0xFF4F46E5),
                );
                _openEdit(context, ref, newCat, isNew: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Nueva Categoría',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, i) {
              final c = state.categories[i];
              return _CategoryCard(
                cat: c,
                onEdit: () => _openEdit(context, ref, c, isNew: false),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openEdit(
    BuildContext context,
    WidgetRef ref,
    AdminCategoryEntity cat, {
    required bool isNew,
  }) {
    showDialog(
      context: context,
      builder: (_) => _EditCategoryDialog(cat: cat, isNew: isNew),
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
        gradient: const LinearGradient(colors: [primary, Color(0xFF6D5EF6)]),
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

class _CategoryCard extends StatelessWidget {
  final AdminCategoryEntity cat;
  final VoidCallback onEdit;

  const _CategoryCard({required this.cat, required this.onEdit});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(cat.icon, color: cat.color),
          ),
          const SizedBox(height: 10),
          Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditCategoryDialog extends ConsumerStatefulWidget {
  final AdminCategoryEntity cat;
  final bool isNew;

  const _EditCategoryDialog({required this.cat, required this.isNew});

  @override
  ConsumerState<_EditCategoryDialog> createState() =>
      _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<_EditCategoryDialog> {
  static const primary = Color(0xFF4F46E5);

  late TextEditingController nameCtrl;
  late Color selectedColor;

  final colors = const [
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.cat.name);
    selectedColor = widget.cat.color;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(adminControllerProvider.notifier);

    return AlertDialog(
      title: const Text(
        'Editar Categoría',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Nombre de la categoría'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerLeft, child: Text('Color')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: colors.map((c) {
              final sel = c.toARGB32() == selectedColor.toARGB32();
              return InkWell(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? Colors.black87 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final updated = widget.cat.copyWith(
              name: nameCtrl.text.trim().isEmpty
                  ? widget.cat.name
                  : nameCtrl.text.trim(),
              color: selectedColor,
            );

            if (widget.isNew) {
              ctrl.addCategory(updated);
            } else {
              ctrl.updateCategory(updated);
            }

            Navigator.pop(context);
          },
          child: const Text(
            'Guardar',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
