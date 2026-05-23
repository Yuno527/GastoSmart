import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/infrastructure/datasources/local_data_source.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
      final dataSource = ref.watch(localDataSourceProvider);
      return AdminController(dataSource)..load();
    });

/* ============ State ============ */

class AdminState {
  final bool loading;
  final String usersQuery;
  final List<AdminUserEntity> users;
  final List<AdminCategoryEntity> categories;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool spendAlertsEnabled;
  final int budget;

  const AdminState({
    required this.loading,
    required this.usersQuery,
    required this.users,
    required this.categories,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.spendAlertsEnabled,
    required this.budget,
  });

  factory AdminState.initial() => const AdminState(
    loading: false,
    usersQuery: '',
    users: [],
    categories: [],
    darkMode: false,
    notificationsEnabled: true,
    spendAlertsEnabled: true,
    budget: 500000,
  );

  AdminState copyWith({
    bool? loading,
    String? usersQuery,
    List<AdminUserEntity>? users,
    List<AdminCategoryEntity>? categories,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? spendAlertsEnabled,
    int? budget,
  }) {
    return AdminState(
      loading: loading ?? this.loading,
      usersQuery: usersQuery ?? this.usersQuery,
      users: users ?? this.users,
      categories: categories ?? this.categories,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      spendAlertsEnabled: spendAlertsEnabled ?? this.spendAlertsEnabled,
      budget: budget ?? this.budget,
    );
  }
}

/* ============ Controller ============ */

class AdminController extends StateNotifier<AdminState> {
  final LocalDataSource _dataSource;

  AdminController(this._dataSource) : super(AdminState.initial());

  void load() {
    state = state.copyWith(
      loading: false,
      users: _dataSource.getUsers(),
      categories: _dataSource.getGlobalCategories(),
      darkMode: _dataSource.config['modoOscuro'] as bool? ?? false,
      notificationsEnabled: _dataSource.config['notificaciones'] as bool? ?? true,
      spendAlertsEnabled: _dataSource.config['alertasGasto'] as bool? ?? true,
      budget: _dataSource.config['presupuesto'] as int? ?? 500000,
    );
  }

  /* -------- Usuarios -------- */
  void setUsersQuery(String q) => state = state.copyWith(usersQuery: q);

  List<AdminUserEntity> filteredUsers() {
    final q = state.usersQuery.trim().toLowerCase();
    if (q.isEmpty) return state.users;
    return state.users
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  /* -------- Categorías — CRUD + persistencia -------- */
  void addCategory(AdminCategoryEntity cat) {
    final updated = [cat, ...state.categories];
    state = state.copyWith(categories: updated);
    _dataSource.addGlobalCategory(cat);
  }

  void updateCategory(AdminCategoryEntity cat) {
    final updated = state.categories
        .map((c) => c.id == cat.id ? cat : c)
        .toList();
    state = state.copyWith(categories: updated);
    _dataSource.updateGlobalCategory(cat);
  }

  void deleteCategory(String id) {
    final updated = state.categories.where((c) => c.id != id).toList();
    state = state.copyWith(categories: updated);
    _dataSource.deleteGlobalCategory(id);
  }

  /* -------- Usuarios -------- */
  void setUserStatus(String userId, AdminUserStatus status) {
    final updated = state.users
        .map((u) => u.id == userId ? u.copyWith(status: status) : u)
        .toList();
    state = state.copyWith(users: updated);
    _dataSource.updateUserStatus(userId, status);
  }

  /* -------- Config -------- */
  void toggleDark(bool v) {
    state = state.copyWith(darkMode: v);
    _saveConfig();
  }

  void toggleNotifications(bool v) {
    state = state.copyWith(notificationsEnabled: v);
    _saveConfig();
  }

  void toggleSpendAlerts(bool v) {
    state = state.copyWith(spendAlertsEnabled: v);
    _saveConfig();
  }

  void setBudget(int v) {
    state = state.copyWith(budget: v);
    _saveConfig();
  }

  void _saveConfig() {
    _dataSource.saveConfig({
      'modoOscuro': state.darkMode,
      'notificaciones': state.notificationsEnabled,
      'alertasGasto': state.spendAlertsEnabled,
      'presupuesto': state.budget,
    });
  }
}
