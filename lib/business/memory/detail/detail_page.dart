import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/memory/common/util/common_formats.dart';
import 'package:lapse/business/memory/detail/detail_service.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/skeleton.dart';

const double paddingStart = 16;
const double paddingTop = 15;

const String _logTag = "#DetailPage#";

class DetailPage extends StatefulWidget {
  String? contentId;

  DetailPage(this.contentId);

  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DetailService detailService = DetailService();

  int contentId = 0;
  EventBo? _memoryContentBo;

  void _updateScheduleState(BuildContext context, ScheduleBo scheduleBo) async {
    await detailService.updateScheduleStatus(scheduleBo);
    context.read<DetailService>().acquireMemoryContent(contentId);
  }

  Future<bool?> _deleteContentConfirm(BuildContext context) async {
    var localizations = TextI18ns.from(context);
    return showDialog(
        context: context,
        builder: (builderContext) {
          return AlertDialog(
            content: Text(localizations.memContentDeleteConfirm),
            actions: <Widget>[
              TextButton(
                child: Text(localizations.commonCancel,
                    style: TextStyle(fontSize: 16, color: colorPrimary7)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(localizations.commonDelete,
                    style: TextStyle(fontSize: 16, color: colorPrimary7)),
                onPressed: () async {
                  _deleteContent(context);
                },
              ),
            ],
          );
        });
  }

  void _deleteContent(BuildContext context) async {
    Navigator.of(context).pop(true);
    if (_memoryContentBo != null) {
      await detailService.deleteContent(_memoryContentBo!);
      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memDetailTitle;
    if (widget.contentId == null) {
      return buildEmpty(label);
    }

    var id = int.tryParse(widget.contentId!);
    if (id == null) {
      return buildEmpty(label);
    } else {
      contentId = id!;
      return BlocProvider(
          create: (_) => detailService..acquireMemoryContent(contentId),
          child: BlocBuilder<DetailService, EventBo>(
              builder: (blocContext, memoryContentBo) {
            _memoryContentBo = memoryContentBo;
            return Skeleton(
              title: memoryContentBo.title,
              body: buildPage(blocContext, memoryContentBo),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () async {
                    _deleteContentConfirm(context);
                  },
                )
              ],
            );
          }));
    }
  }

  Widget buildEmpty(String title) {
    return Skeleton(title: title, body: Container());
  }

  Widget buildPage(BuildContext context, EventBo memoryContentBo) {
    print("$_logTag @buildPage _______ contentBo: ${memoryContentBo.id}");
    const radius = Radius.circular(8.0);
    var topWidget = SliverToBoxAdapter(
        child: Container(
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 00),
            child: Container(
                padding: const EdgeInsets.fromLTRB(
                    paddingStart, paddingTop, paddingStart, 40),
                decoration: const BoxDecoration(
                    color: colorPrimary6,
                    borderRadius:
                        BorderRadius.only(topLeft: radius, topRight: radius)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: const BoxDecoration(
                      color: colorPrimary5,
                      borderRadius: BorderRadius.all(Radius.circular(3))),
                  constraints: BoxConstraints(
                    minHeight: 160,
                  ),
                  child: Text(
                    memoryContentBo.content != null
                        ? memoryContentBo.content!
                        : "",
                    style: TextStyle(fontSize: 16, color: colorPrimary7),
                  ),
                ))));

    var bodyWidget = Container(
        decoration: const BoxDecoration(color: colorPrimary6),
        child: CustomScrollView(
          slivers: [
            topWidget,
            _DetailTimelineWidget(
              memoryContentBo.schedules,
              paddingStart * 2,
              (scheduleBo) => _updateScheduleState(context, scheduleBo),
            ),
          ],
        ));
    return bodyWidget;
  }
}

class _DetailTimelineWidget extends StatefulWidget {
  List<ScheduleBo>? scheduleBoList;
  final double paddingHorizontal;
  ValueChanged<ScheduleBo>? onScheduleStatusChanged;

  _DetailTimelineWidget(
    this.scheduleBoList,
    this.paddingHorizontal,
    this.onScheduleStatusChanged,
  );

  @override
  State<StatefulWidget> createState() => _DetailTimelineState();
}

class _DetailTimelineState extends State<_DetailTimelineWidget> {
  @override
  Widget build(BuildContext context) {
    var scheduleBoList = widget.scheduleBoList;
    var count = scheduleBoList != null ? (scheduleBoList?.length)! : 0;
    if (count == 0) {
      return SliverToBoxAdapter(child: Container());
    } else {
      var scheduleBos = scheduleBoList!;
      return SliverList(
          delegate: SliverChildBuilderDelegate((delegateContext, index) {
        if (index < count) {
          return _DetailScheduleWidget(scheduleBos[index], index,
              widget.paddingHorizontal, widget.onScheduleStatusChanged);
        } else {
          return Container(
              decoration: BoxDecoration(color: colorPrimary6),
              padding: EdgeInsets.fromLTRB(
                  widget.paddingHorizontal!, 0, widget.paddingHorizontal!, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: 15,
                      height: 80,
                      alignment: Alignment.center,
                      child: VerticalDivider(color: colorPrimary2, width: 1.0)),
                ],
              ));
        }
      }, childCount: count + 1));
    }
  }
}

class _DetailScheduleWidget extends StatefulWidget {
  final ScheduleBo scheduleBo;
  final int selectedIndex;
  final double paddingHorizontal;
  ValueChanged<ScheduleBo>? onScheduleStatusChanged;

  _DetailScheduleWidget(this.scheduleBo, this.selectedIndex,
      this.paddingHorizontal, this.onScheduleStatusChanged);

  @override
  State<StatefulWidget> createState() => _DetailScheduleState();
}

class _DetailScheduleState extends State<_DetailScheduleWidget> {
  DateTime nowAt = DateTime.now();
  var _scheduleFinished = false;

  @override
  void didUpdateWidget(covariant _DetailScheduleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    nowAt = DateTime.now();
    print("$_logTag _____ @didUpdateWidget _____ ");
  }

  Color getPrimaryColor() {
    var status = widget.scheduleBo.status;
    print(
        "$_logTag @getPrimaryColor index: ${widget.selectedIndex}, status: $status");
    if (ScheduleStatus.done.index == status) {
      //done
      return colorPrimary1;
    } else if (ScheduleStatus.todo.index == status &&
        widget.scheduleBo.actionAt != null) {
      var actionAtInMills = widget.scheduleBo.actionAt!;
      var nowAtInMills = nowAt.millisecondsSinceEpoch;
      if (actionAtInMills < nowAtInMills) {
        return colorPrimary3;
      }
    }
    return colorPrimary2;
  }

  String formatTimeHint(BuildContext context) {
    var timeHint = "";
    const separator = "  ";
    var status = widget.scheduleBo.status;
    var localizations = TextI18ns.from(context);
    if (ScheduleStatus.done.index == status) {
      print("$_logTag @formatTimeHint doneAt: ${widget.scheduleBo.doneAt}");
      if (widget.scheduleBo.doneAt != null) {
        var doneAt =
            DateTime.fromMillisecondsSinceEpoch(widget.scheduleBo.doneAt!);
        var doneHint =
            CommonFormats.formatRemainingTime(doneAt, nowAt, context);
        print("$_logTag @formatTimeHint doneHint: $doneHint");
        if (doneHint.isNotEmpty) {
          var week = CommonFormats.formatWeek(context, doneAt);
          if (week.length > 0) {
            week += separator;
          }
          var tail;
          if (doneHint == TIME_FORMAT_ZERO) {
            tail = localizations.commonAgoNow;
          } else {
            tail = doneHint + localizations.commonAgo;
          }
          timeHint = week + tail;
        }
      }
    } else if (ScheduleStatus.todo.index == status) {
      var actionAtInMills = widget.scheduleBo.actionAt;
      if (actionAtInMills != null &&
          nowAt.millisecondsSinceEpoch < actionAtInMills) {
        var actionAt = DateTime.fromMillisecondsSinceEpoch(actionAtInMills!);
        var expectingHint =
            CommonFormats.formatRemainingTime(nowAt, actionAt, context);
        if (expectingHint.isNotEmpty) {
          var week = CommonFormats.formatWeek(context, actionAt);
          if (week.length > 0) {
            week += separator;
          }
          var tail;
          if (expectingHint == TIME_FORMAT_ZERO) {
            tail = localizations.commonLaterNow;
          } else {
            tail = expectingHint + localizations.commonLater;
          }
          timeHint = week + tail;
        }
      }
    }
    return timeHint;
  }

  void finishSchedule(bool? checked) async {
    setState(() {
      _scheduleFinished = !_scheduleFinished;
    });
    if (checked == true) {
      Future.delayed(Duration(milliseconds: 1000));
      var scheduleBo = widget.scheduleBo;
      scheduleBo.status = ScheduleStatus.done.index;
      widget.onScheduleStatusChanged?.call(scheduleBo);
    }
  }

  bool _isOverdue() {
    var scheduleBo = widget.scheduleBo;
    return ScheduleStatus.todo.index == scheduleBo.status &&
        scheduleBo.actionAt! < nowAt.millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = getPrimaryColor();
    var timeHint = formatTimeHint(context);
    const radius = BorderRadius.all(Radius.circular(15.0));
    double itemHeight = 10 + 10 + 15 + (widget.selectedIndex * 6);
    var actionAt =
        DateTime.fromMillisecondsSinceEpoch(widget.scheduleBo.actionAt!);

    Widget minorWidget;
    var isOverdue = _isOverdue();
    if (isOverdue) {
      minorWidget = Container(
          height: 15,
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.only(left: 100),
          alignment: Alignment.center,
          child: Center(
            child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _scheduleFinished,
                checkColor: primaryColor,
                activeColor: primaryColor,
                onChanged: (checked) {
                  finishSchedule(checked);
                },
                side: MaterialStateBorderSide.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return BorderSide(width: 2, color: primaryColor);
                    }
                    return BorderSide(width: 2, color: primaryColor);
                  },
                )),
          ));
    } else {
      minorWidget = Container(
          height: 15,
          padding: const EdgeInsets.only(left: 4, right: 4),
          margin: const EdgeInsets.only(left: 10),
          alignment: Alignment.center,
          child: Text(timeHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: colorPrimary2,
              )));
    }
    return Container(
        decoration: BoxDecoration(color: colorPrimary6),
        padding: EdgeInsets.fromLTRB(
            widget.paddingHorizontal, 0, widget.paddingHorizontal, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                children: [
                  Container(
                      width: 15,
                      height: itemHeight,
                      alignment: Alignment.center,
                      child: VerticalDivider(color: colorPrimary2, width: 1.0)),
                  Positioned(
                    bottom: 10,
                    child: Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: primaryColor, borderRadius: radius),
                        child: Text((widget.selectedIndex + 1).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorPrimary6,
                            ))),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  Container(
                      height: itemHeight,
                      width: 300,
                      alignment: Alignment.center,
                      child: VerticalDivider(color: Colors.transparent)),
                  Positioned(
                    bottom: 10,
                    child: Row(
                      children: [
                        Container(
                            height: 15,
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            decoration: BoxDecoration(
                                color: primaryColor, borderRadius: radius),
                            alignment: Alignment.center,
                            child:
                                Text(CommonFormats.dHHmmFormat.format(actionAt),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorPrimary6,
                                    ))),
                        minorWidget
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
