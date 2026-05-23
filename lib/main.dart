import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/presentation/routes.dart';
import 'package:proyecto_movil/infrastructure/datasources/local_data_source.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';
import 'package:proyecto_movil/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa data source: carga desde shared_preferences o desde assets/data/app_data.json
  final localDataSource = LocalDataSource();
  await localDataSource.init();

  // Inicializa servicio de sesión
  final sessionService = SessionService();
  await sessionService.init();

  runApp(
    ProviderScope(
      overrides: [
        localDataSourceProvider.overrideWithValue(localDataSource),
        sessionServiceProvider.overrideWithValue(sessionService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOnboarding = ref.watch(showOnboardingProvider);
    final router = buildRouter(showOnboarding: showOnboarding);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
