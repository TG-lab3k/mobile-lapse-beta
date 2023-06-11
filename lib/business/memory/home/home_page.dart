import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/home/home_service.dart';
import 'package:lapse/business/memory/home/home_timeline_widget.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/infra/data/database/database_helper.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/toasts.dart';

class MemoryHomePage extends StatefulWidget {
  const MemoryHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _MemoryHomePageState();
}

const double heightItem = 15;

class _MemoryHomePageState extends State<MemoryHomePage> {
  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeService()..listMemoryContents(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Center(
            child: Text("Lapse"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Assets.image("added.png"),
              tooltip: '新增',
              onPressed: () {
                context.go("/lapse/memory/added");
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeService, HomeState>(
          builder: (context, homeState) => Container(
            height: double.infinity,
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            child: HomeTimelineWidget(
              homeState: homeState,
            ),
          ),
        ),
      ),
    );
  }
}
