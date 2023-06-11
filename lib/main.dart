import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/added/added_page.dart';
import 'package:lapse/business/memory/home/home_page.dart';
import 'package:lapse/theme/themes.dart';
import 'package:lapse/widget/toasts.dart';

void main() {
  runApp(const LapseApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const MemoryHomePage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'lapse/memory/added',
          builder: (BuildContext context, GoRouterState state) =>
              const AddedPage(),
        ),
      ],
    ),
  ],
);

class LapseApp extends StatefulWidget {
  const LapseApp({super.key});

  @override
  State createState() =>
      _LapseAppState(); // This widget is the root of your application.
}

class _LapseAppState extends State<LapseApp> {
  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      builder: FToastBuilder(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Lapse',
      theme: Themes.lapseTheme,
    );
  }
}
