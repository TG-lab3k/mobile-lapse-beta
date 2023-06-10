import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lapse/business/memory/home/home_page.dart';
import 'package:lapse/infra/data/database/database_helper.dart';
import 'package:lapse/widget/toasts.dart';

void main() {
  runApp(const LapseApp());
}

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
    DatabaseHelper().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Lapse',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MemoryHomePage(title: 'Lapse'),
    );
  }
}
