import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/added/common/tag_menu.dart';
import 'package:lapse/business/memory/added/memory/added_service.dart';
import 'package:lapse/business/memory/common/util/common_formats.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:lapse/widget/skeleton.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simple_tags/simple_tags.dart';

class AddedCommonPage extends StatefulWidget {
  int? repeat = 1;

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
  String? _dateTimePickerFormat;
  DateTimePickerLocale _locale = DateTimePickerLocale.zh_cn;
  final TextEditingController _spendTimeEditingController =
      TextEditingController();
  DateTime? _reminderTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch +
          Duration(minutes: 30).inMilliseconds);

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  void dispose() {
    super.dispose();
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
    _spendTimeEditingController.text = "30";
    final AppLocalizations localizations = TextI18ns.from(context);
    const radius = Radius.circular(8.0);
    const textFieldStyle = TextStyle(fontSize: 16, color: colorPrimary7);
    var topWidget = SliverToBoxAdapter(
        child: Container(
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    decoration: const BoxDecoration(
                        color: colorPrimary6,
                        borderRadius: BorderRadius.only(
                            topLeft: radius, topRight: radius)),
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(
                            paddingStart, 0, paddingStart, 0),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          decoration: const BoxDecoration(
                              color: colorPrimary9,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
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
                        ))),
              ],
            )));

    var contentWidget = Container(
        decoration: const BoxDecoration(color: colorPrimary6),
        child: CustomScrollView(
          slivers: [
            topWidget,
            SliverToBoxAdapter(
                child: Container(
              decoration: const BoxDecoration(color: colorPrimary6),
              padding:
                  const EdgeInsets.fromLTRB(paddingStart, 10, paddingStart, 10),
              child: buildTags(),
            )),
            SliverToBoxAdapter(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        paddingStart, 10, paddingStart, 10),
                    child: Row(
                      children: <Widget>[
                        Text("预计完成时长"),
                        Flexible(
                          child: SizedBox(
                              width: 50,
                              child: Container(
                                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: colorPrimary9,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                    child: TextField(
                                        maxLines: 1,
                                        style: textFieldStyle,
                                        cursorColor: colorPrimary8,
                                        keyboardType: TextInputType.number,
                                        controller: _spendTimeEditingController,
                                        decoration: buildInputDecoration("")),
                                  ))),
                        ),
                        Text("分钟")
                      ],
                    ))),
            SliverToBoxAdapter(
                child: Container(
              padding:
                  const EdgeInsets.fromLTRB(paddingStart, 10, paddingStart, 10),
              child: Row(
                children: <Widget>[
                  Text("提醒时间:"),
                  Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Clickable(
                        host: Text(
                            CommonFormats.dHHmmFormat.format(_reminderTime!)),
                        listener: (Widget hostWidget) {
                          _showDateTimePicker(
                              context, DateTime.now(), _reminderTime!);
                        },
                      ))
                ],
              ),
            )),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(children: [
                  Container(
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsets.only(left: 6),
                      child: Text("是否重复: ")),
                  Row(
                    children: [
                      Radio(
                        activeColor: Color.fromARGB(0xff, 0xff, 0x33, 0x33),
                        value: 1,
                        groupValue: widget.repeat,
                        onChanged: (value) {
                          setState(() {
                            widget.repeat = value;
                          });
                        },
                      ),
                      Text("不重复"),
                      SizedBox(width: 10),
                      Radio(
                        value: 2,
                        groupValue: widget.repeat,
                        onChanged: (value) {
                          setState(() {
                            widget.repeat = value;
                          });
                        },
                        activeColor: Color.fromARGB(0xff, 0xff, 0x33, 0x33),
                      ),
                      Text("每周重复"),
                      SizedBox(width: 10),
                      Radio(
                        value: 3,
                        groupValue: widget.repeat,
                        onChanged: (value) {
                          setState(() {
                            widget.repeat = value;
                          });
                        },
                        activeColor: Color.fromARGB(0xff, 0xff, 0x33, 0x33),
                      ),
                      Text("每月重复")
                    ],
                  )
                ]),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 60, bottom: 30),
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

  void _showDateTimePicker(
      BuildContext context, DateTime startAt, DateTime selectedAt) {
    if (_dateTimePickerFormat == null) {
      _dateTimePickerFormat = TextI18ns.from(context).memAddedDateTimeFormat;
    }
    DatePicker.showDatePicker(
      context,
      minDateTime: startAt,
      initialDateTime: selectedAt,
      dateFormat: _dateTimePickerFormat,
      locale: _locale!,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirmTextStyle: TextStyle(color: colorPrimary8),
        cancelTextStyle: TextStyle(color: colorPrimary8),
      ),
      pickerMode: DateTimePickerMode.datetime,
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _reminderTime = dateTime;
        });
      },
    );
  }

  Widget buildTags() {
    List<String> tagDataList = [
      '# 英语/单词/高频词',
      '# 英语/单词/阅读生词',
      '# 英语/阅读',
      '# 英语/看电影',
      '# 数学/逻辑思维',
      '# 数学/几何空间',
      '# 数学/推理',
    ];

    return SimpleTags(
      content: tagDataList,
      wrapSpacing: 4,
      wrapRunSpacing: 4,
      onTagPress: (tag) {
        print('pressed $tag');
      },
      onTagLongPress: (tag) {
        print('long pressed $tag');
      },
      onTagDoubleTap: (tag) {
        print('double tapped $tag');
      },
      tagContainerPadding: EdgeInsets.all(6),
      tagTextStyle: TextStyle(
          fontSize: 11, color: Color.fromARGB(0xff, 0x1b, 0xdb, 0x96)),
      tagContainerDecoration: BoxDecoration(
        color: Color.fromARGB(0x1a, 0x66, 0xde, 0xb3),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memAddedTitle;
    return Skeleton(title: label, body: buildPage(context));
  }
}
