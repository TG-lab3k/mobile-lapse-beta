import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/event/added/common/tag_menu.dart';
import 'package:lapse/business/event/added/added_service.dart';
import 'package:lapse/business/event/common/util/common_formats.dart';
import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';
import 'package:lapse/business/event/repository/database/tag.dart';
import 'package:lapse/business/event/repository/database/tenant.dart';
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

class _Event {
  String? title;
  String? content;
  List<String>? tags;

  _Event(this.title, this.content, this.tags);
}

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

  _createEvent(BuildContext context) async {
    _Event? event = _resolveEventContent();
    if (event != null) {
      DateTime nowAt = DateTime.now();
      if (nowAt.isAfter(_reminderTime!)) {
        String reminderTimeBeforeNow =
            TextI18ns.from(context).eventAdded_reminderTimeBeforeNow;
        Toasts.toast(reminderTimeBeforeNow);
        return;
      }

      var scheduleBo = ScheduleBo(
          actionAt: _reminderTime!.millisecondsSinceEpoch,
          status: ScheduleStatus.todo.index);
      List<ScheduleBo> schedules = [scheduleBo];
      TenantBo tenantBo = TenantBo(id: 1);
      EventBo eventBo = EventBo(
          title: event.title,
          content: event.content,
          tenant: tenantBo,
          schedules: schedules);

      List<String>? tagList = event.tags;
      Map<String, Map> tagMap = HashMap();
      Map<String, TagBo> tagBoMap = HashMap();
      tagList?.forEach((originTagString) {
        //Resolve tag
        List<String> tagStrList = originTagString.split("/");
        Map? downMap;
        TagBo? downTagBo;
        for (int i = 0; i < tagStrList.length; i++) {
          String tag = tagStrList.elementAt(i);
          if (i == 0) {
            downMap = tagMap[tag];
            if (downMap == null) {
              downMap = HashMap();
              tagMap[tag] = downMap;
            }

            downTagBo = tagBoMap[tag];
            if (downTagBo == null) {
              downTagBo = TagBo(tag: tag);
              downTagBo.children = [];
              tagBoMap[tag] = downTagBo;
            }
          } else {
            Map? nextMap = downMap?[tag];
            if (nextMap == null) {
              nextMap = HashMap();
              downMap?[tag] = nextMap;

              TagBo? nextTagBo = TagBo(tag: tag);
              nextTagBo.children = [];
              downTagBo?.children?.add(nextTagBo);
              downTagBo = nextTagBo;
            }
            downMap = nextMap;
          }
        }
      });

      eventBo.tags = List.from(tagBoMap.values);
      String appName = TextI18ns.from(context).appName;
      await _addedService.createEventContent(eventBo, appName);
      String memAddedSuccess = TextI18ns.from(context).memAddedSuccess;
      Toasts.toast(memAddedSuccess);
      context.go("/");
    }
  }

  Widget buildPage(BuildContext context) {
    final AppLocalizations localizations = TextI18ns.from(context);
    const radius = Radius.circular(8.0);
    const textFieldStyle = TextStyle(fontSize: 16, color: colorPrimary7);
    var topWidget = SliverToBoxAdapter(
        child: Container(
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                decoration: const BoxDecoration(
                    color: colorPrimary6,
                    borderRadius:
                        BorderRadius.only(topLeft: radius, topRight: radius)),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        paddingStart, 0, paddingStart, 0),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      decoration: const BoxDecoration(
                          color: colorPrimary9,
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
              decoration: const BoxDecoration(color: colorPrimary6),
              padding:
                  const EdgeInsets.fromLTRB(paddingStart, 10, paddingStart, 10),
              child: buildTags(),
            )),
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
                listener: (_) => _createEvent(context),
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
      '#英语/单词/高频词',
      '#英语/单词/阅读生词',
      '#英语/阅读',
      '#英语/看电影',
      '#数学/逻辑思维',
      '#数学/几何空间',
      '#数学/推理',
    ];

    return SimpleTags(
      content: tagDataList,
      wrapSpacing: 4,
      wrapRunSpacing: 4,
      onTagPress: _resolveTag,
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

  _resolveTag(String tag) {
    var text = _contentEditingController.value.text;
    if (text.isEmpty || !text.contains(tag)) {
      _contentEditingController.text = text + ' ' + tag;
    }
  }

  _Event? _resolveEventContent() {
    var text = _contentEditingController.value.text;
    if (text.trim().isEmpty) {
      String canNotEmpty =
          TextI18ns.from(context).eventAdded_contentCanNotEmpty;
      Toasts.toast(canNotEmpty);
      return null;
    }

    /**
     * 输入规则
     * 标题<换号符号>
     * 内容<换号符号>
     * #标签
     */

    int titleEndIndex = text.indexOf("\n");
    String title = "";
    String eventContent = "";
    int contentStartIndex = 0;
    List<String> tagList = [];
    if (titleEndIndex != -1) {
      title = text.substring(0, titleEndIndex);
      contentStartIndex = titleEndIndex + 1;

      text = text.substring(contentStartIndex);
      eventContent = _resolveEventTag(text, tagList);
    } else {
      title = _resolveEventTag(text, tagList);
    }

    print("#_resolveEventContent# title: [$title]");
    print("#_resolveEventContent# content: [$eventContent]");
    tagList.forEach((tag) {
      print("#_resolveEventContent# tag: [$tag]");
    });
    if (title.isEmpty) {
      String canNotEmpty = TextI18ns.from(context).eventAdded_titleCanNotEmpty;
      Toasts.toast(canNotEmpty);
      return null;
    }

    return _Event(title, eventContent, tagList);
  }

  _resolveEventTag(String text, List<String> tagList) {
    //Event Content And Tags
    String eventContent = "";
    //resolve tags
    int tagSearchStartIndex = 0;
    int tagStartIndex = text.indexOf("#", tagSearchStartIndex);
    if (tagStartIndex > 0) {
      eventContent = text.substring(0, tagStartIndex);
      int tagEndIndex = -1;
      do {
        tagEndIndex = text.indexOf("#", tagStartIndex + 2);
        if (tagEndIndex == -1) {
          tagEndIndex = text.indexOf(" ", tagStartIndex + 1);
          if (tagEndIndex == -1) {
            tagEndIndex = text.length;
          }
        }
        String tag = text.substring(tagStartIndex + 1, tagEndIndex).trim();
        tagList.add(tag);
        tagSearchStartIndex = tagEndIndex;
      } while (tagSearchStartIndex < text.length &&
          (tagStartIndex = text.indexOf("#", tagSearchStartIndex)) > 0);
    } else {
      eventContent = text;
    }

    if (eventContent.isNotEmpty) {
      eventContent = eventContent.trim();
    }
    return eventContent;
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memAddedTitle;
    return Skeleton(title: label, body: buildPage(context));
  }
}
