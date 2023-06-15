import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:lapse/business/memory/added/learning_curve.dart';
import 'package:lapse/business/memory/common/util/common_formats.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';

final DateFormat _format = DateFormat('yyyy-MM-dd HH:mm');

class _AmendTimelineItemWidget extends StatefulWidget {
  _AmendTimelineItemWidget(
      {required this.index,
      required this.paddingHorizontal,
      required this.startAt,
      required this.selectedAt,
      required this.timelineMap});

  final int index;
  final double paddingHorizontal;
  final DateTime startAt;
  DateTime? selectedAt;
  final Map<int, DateTime> timelineMap;

  @override
  State createState() {
    return _AmendTimelineItemState();
  }

  void _updateSelectedAt(DateTime newSelectedAt) {
    this.selectedAt = newSelectedAt;
    this.timelineMap[index] = newSelectedAt;
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
      initialDateTime: widget.selectedAt,
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
    const radius = BorderRadius.all(Radius.circular(15.0));
    var localizations = TextI18ns.from(context);
    double itemHeight = 10 + 10 + 15 + (widget.index * 6);
    var endAt = widget.selectedAt != null ? widget.selectedAt! : widget.startAt;
    var remaining =
        CommonFormats.formatRemainingTime(widget.startAt, endAt, context);
    if (remaining.isNotEmpty) {
      remaining += localizations.commonLater;
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
                        child: Text((widget.index + 1).toString(),
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
                      width: 200,
                      alignment: Alignment.center,
                      child: VerticalDivider(
                          color: Color.fromARGB(0x00, 0x00, 0x00, 0x00))),
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
                                child: Text(_format.format(widget.selectedAt!),
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
  AmendTimelineWidget({this.paddingHorizontal, required this.timelineMap});

  double? paddingHorizontal = 10;
  final Map<int, DateTime> timelineMap;

  @override
  State<AmendTimelineWidget> createState() => _AmendTimelineWidgetState();
}

class _AmendTimelineWidgetState extends State<AmendTimelineWidget> {
  @override
  Widget build(BuildContext context) {
    var nowAt = DateTime.now();
    var timelines = LearningCurve.memoryCurve(nowAt);
    widget.timelineMap.clear();
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index < timelines.length) {
          var selectedAt = timelines[index];
          widget.timelineMap[index] = selectedAt;
          return _AmendTimelineItemWidget(
            index: index,
            paddingHorizontal: widget.paddingHorizontal!,
            startAt: nowAt,
            selectedAt: selectedAt,
            timelineMap: widget.timelineMap,
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
      }, childCount: timelines.length + 1),
    );
  }
}
