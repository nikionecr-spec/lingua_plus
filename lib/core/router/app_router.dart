import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dictionary/dictionary_screen.dart';
import '../../features/dictionary/favorites_screen.dart';
import '../../features/dictionary/word_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/library/reader_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/translator/translator_screen.dart';
import '../constants/app_strings.dart';
import '../../shared/widgets/app_shell.dart';

/// All route paths (single source of truth).
class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dictionary = '/dictionary';
  static const String wordDetail = '/word';
  static const String favorites = '/favorites';
  static const String library = '/library';
  static const String reader = '/reader';
  static const String translator = '/translator';
  static const String settings = '/settings';
}

/// Paths of the 4 bottom-nav branches, in order.
class ShellBranchPaths {
  ShellBranchPaths._();

  static const List<String> paths = [
    Routes.home,
    Routes.dictionary,
    Routes.library,
    Routes.translator,
  ];
}

final GlobalKey<NavigatorState> _rootKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final List<GlobalKey<NavigatorState>> _branchKeys = List.generate(
  4,
  (i) => GlobalKey<NavigatorState>(debugLabel: 'branch-$i'),
);

/// Builds the app router. [sp] is the bootstrapped SharedPreferences used
/// for the onboarding redirect (read synchronously — already loaded).
GoRouter buildAppRouter({required dynamic sp}) {
  final onboardedFlag = (sp.getBool('onboarded') ?? false) as bool;

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboardedFlag ? Routes.home : Routes.onboarding,
    redirect: (context, state) {
      final onboarded = sp.getBool('onboarded') ?? false;
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded && !atOnboarding) return Routes.onboarding;
      if (onboarded && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.wordDetail,
        builder: (context, state) => WordDetailScreen(
          word: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.reader,
        builder: (context, state) => ReaderScreen(
          bookId: state.uri.queryParameters['book'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _branchKeys[0],
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _branchKeys[1],
            routes: [
              GoRoute(
                path: Routes.dictionary,
                builder: (context, state) => const DictionaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _branchKeys[2],
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _branchKeys[3],
            routes: [
              GoRoute(
                path: Routes.translator,
                builder: (context, state) => const TranslatorScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Titles for nav destinations (kept here to stay in sync with branches).
const List<String> kNavTitles = [
  AppStrings.navHome,
  AppStrings.navDictionary,
  AppStrings.navLibrary,
  AppStrings.navTranslator,
];
