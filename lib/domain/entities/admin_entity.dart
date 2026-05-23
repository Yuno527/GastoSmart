import 'package:flutter/material.dart';

enum AdminUserStatus { active, inactive, blocked }

enum AdminUserRole { admin, user }

class AdminUserEntity {
  final String id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final AdminUserStatus status;
  final AdminUserRole role;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.status,
    required this.role,
  });

  AdminUserEntity copyWith({AdminUserStatus? status, AdminUserRole? role}) {
    return AdminUserEntity(
      id: id,
      name: name,
      email: email,
      password: password,
      createdAt: createdAt,
      status: status ?? this.status,
      role: role ?? this.role,
    );
  }
}

class AdminCategoryEntity {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const AdminCategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  AdminCategoryEntity copyWith({String? name, IconData? icon, Color? color}) {
    return AdminCategoryEntity(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
