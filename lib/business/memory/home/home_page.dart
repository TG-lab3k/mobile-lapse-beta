import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/home/home_service.dart';
import 'package:lapse/business/memory/home/home_timeline_widget.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MemoryHomePage extends StatefulWidget {
  MemoryHomePage({super.key});

  final HomeService _homeService = HomeService();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  State<StatefulWidget> createState() => _MemoryHomePageState();
}

const double heightItem = 15;

class _MemoryHomePageState extends State<MemoryHomePage> {
  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
    print("#MemoryHomePage# ------ @initState ");
  }

  @override
  void didUpdateWidget(covariant MemoryHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("#MemoryHomePage# ------ @didUpdateWidget ");
    widget._refreshController.requestRefresh();
  }

  @override
  Widget build(BuildContext context) {
    print("#MemoryHomePage# ------ @build ");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Text("Lapse"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Assets.image("added.png"),
            tooltip: TextI18ns.from(context).memAddedTitle,
            onPressed: () {
              context.go("/lapse/memory/added");
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocProvider(
        create: (blocContext) => widget._homeService..listMemoryContents(),
        child: BlocBuilder<HomeService, HomeState>(
            builder: (blocContext, homeState) {
          return SmartRefresher(
            controller: widget._refreshController,
            enablePullUp: true,
            header: WaterDropMaterialHeader(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onRefresh: () => _listHome(context),
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(color: colorPrimary5),
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
              child: HomeTimelineWidget(homeState: homeState),
            ),
            physics: BouncingScrollPhysics(),
          );
        }));
  }

  void _listHome(BuildContext context) {
    widget._homeService.listMemoryContents();
  }
}
