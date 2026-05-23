import 'package:flutter/material.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';

class AdminMapper {
  static Map<String, dynamic> toMap(AdminUserEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'email': entity.email,
      'password': entity.password,
      'createdAt': entity.createdAt.toIso8601String(),
      'status': entity.status.toString(),
      'role': entity.role.toString(),
    };
  }

  static AdminUserEntity fromMap(Map<String, dynamic> map) {
    return AdminUserEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: AdminUserStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => AdminUserStatus.inactive,
      ),
      role: AdminUserRole.values.firstWhere(
        (e) => e.toString() == map['role'],
        orElse: () => AdminUserRole.user,
      ),
    );
  }

  static Map<String, dynamic> categoryToMap(AdminCategoryEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'icon': entity.icon.toString(),
      'color': entity.color.toString(),
    };
  }

  static AdminCategoryEntity categoryFromMap(Map<String, dynamic> map) {
    return AdminCategoryEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: Icons.label_outline,
      color: Colors.grey,
    );
  }
}
