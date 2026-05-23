import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proyecto_movil/domain/entities/transaction_entity.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';

const _kPrefsKey = 'app_data';

/// Data source que simula un backend (JSON + memoria + shared_preferences)
class LocalDataSource {
  // "Base de datos" en memoria
  List<TransactionEntity> transactions = [];
  List<AdminCategoryEntity> globalCategories = [];
  List<AdminCategoryEntity> userCategories = [];
  List<AdminUserEntity> users = [];
  Map<String, dynamic> config = {};

  bool loaded = false;
  late SharedPreferences _prefs;

  // Mapa de iconos — clave string en JSON → IconData en Flutter
  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant_outlined,
    'cafe': Icons.local_cafe_outlined,
    'car': Icons.directions_car_outlined,
    'home': Icons.home_outlined,
    'devices': Icons.devices_other_outlined,
    'health': Icons.favorite_border,
    'label': Icons.label_outline,
    'school': Icons.school_outlined,
    'sports': Icons.sports_esports_outlined,
    'shopping': Icons.shopping_bag_outlined,
  };

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static String _colorToHex(Color c) {
    final rgb = c.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static String _iconKey(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint) return entry.key;
    }
    return 'label';
  }

  Future<void> init() async {
    if (loaded) return;

    _prefs = await SharedPreferences.getInstance();

    final saved = _prefs.getString(_kPrefsKey);
    final Map<String, dynamic> data;

    if (saved != null) {
      data = jsonDecode(saved) as Map<String, dynamic>;
    } else {
      final raw = await rootBundle.loadString('assets/data/app_data.json');
      data = jsonDecode(raw) as Map<String, dynamic>;
    }

    _loadFromMap(data);
    loaded = true;
  }

  void _loadFromMap(Map<String, dynamic> data) {
    // Transacciones
    transactions = ((data['transacciones'] as List?) ?? []).map((t) {
      final parts = (t['fecha'] as String).split('-');
      return TransactionEntity(
        id: t['id'] as String,
        userId: t['usuario_id'] as String? ?? '',
        type: (t['tipo'] as String) == 'ingreso'
            ? TransactionType.income
            : TransactionType.expense,
        amount: t['monto'] as int,
        category: t['categoria'] as String,
        date: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ),
        note: t['nota'] as String,
      );
    }).toList();

    // Categorías globales
    globalCategories = ((data['categorias_globales'] as List?) ?? []).map((c) {
      return AdminCategoryEntity(
        id: c['id'] as String,
        name: c['nombre'] as String,
        icon: _iconMap[c['icono']] ?? Icons.label_outline,
        color: _parseColor(c['color'] as String),
      );
    }).toList();

    // Categorías del usuario
    userCategories = ((data['categorias_usuario'] as List?) ?? []).map((c) {
      return AdminCategoryEntity(
        id: c['id'] as String,
        name: c['nombre'] as String,
        icon: _iconMap[c['icono']] ?? Icons.label_outline,
        color: _parseColor(c['color'] as String),
      );
    }).toList();

    // Usuarios
    users = ((data['usuarios'] as List?) ?? []).map((u) {
      final parts = (u['fechaCreacion'] as String).split('-');
      AdminUserStatus status;
      switch (u['estado'] as String) {
        case 'activo':
          status = AdminUserStatus.active;
          break;
        case 'inactivo':
          status = AdminUserStatus.inactive;
          break;
        default:
          status = AdminUserStatus.blocked;
      }
      AdminUserRole role;
      switch (u['rol'] as String? ?? 'usuario') {
        case 'admin':
          role = AdminUserRole.admin;
          break;
        default:
          role = AdminUserRole.user;
      }
      return AdminUserEntity(
        id: u['id'] as String,
        name: u['nombre'] as String,
        email: u['email'] as String,
        password: u['contrasena'] as String? ?? '',
        createdAt: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ),
        status: status,
        role: role,
      );
    }).toList();

    config = Map<String, dynamic>.from((data['config'] as Map?) ?? {});
  }

  Future<void> _save() async {
    await _prefs.setString(_kPrefsKey, jsonEncode(_toMap()));
  }

  Map<String, dynamic> _toMap() {
    return {
      'config': config,
      'categorias_globales': globalCategories.map((c) => {
            'id': c.id,
            'nombre': c.name,
            'icono': _iconKey(c.icon),
            'color': _colorToHex(c.color),
          }).toList(),
      'categorias_usuario': userCategories.map((c) => {
            'id': c.id,
            'nombre': c.name,
            'icono': _iconKey(c.icon),
            'color': _colorToHex(c.color),
          }).toList(),
      'usuarios': users.map((u) {
        final d = u.createdAt;
        String estado;
        switch (u.status) {
          case AdminUserStatus.active:
            estado = 'activo';
            break;
          case AdminUserStatus.inactive:
            estado = 'inactivo';
            break;
          default:
            estado = 'bloqueado';
        }
        String rol;
        switch (u.role) {
          case AdminUserRole.admin:
            rol = 'admin';
            break;
          default:
            rol = 'usuario';
        }
        return {
          'id': u.id,
          'nombre': u.name,
          'email': u.email,
          'contrasena': u.password,
          'fechaCreacion':
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
          'estado': estado,
          'rol': rol,
        };
      }).toList(),
      'transacciones': transactions.map((t) {
        final d = t.date;
        return {
          'id': t.id,
          'usuario_id': t.userId,
          'tipo': t.type == TransactionType.income ? 'ingreso' : 'gasto',
          'monto': t.amount,
          'categoria': t.category,
          'fecha':
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
          'nota': t.note,
        };
      }).toList(),
    };
  }

  // Transacciones
  List<TransactionEntity> getTransactions() => transactions;
  Future<void> addTransaction(TransactionEntity tx) async {
    transactions.add(tx);
    await _save();
  }

  Future<void> updateTransaction(TransactionEntity tx) async {
    final i = transactions.indexWhere((t) => t.id == tx.id);
    if (i != -1) {
      transactions[i] = tx;
      await _save();
    }
  }

  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((t) => t.id == id);
    await _save();
  }

  // Categorías globales
  List<AdminCategoryEntity> getGlobalCategories() => globalCategories;
  Future<void> addGlobalCategory(AdminCategoryEntity cat) async {
    globalCategories.add(cat);
    await _save();
  }

  Future<void> updateGlobalCategory(AdminCategoryEntity cat) async {
    final i = globalCategories.indexWhere((c) => c.id == cat.id);
    if (i != -1) {
      globalCategories[i] = cat;
      await _save();
    }
  }

  Future<void> deleteGlobalCategory(String id) async {
    globalCategories.removeWhere((c) => c.id == id);
    await _save();
  }

  // Categorías usuario
  List<AdminCategoryEntity> getUserCategories() => userCategories;
  Future<void> addUserCategory(AdminCategoryEntity cat) async {
    userCategories.add(cat);
    await _save();
  }

  Future<void> updateUserCategory(AdminCategoryEntity cat) async {
    final i = userCategories.indexWhere((c) => c.id == cat.id);
    if (i != -1) {
      userCategories[i] = cat;
      await _save();
    }
  }

  Future<void> deleteUserCategory(String id) async {
    userCategories.removeWhere((c) => c.id == id);
    await _save();
  }

  // Usuarios
  List<AdminUserEntity> getUsers() => users;
  Future<void> addUser(AdminUserEntity user) async {
    users.add(user);
    await _save();
  }

  Future<void> updateUserStatus(String userId, AdminUserStatus status) async {
    final i = users.indexWhere((u) => u.id == userId);
    if (i != -1) {
      users[i] = users[i].copyWith(status: status);
      await _save();
    }
  }

  // Config
  Future<void> saveConfig(Map<String, dynamic> newConfig) async {
    config = newConfig;
    await _save();
  }
}
