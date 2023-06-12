import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/added/added_service.dart';
import 'package:lapse/business/memory/added/amend_timeline_widget.dart';
import 'package:lapse/business/memory/repository/database/database_repository.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/l10n/localizations.dart';
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

  final Map<int, DateTime> _timelineMap = {};
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
                          controller: _contentEditingController,
                          decoration: buildInputDecoration(
                              localizations.memAddedContentHint),
                        ),
                      ),
                    ])))));

    var contentWidget = Stack(
      children: [
        CustomScrollView(
          slivers: [
            topWidget,
            AmendTimelineWidget(
              paddingHorizontal: paddingStart * 2,
              timelineMap: _timelineMap,
            ),
          ],
        ),
        Positioned(
          bottom: 50,
          child: Container(
            child: MaterialButton(
              onPressed: () {
                print(
                    "-----MaterialButton------: ${_titleEditingController.value.text}");
                _createMemoryContent(context);
              },
              child: Text(localizations.memAddedSubmit),
            ),
          ),
        )
      ],
    );

    return contentWidget;
  }

  List<DateTime> _getDateTimes() {
    List<DateTime> dateTimes = [];
    _timelineMap.values.forEach((selectedAt) {
      dateTimes.add(selectedAt);
    });
    return dateTimes;
  }

  _createMemoryContent(BuildContext context) async {
    var title = _titleEditingController.value.text;
    var content = _contentEditingController.value.text;

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
    Toasts.toast("创建成功");
    context.go("/");
  }
}
