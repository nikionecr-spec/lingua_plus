import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/isar_database.dart';
import 'shared/widgets/app_shell.dart';

/// Bootstrap: open Isar, seed bundled dictionary, load prefs, build router.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final sp = await SharedPreferences.getInstance();
  final isar = await IsarDatabase.open();

  // First launch: seed the bundled offline dictionary.
  try {
    final jsonText =
        await rootBundle.loadString('assets/data/dictionary.json');
    await IsarDatabase.seedDictionary(isar, jsonText);
  } catch (e) {
    debugPrint('dictionary seed skipped: $e');
  }

  final router = buildAppRouter(sp: sp);

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPrefsProvider.overrideWithValue(sp),
        appRouterProvider.overrideWithValue(router),
      ],
      child: const LinguaPlusApp(),
    ),
  );
}

class LinguaPlusApp extends ConsumerWidget {
  const LinguaPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        // Persian-first: force RTL at the root. English content is
        // wrapped in `En` (LTR) locally inside widgets.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: GradientBackground(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
