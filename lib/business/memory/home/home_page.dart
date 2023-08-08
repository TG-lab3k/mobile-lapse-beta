import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/home/home_service.dart';
import 'package:lapse/business/memory/home/home_timeline_widget.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MemoryHomePage extends StatefulWidget {
  MemoryHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    print("#MemoryHomePage# ------ @createState ");
    return _MemoryHomePageState();
  }
}

const double heightItem = 15;

class _MemoryHomePageState extends State<MemoryHomePage> {
  GlobalKey _blocProviderKey = GlobalKey();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
    _homeService.listContentCompleted = () async {
      _refreshController.refreshCompleted();
    };
    print("#_MemoryHomePageState# ------ @initState ");
  }

  @override
  void didUpdateWidget(covariant MemoryHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _listHome();
    print("#_MemoryHomePageState# ------ @didUpdateWidget ");
  }

  @override
  Widget build(BuildContext context) {
    print("#_MemoryHomePageState# ------ @build ");
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Text("Lapse"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Assets.image("added.png"),
            onPressed: () {
              context.go("/lapse/event/added/common");
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    print("#_MemoryHomePageState# ------ @_buildBody ");
    return BlocProvider(
        key: _blocProviderKey,
        create: (blocContext) => _homeService..listMemoryContents(),
        child: BlocBuilder<HomeService, HomeState>(
            builder: (blocContext, homeState) {
          return HomeTimelineWidget(
            _refreshController,
            homeState: homeState,
            onRefreshList: () async => _listHome(),
          );
        }));
  }

  void _listHome() async {
    print("#_MemoryHomePageState# -------- @_listHome");
    _homeService.listMemoryContents();
  }
}
