import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:lapse/business/event/added/memory/learning_curve.dart';
import 'package:lapse/business/event/common/util/common_formats.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';

class _ActionTime {
  DateTime actionTime;
  int index;

  _ActionTime(this.actionTime, this.index);
}

class _AmendTimelineItemWidget extends StatefulWidget {
  _AmendTimelineItemWidget(
      {required this.selectedIndex,
      required this.timelineList,
      required this.startAt,
      required this.paddingHorizontal,
      required this.onActionTimeChanged});

  final int selectedIndex;
  final double paddingHorizontal;
  final DateTime startAt;
  DateTime? _selectedAt;
  final List<DateTime> timelineList;
  final ValueChanged<_ActionTime> onActionTimeChanged;

  @override
  State createState() {
    return _AmendTimelineItemState();
  }

  void _updateSelectedAt(DateTime newSelectedAt) {
    this._selectedAt = newSelectedAt;
    this.timelineList[selectedIndex] = newSelectedAt;
    if (selectedIndex == 0) {
      onActionTimeChanged(_ActionTime(newSelectedAt, selectedIndex));
    }
  }
}

class _AmendTimelineItemState extends State<_AmendTimelineItemWidget> {
  DateTimePickerLocale _locale = DateTimePickerLocale.zh_cn;

  String? _dateTimePickerFormat;

  void _showDateTimePicker(BuildContext context) {
    if (_dateTimePickerFormat == null) {
      _dateTimePickerFormat = TextI18ns.from(context).memAddedDateTimeFormat;
    }
    DatePicker.showDatePicker(
      context,
      minDateTime: widget.startAt,
      initialDateTime: widget._selectedAt!,
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
          widget._updateSelectedAt(dateTime);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget._selectedAt = widget.timelineList[widget.selectedIndex];
    const radius = BorderRadius.all(Radius.circular(15.0));
    var localizations = TextI18ns.from(context);
    double itemHeight = 10 + 10 + 15 + (widget.selectedIndex * 6);
    var endAt =
        widget._selectedAt != null ? widget._selectedAt! : widget.startAt;
    var remaining =
        CommonFormats.formatRemainingTime(widget.startAt, endAt, context);
    if (remaining.isNotEmpty) {
      var week = CommonFormats.formatWeek(localizations, endAt);
      if (week.length > 0) {
        week += "  ";
      }
      remaining = week + remaining + localizations.commonLater;
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
                        decoration: const BoxDecoration(
                            color: colorPrimary2, borderRadius: radius),
                        child: Text((widget.selectedIndex + 1).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
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
                        Clickable(
                            host: Container(
                                height: 15,
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
                                decoration: const BoxDecoration(
                                    color: colorPrimary2, borderRadius: radius),
                                alignment: Alignment.center,
                                child: Text(CommonFormats.dHHmmFormat.format(widget._selectedAt!),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorPrimary6,
                                    ))),
                            listener: (Widget hostWidget) {
                              _showDateTimePicker(context);
                            }),
                        Container(
                            height: 15,
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            margin: const EdgeInsets.only(left: 10),
                            alignment: Alignment.center,
                            child: Text(remaining,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorPrimary2,
                                )))
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

class AmendTimelineWidget extends StatefulWidget {
  AmendTimelineWidget({this.paddingHorizontal, required this.timelineList});

  double? paddingHorizontal = 10;
  List<DateTime> timelineList = [];

  @override
  State<AmendTimelineWidget> createState() => _AmendTimelineWidgetState();
}

class _AmendTimelineWidgetState extends State<AmendTimelineWidget> {
  late DateTime _startAt;

  @override
  void initState() {
    super.initState();
    _startAt = DateTime.now();
    var timelineList = LearningCurve.memoryCurve(_startAt);
    widget.timelineList.clear();
    timelineList.forEach((time) {
      widget.timelineList.add(time);
    });
  }

  void changeActionTime(_ActionTime _actionTime) async {
    DateTime changedTime = _actionTime.actionTime;
    int changedIndex = _actionTime.index;
    var influencedList =
        LearningCurve.memoryCurveNext(changedTime, changedIndex);
    var timelineList = widget.timelineList;
    var originCount = timelineList.length;
    var influencedCount = influencedList.length;
    var nextIndex = changedIndex + 1;
    for (int i = 0; i < influencedCount; i++) {
      var originIndex = i + nextIndex;
      if (originIndex < originCount) {
        timelineList[originIndex] = influencedList[i];
      }
    }
    setState(() {
      this._startAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    var timelineLength = widget.timelineList.length;
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index < timelineLength) {
          return _AmendTimelineItemWidget(
            selectedIndex: index,
            timelineList: widget.timelineList,
            startAt: _startAt,
            paddingHorizontal: widget.paddingHorizontal!,
            onActionTimeChanged: changeActionTime,
          );
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
      }, childCount: timelineLength + 1),
    );
  }
}
