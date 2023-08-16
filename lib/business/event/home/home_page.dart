import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/event/home/home_service.dart';
import 'package:lapse/business/event/home/schedule_page.dart';
import 'package:lapse/business/event/home/schedule_service.dart';
import 'package:lapse/business/event/repository/database/tag.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
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
          child: Text("日程"),
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
      drawer: Drawer(
        child: _AppMenu(),
      ),
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

class _AppMenu extends StatelessWidget {
  HomeMenuService _homeMenuService = HomeMenuService();
  GlobalKey _blocProviderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        key: _blocProviderKey,
        create: (blocContext) => _homeMenuService..getHomeMenuInfo(),
        child: BlocBuilder<HomeMenuService, HomeMenuState>(
            builder: (blocContext, homeMenuState) {
          return Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: CustomScrollView(
              slivers: [
                buildHeader(),
                buildAppMenu(context),
                buildDivider(),
                buildCustomerMenu(homeMenuState.customerTagList),
              ],
            ),
          );
        }));
  }

  Widget buildHeader() {
    return SliverToBoxAdapter(
      child: SizedBox(height: 400),
    );
  }

  Widget buildAppMenu(BuildContext context) {
    var i18ns = TextI18ns.from(context);
    return SliverToBoxAdapter(
        child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Clickable(
              host: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  child: Assets.image("ic_appmenu_howtous.png"),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: Text(i18ns.menuHowtous,
                        style: TextStyle(fontSize: 14, color: colorPrimary03)))
              ],
            ),
          )),

          //
          Clickable(
              host: Row(
            children: [
              Container(
                height: 15,
                width: 15,
                child: Assets.image("ic_appmenu_customerservice.png"),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(i18ns.menuCustomerservice,
                      style: TextStyle(fontSize: 14, color: colorPrimary03)))
            ],
          )),
        ],
      ),
    ));
  }

  Widget buildDivider() {
    return SliverToBoxAdapter(child: Divider(height: 1, color: colorPrimary2));
  }

  Widget buildCustomerMenu(List<TagBo>? tagList) {
    var count = tagList != null ? tagList!.length : 0;
    print("#buildCustomerMenu# $count");
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      TagBo tagBo = tagList!.elementAt(index);
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Clickable(
                host: Text(
              "#  ${tagBo.tag}",
              style: TextStyle(fontSize: 14, color: colorPrimary04),
            )),
            Expanded(
                child: Container(
              alignment: Alignment.topRight,
              height: 40,
              width: 40,
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
              child: IconButton(
                icon: Assets.image("ic_menu_ellipsis_horizontal.png"),
                onPressed: () {
                  //TODO
                  print("点击标签");
                },
              ),
            ))
          ],
        ),
      );
    }, childCount: count));
  }
}
