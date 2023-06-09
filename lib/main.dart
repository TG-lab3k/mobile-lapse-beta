import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lapse/business/memory/added/added_page.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AddedPage(), //MemoryHomePage(title: 'Lapse'),
    );
  }
}
