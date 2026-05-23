# 🏗️ Arquitectura Hexagonal - proyecto_movil

## Descripción General

El proyecto ha sido refactorizado completamente siguiendo los principios de **Arquitectura Hexagonal** (Puertos y Adaptadores). Esta arquitectura permite:

✅ **Desacoplamiento**: La lógica de negocio es independiente de los frameworks  
✅ **Testabilidad**: Fácil mockar dependencias e inyectar componentes  
✅ **Escalabilidad**: Agregar nuevas features sin impactar código existente  
✅ **Mantenibilidad**: Código organizado y responsabilidades claras  
✅ **Flexibilidad**: Cambiar de BD, API o UI sin alterar la lógica de negocio  

---

## 📁 Estructura de Carpetas

```
lib/
├── core/                          # Código compartido transversal
│   ├── errors/                    # Excepciones y tipos de error
│   ├── constants/                 # Constantes globales
│   └── extensions/                # Extensiones de clases
│
├── domain/                        # 🎯 LÓGICA DE NEGOCIO (sin dependencias externas)
│   ├── entities/                  # Modelos de negocio puros
│   ├── repositories/              # Interfaces (contratos)
│   ├── usecases/                  # Casos de uso
│   └── services/                  # Interfaces de servicios
│
├── infrastructure/                # 🔧 IMPLEMENTACIÓN TÉCNICA
│   ├── datasources/               # Fuentes de datos (JSON, API, BD)
│   ├── repositories/              # Implementaciones de repositorios
│   ├── services/                  # Implementaciones de servicios
│   └── mappers/                   # Conversión DTOs ↔ Entities
│
├── application/                   # ⚙️ ORQUESTACIÓN Y ESTADO
│   ├── providers/                 # Riverpod providers y controllers
│   └── dto/                       # Data Transfer Objects
│
├── presentation/                  # 🎨 INTERFAZ DE USUARIO
│   ├── admin/                     # Panel de administración
│   │   ├── pages/                 # Pantallas principales
│   │   └── widgets/               # Componentes reutilizables
│   ├── usuario/                   # Vistas del usuario
│   │   ├── pages/                 # Pantallas principales
│   │   └── widgets/               # Componentes reutilizables
│   ├── shared/                    # Widgets compartidos
│   └── routes.dart                # Definición de rutas
│
├── config/                        # ⚙️ CONFIGURACIÓN GLOBAL
│   └── app_theme.dart             # Tema de la aplicación
│
└── main.dart                      # Punto de entrada
```

---

## 🔄 Flujo de Dependencias

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  (Flutter Widgets, Pages, Vistas de Usuario)            │
│  └─ Usa: Application Providers                          │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                 APPLICATION LAYER                        │
│  (Riverpod Providers, Controllers, State Management)    │
│  └─ Orqueста: Domain + Infrastructure                  │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐      ┌──────────────────────┐
│  DOMAIN LAYER    │      │ INFRASTRUCTURE LAYER │
│  (Lógica Pura)   │      │ (Implementación)     │
│                  │      │                      │
│ • Entities       │      │ • DataSources        │
│ • Repositories   │──◄───┤ • Repositories       │
│   (interfaces)   │      │   (implemen.)        │
│ • UseCases       │      │ • Services           │
│ • Services       │      │ • Mappers            │
│   (interfaces)   │      │ • DB, API, Files     │
└──────────────────┘      └──────────────────────┘
        ▲                         ▲
        └─────────────────────────┘
        (Las dependencias
         siempre apuntan
         hacia adentro)

┌──────────────────────────────────────────────────────────┐
│               CORE LAYER (Transversal)                   │
│  (Errors, Constants, Extensions)                        │
└──────────────────────────────────────────────────────────┘
```

---

## 📚 Descripción de Capas

### 1. **Core** (`lib/core/`)
Código compartido transversal que **todas** las capas pueden usar.

- **errors/**: Excepciones y tipos de error
  - `exceptions.dart` - Excepciones técnicas
  - `failure.dart` - Tipos de fallos de negocio
  - `result.dart` - Tipo Result<T> para manejo de errores

- **constants/** - Constantes globales
- **extensions/** - Extensiones de clases

### 2. **Domain** (`lib/domain/`) 🎯
**Capa de lógica de negocio pura** - El corazón de la aplicación.

**Características:**
- ✅ NO tiene dependencias externas (sin Flutter, Riverpod, etc.)
- ✅ Define QUÉ hacer, no CÓMO hacerlo
- ✅ Independiente de frameworks

**Componentes:**

```dart
// entities/ - Modelos de negocio puros
TransactionEntity              // Modelo de transacción
AdminUserEntity, AdminCategoryEntity

// repositories/ - INTERFACES (Puertos)
abstract class TransactionsRepository {
  Future<void> add(TransactionEntity tx);
  Future<List<TransactionEntity>> getAll();
  // ...
}

// usecases/ - Casos de uso (lógica de aplicación)
class AddTransactionUseCase {
  Future<void> call(TransactionEntity tx) { ... }
}

// services/ - Interfaces de servicios
abstract class AuthService { ... }
```

### 3. **Infrastructure** (`lib/infrastructure/`) 🔧
**Capa de implementación técnica** - Donde viven los detalles técnicos.

**Características:**
- ✅ Implementaciones concretas de interfaces de Domain
- ✅ Acceso a BD, APIs, archivos, dispositivos
- ✅ Mapeo entre DTOs y Entities

**Componentes:**

```dart
// datasources/ - Fuentes de datos
LocalDataSource              // Lee/escribe en JSON + SharedPreferences

// repositories/ - Implementaciones concretas
JsonTransactionsRepository implements TransactionsRepository
InMemoryTransactionsRepository   // Para testing

// services/ - Implementaciones
SessionService              // Maneja sesión de usuario

// mappers/ - Conversión entre capas
TransactionMapper          // Entity ↔ DTO
AdminMapper
```

### 4. **Application** (`lib/application/`) ⚙️
**Capa de orquestación** - Conecta Domain e Infrastructure.

**Características:**
- ✅ Inyección de dependencias (Riverpod Providers)
- ✅ Orquestación de casos de uso y servicios
- ✅ Gestión de estado de aplicación

**Componentes:**

```dart
// providers/ - Riverpod Providers
final transactionsRepositoryProvider = Provider(...)
final addTransactionUseCaseProvider = Provider(...)
final transactionsControllerProvider = StateNotifierProvider(...)
final adminControllerProvider = StateNotifierProvider(...)

// Controllers - Gestión de estado
TransactionsController extends StateNotifier<TransactionsState>
AdminController extends StateNotifier<AdminState>
```

### 5. **Presentation** (`lib/presentation/`) 🎨
**Capa de interfaz de usuario** - Lo que ve el usuario.

**Características:**
- ✅ Conoce SOLO Application
- ✅ Jamás tiene lógica de negocio
- ✅ Solo renderi za y captura interacciones

**Estructura:**

```dart
presentation/
├── admin/
│   ├── pages/           # AdminDashboardPage, AdminUsersPage, etc.
│   └── widgets/         # Componentes reutilizables
├── usuario/
│   ├── pages/           # HomePage, LoginPage, HistoryPage, etc.
│   └── widgets/
├── shared/              # Widgets compartidos entre módulos
└── routes.dart          # Definición de rutas (GoRouter)
```

### 6. **Config** (`lib/config/`) ⚙️
**Configuración global** de la aplicación.

- `app_theme.dart` - Tema de Material Design
- `providers.dart` - Configuración de inyección (si es necesario)

---

## 🔀 Ejemplo de Flujo: Agregar una Transacción

### 1️⃣ Usuario presiona botón en UI (Presentation)
```dart
// presentation/usuario/pages/add_transaction_page.dart
ElevatedButton(
  onPressed: () async {
    // Captura interacción de usuario
    final tx = TransactionEntity(...);
    ref.read(transactionsControllerProvider.notifier).add(tx);
  },
)
```

### 2️⃣ Controller orquesta (Application)
```dart
// application/providers/app_providers.dart
class TransactionsController extends StateNotifier<TransactionsState> {
  Future<void> add(TransactionEntity tx) async {
    await addUseCase(tx);
    // Actualiza estado UI
  }
}
```

### 3️⃣ UseCase ejecuta lógica (Domain)
```dart
// domain/usecases/add_transaction_usecase.dart
class AddTransactionUseCase {
  Future<void> call(TransactionEntity tx) {
    if (tx.amount <= 0) throw Exception(...);
    return repo.add(tx);  // ← Llamarepository
  }
}
```

### 4️⃣ Repository guarda datos (Infrastructure)
```dart
// infrastructure/repositories/transactions_repository_impl.dart
class JsonTransactionsRepository implements TransactionsRepository {
  @override
  Future<void> add(TransactionEntity tx) {
    return dataSource.addTransaction(tx);
  }
}
```

### 5️⃣ DataSource persiste (Infrastructure)
```dart
// infrastructure/datasources/local_data_source.dart
Future<void> addTransaction(TransactionEntity tx) async {
  transactions.add(tx);
  await _save();  // ← Escribe en SharedPreferences
}
```

---

## 📝 Guía: Agregar Una Nueva Feature

### Pasos:

1. **Define la Entidad** en `domain/entities/`
   ```dart
   class BudgetEntity {
     final String id;
     final int limit;
     final String category;
   }
   ```

2. **Define el Repositorio (Interfaz)** en `domain/repositories/`
   ```dart
   abstract class BudgetsRepository {
     Future<void> add(BudgetEntity budget);
     Future<List<BudgetEntity>> getAll();
   }
   ```

3. **Implementa el Repositorio** en `infrastructure/repositories/`
   ```dart
   class BudgetsRepositoryImpl implements BudgetsRepository {
     final LocalDataSource dataSource;
     // ...
   }
   ```

4. **Crea el Caso de Uso** en `domain/usecases/`
   ```dart
   class AddBudgetUseCase {
     Future<void> call(BudgetEntity budget) { ... }
   }
   ```

5. **Agrega Providers** en `application/providers/`
   ```dart
   final budgetsRepositoryProvider = Provider(...);
   final addBudgetUseCaseProvider = Provider(...);
   ```

6. **Crea las Vistas** en `presentation/`
   ```dart
   class BudgetsPage extends ConsumerWidget { ... }
   ```

---

## ✅ Checklist de Migración

- ✅ Estructura de carpetas según Hexagonal
- ✅ Entidades en `domain/entities/`
- ✅ Interfaces de repositorios en `domain/repositories/`
- ✅ Casos de uso en `domain/usecases/`
- ✅ Data sources en `infrastructure/datasources/`
- ✅ Implementaciones en `infrastructure/repositories/`
- ✅ Servicios en `infrastructure/services/`
- ✅ Mappers en `infrastructure/mappers/`
- ✅ Providers en `application/providers/`
- ✅ Vistas en `presentation/`
- ✅ Rutas en `presentation/routes.dart`
- ✅ Tema en `config/app_theme.dart`
- ✅ Sin errores de compilación ✓
- ✅ Documentación actualizada

---

## 🚀 Ventajas de Esta Arquitectura

| Aspecto | Beneficio |
|--------|----------|
| **Testabilidad** | Mock repositories fácilmente, pruebas unitarias puras en Domain |
| **Mantenibilidad** | Código organizado, responsabilidades claras |
| **Escalabilidad** | Agregar features sin romper existentes |
| **Flexibility** | Cambiar de BD (SQLite → Firebase) sin tocar Domain |
| **Independencia** | Domain no depende de Flutter, solo de Dart puro |
| **Colaboración** | Equipos pueden trabajar en paralelo (Backend usa Domain, Mobile usa Presentation) |

---

## 📚 Recursos Adicionales

- [Arquitectura Hexagonal (Alistair Cockburn)](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Riverpod Docs](https://riverpod.dev/)
- [Repository Pattern](https://www.martinfowler.com/eaaCatalog/repository.html)

---

**Fecha de migración:** 23 de mayo de 2026  
**Estado:** ✅ Completado  
**Errores de compilación:** ✅ 0

