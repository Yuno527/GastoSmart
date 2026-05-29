import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:proyecto_movil/presentation/routes.dart';
import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/infrastructure/services/session_service.dart';
import 'package:proyecto_movil/infrastructure/datasources/supabase_data_source.dart';
import 'package:proyecto_movil/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wipqthtzcgfqjwgpjiuo.supabase.co',
    anonKey: 'sb_publishable_vH60qq8XlpwFL0EPz23x2g_VAGD76NW',
  );

  final sessionService = SessionService();
  await sessionService.init();
  
  // Verificar si el onboarding debe mostrarse
  bool showOnboarding = true;
  
  if (sessionService.isLoggedIn) {
    // Si el usuario está logueado, verificar el estado en Supabase
    final supabaseClient = Supabase.instance.client;
    final dataSource = SupabaseDataSource(supabaseClient);
    final onboardingDone = await dataSource.getOnboardingCompletado(sessionService.currentUserId);
    showOnboarding = !onboardingDone;
  } else {
    // Si no está logueado, verificar el estado en SharedPreferences
    final deviceOnboardingDone = await sessionService.isDeviceOnboardingDone();
    showOnboarding = !deviceOnboardingDone;
  }

  runApp(
    ProviderScope(
      overrides: [
        sessionServiceProvider.overrideWithValue(sessionService),
        showOnboardingProvider.overrideWith((_) => showOnboarding),
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