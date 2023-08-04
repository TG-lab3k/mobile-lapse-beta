import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/added/common/tag_menu.dart';
import 'package:lapse/business/memory/added/memory/added_service.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/infra/plugin/calendar_plugin.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:lapse/widget/skeleton.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddedCommonPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddedCommonState();
  }
}

const double paddingStart = 16;
const double paddingTop = 15;

class _AddedCommonState extends State<AddedCommonPage> {
  final TextEditingController _contentEditingController =
      TextEditingController();
  List<DateTime> _timelineList = [];
  final AddedService _addedService = AddedService();
  TagMenu? tagMenu;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
    tagMenu = TagMenu.register(context, _focusNode, _contentEditingController);
  }

  @override
  void dispose() {
    super.dispose();
    tagMenu?.dispose();
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 10, color: colorPrimary2),
        fillColor: Colors.transparent,
        filled: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: InputBorder.none);
  }

  List<DateTime> _getDateTimes() {
    List<DateTime> dateTimes = [];
    _timelineList.forEach((selectedAt) {
      dateTimes.add(selectedAt);
    });
    return dateTimes;
  }

  _createMemoryContent(BuildContext context) async {
    var title = "";
    var content = _contentEditingController.value.text;
    if (title.isEmpty) {
      String noTitle = TextI18ns.from(context).memAddedTipsNoTitle;
      Toasts.toast(noTitle);
      return;
    }
    var times = _getDateTimes();
    List<ScheduleBo> schedules = [];
    times.forEach((time) {
      var scheduleBo = ScheduleBo(
          actionAt: time.millisecondsSinceEpoch,
          status: ScheduleStatus.todo.index);
      schedules.add(scheduleBo);
    });

    TenantBo tenantBo = TenantBo(id: 1);

    MemoryContentBo memoryContentBo = MemoryContentBo(
        title: title, content: content, tenant: tenantBo, schedules: schedules);

    String appName = TextI18ns.from(context).appName;
    await _addedService.createMemoryContent(memoryContentBo, appName);
    String memAddedSuccess = TextI18ns.from(context).memAddedSuccess;
    Toasts.toast(memAddedSuccess);
    context.go("/");
  }

  Widget buildPage(BuildContext context) {
    final AppLocalizations localizations = TextI18ns.from(context);
    const radius = Radius.circular(8.0);
    const textFieldStyle = TextStyle(fontSize: 16, color: colorPrimary7);
    var topWidget = SliverToBoxAdapter(
        child: Container(
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 00),
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                decoration: const BoxDecoration(
                    color: colorPrimary6,
                    borderRadius:
                        BorderRadius.only(topLeft: radius, topRight: radius)),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        paddingStart, paddingTop, paddingStart, 0),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      decoration: const BoxDecoration(
                          color: colorPrimary5,
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: TextField(
                        minLines: 10,
                        maxLines: 10,
                        style: textFieldStyle,
                        cursorColor: colorPrimary8,
                        controller: _contentEditingController,
                        focusNode: _focusNode,
                        decoration: buildInputDecoration(
                            localizations.eventContentHint),
                      ),
                    )))));

    var contentWidget = Container(
        decoration: const BoxDecoration(color: colorPrimary6),
        child: CustomScrollView(
          slivers: [
            topWidget,
            SliverToBoxAdapter(
                child: Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 30),
              child: Clickable(
                listener: (_) => _createMemoryContent(context),
                host: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                      color: colorPrimary1,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Center(
                      child: Text(
                    localizations.memAddedSubmit,
                    style: TextStyle(
                      color: colorPrimary6,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
            ))
          ],
        ));

    return contentWidget;
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memAddedTitle;
    Future.delayed(Duration(milliseconds: 100), () async {
      var status = await CalendarPlugin.checkAndRequestCalendarPermission();
      print("@checkAndRequestCalendarPermission status: $status");
    });
    return Skeleton(title: label, body: buildPage(context));
  }
}
