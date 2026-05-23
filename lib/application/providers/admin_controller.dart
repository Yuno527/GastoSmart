import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>(
  (ref) => AdminController(ref.watch(supabaseDataSourceProvider))..load(),
);

class AdminState {
  final bool loading;
  final String usersQuery;
  final List<AdminUserEntity> users;
  final List<AdminCategoryEntity> categories;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool spendAlertsEnabled;
  final int budget;
  final String? error;

  const AdminState({
    required this.loading,
    required this.usersQuery,
    required this.users,
    required this.categories,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.spendAlertsEnabled,
    required this.budget,
    this.error,
  });

  factory AdminState.initial() => const AdminState(
        loading: false, usersQuery: '', users: [], categories: [],
        darkMode: false, notificationsEnabled: true,
        spendAlertsEnabled: true, budget: 500000,
      );

  AdminState copyWith({
    bool? loading, String? usersQuery,
    List<AdminUserEntity>? users, List<AdminCategoryEntity>? categories,
    bool? darkMode, bool? notificationsEnabled,
    bool? spendAlertsEnabled, int? budget, String? error,
  }) =>
      AdminState(
        loading:              loading              ?? this.loading,
        usersQuery:           usersQuery           ?? this.usersQuery,
        users:                users                ?? this.users,
        categories:           categories           ?? this.categories,
        darkMode:             darkMode             ?? this.darkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        spendAlertsEnabled:   spendAlertsEnabled   ?? this.spendAlertsEnabled,
        budget:               budget               ?? this.budget,
        error:                error,
      );
}

class AdminController extends StateNotifier<AdminState> {
  final SupabaseDataSource _ds;
  AdminController(this._ds) : super(AdminState.initial());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final users      = await _ds.getUsers();
      final categories = await _ds.getGlobalCategories();
      final cfg        = await _ds.getConfig();
      state = state.copyWith(
        loading: false, users: users, categories: categories,
        darkMode:             cfg['modoOscuro']    as bool? ?? false,
        notificationsEnabled: cfg['notificaciones'] as bool? ?? true,
        budget:               cfg['presupuesto']   as int?  ?? 500000,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ── usuarios ────────────────────────────────────────────────────────
  void setUsersQuery(String q) => state = state.copyWith(usersQuery: q);

  List<AdminUserEntity> filteredUsers() {
    final q = state.usersQuery.trim().toLowerCase();
    if (q.isEmpty) return state.users;
    return state.users
        .where((u) => u.name.toLowerCase().contains(q) ||
                      u.email.toLowerCase().contains(q))
        .toList();
  }

  Future<void> setUserStatus(String userId, AdminUserStatus status) async {
    try {
      await _ds.updateUserStatus(userId, status);
      state = state.copyWith(
        users: state.users.map(
          (u) => u.id == userId ? u.copyWith(status: status) : u,
        ).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── categorías ───────────────────────────────────────────────────────
  Future<void> addCategory(AdminCategoryEntity cat) async {
    try {
      final saved = await _ds.addGlobalCategory(cat);
      state = state.copyWith(categories: [saved, ...state.categories]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCategory(AdminCategoryEntity cat) async {
    try {
      final updated = await _ds.updateCategory(cat);
      state = state.copyWith(
        categories: state.categories.map(
          (c) => c.id == updated.id ? updated : c,
        ).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _ds.deleteCategory(id);
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── config ───────────────────────────────────────────────────────────
  Future<void> toggleDark(bool v) async {
    state = state.copyWith(darkMode: v);
    await _saveConfig();
  }

  Future<void> toggleNotifications(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    await _saveConfig();
  }

  Future<void> toggleSpendAlerts(bool v) async {
    state = state.copyWith(spendAlertsEnabled: v);
    await _saveConfig();
  }

  Future<void> setBudget(int v) async {
    state = state.copyWith(budget: v);
    await _saveConfig();
  }

  Future<void> _saveConfig() async {
    try {
      await _ds.saveConfig({
        'modoOscuro':    state.darkMode,
        'notificaciones': state.notificationsEnabled,
        'alertasGasto':  state.spendAlertsEnabled,
        'presupuesto':   state.budget,
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}