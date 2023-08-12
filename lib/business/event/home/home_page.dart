import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/event/home/schedule_page.dart';
import 'package:lapse/business/event/home/schedule_service.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EventHomePage extends StatefulWidget {
  EventHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    print("#MemoryHomePage# ------ @createState ");
    return _EventHomePageState();
  }
}

const double heightItem = 15;

class _EventHomePageState extends State<EventHomePage> {
  GlobalKey _blocProviderKey = GlobalKey();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
    _scheduleService?.listContentCompleted = () async {
      _refreshController.refreshCompleted();
    };
    print("#_MemoryHomePageState# ------ @initState ");
  }

  @override
  void didUpdateWidget(covariant EventHomePage oldWidget) {
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
    var i18ns = TextI18ns.from(context);
    _scheduleService.localizations = i18ns;
    return BlocProvider(
        key: _blocProviderKey,
        create: (blocContext) => _scheduleService..listScheduleEvent(),
        child: BlocBuilder<ScheduleService, ScheduleState>(
            builder: (blocContext, scheduleState) {
          return SchedulePage(
              scheduleState, _refreshController, () async => _listHome());
        }));
  }

  void _listHome() async {
    print("#_MemoryHomePageState# -------- @_listHome");
    _scheduleService.listScheduleEvent();
  }
}
