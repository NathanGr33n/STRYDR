import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'services/run_tracking_service.dart';
import 'views/home/home_screen.dart';
import 'views/run/run_screen.dart';
import 'views/summary/summary_screen.dart';
import 'views/insights/insights_screen.dart';
import 'views/goal/goal_screen.dart';

class StryderApp extends StatelessWidget {
  StryderApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/run',
        builder: (context, state) => const RunScreen(),
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) {
          final runState = state.extra as RunState?;
          return SummaryScreen(
            runState: runState ?? const RunState(),
          );
        },
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/goal',
        builder: (context, state) => const GoalScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'STRYDER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
