import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/added/added_service.dart';
import 'package:lapse/business/memory/added/amend_timeline_widget.dart';
import 'package:lapse/business/memory/added/learning_curve.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:lapse/widget/skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:lapse/theme/colors.dart';

class AddedPage extends StatefulWidget {
  const AddedPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddedPageState();
  }
}

const double paddingStart = 16;
const double paddingTop = 15;

class _AddedPageState extends State<AddedPage> {
  final itemKey = UniqueKey();
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  List<DateTime> _timelineList = [];
  final AddedService _addedService = AddedService();

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memAddedTitle;
    return Skeleton(title: label, body: buildPage(context));
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
                    child: Column(children: [
                      Container(
                          decoration: const BoxDecoration(
                              color: colorPrimary5,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                          child: TextField(
                            maxLines: 1,
                            style: textFieldStyle,
                            cursorColor: colorPrimary8,
                            decoration: buildInputDecoration(
                                localizations.memAddedTitleHint),
                            keyboardType: TextInputType.text,
                            controller: _titleEditingController,
                          )),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: const BoxDecoration(
                            color: colorPrimary5,
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        child: TextField(
                          minLines: 8,
                          maxLines: 8,
                          style: textFieldStyle,
                          cursorColor: colorPrimary8,
                          controller: _contentEditingController,
                          decoration: buildInputDecoration(
                              localizations.memAddedContentHint),
                        ),
                      ),
                    ])))));

    var contentWidget = Container(
        decoration: const BoxDecoration(color: colorPrimary6),
        child: CustomScrollView(
          slivers: [
            topWidget,
            AmendTimelineWidget(
              paddingHorizontal: paddingStart * 2,
              timelineList: _timelineList,
            ),
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

  List<DateTime> _getDateTimes() {
    List<DateTime> dateTimes = [];
    _timelineList.forEach((selectedAt) {
      dateTimes.add(selectedAt);
    });
    return dateTimes;
  }

  _createMemoryContent(BuildContext context) async {
    var title = _titleEditingController.value.text;
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
          status: ScheduleStatus.idle.index);
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
}
