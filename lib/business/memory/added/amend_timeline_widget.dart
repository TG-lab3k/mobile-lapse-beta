import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:lapse/business/memory/added/learning_curve.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';

final DateFormat _format = DateFormat('yyyy-MM-dd HH:mm');

class AmendTimelineItemWidget extends StatefulWidget {
  AmendTimelineItemWidget(
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

  _updateSelectedAt(DateTime newSelectedAt) {
    this.selectedAt = newSelectedAt;
    this.timelineMap[index] = newSelectedAt;
  }
}

class _AmendTimelineItemState extends State<AmendTimelineItemWidget> {
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
    return Container(
        decoration: BoxDecoration(color: colorPrimary6),
        padding: EdgeInsets.fromLTRB(
            widget.paddingHorizontal, 0, widget.paddingHorizontal, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              //decoration: const BoxDecoration(color: colorPrimary2),
              child: Stack(
                children: [
                  Container(
                      width: 15,
                      height: 60,
                      alignment: Alignment.center,
                      child: VerticalDivider(color: colorPrimary2, width: 1.0)),
                  Positioned(
                    bottom: 1,
                    child: Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: colorPrimary3, borderRadius: radius),
                        child: Text("${widget.index + 1}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ))),
                  ),
                ],
              ),
            ),
            Container(
              //decoration: const BoxDecoration(color: colorPrimary2),
              margin: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  Container(
                      height: 60,
                      width: 200,
                      alignment: Alignment.center,
                      child: VerticalDivider(
                          color: Color.fromARGB(0x00, 0x00, 0x00, 0x00))),
                  Positioned(
                    bottom: 1,
                    child: Clickable(
                        host: Container(
                            height: 15,
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            decoration: const BoxDecoration(
                                color: colorPrimary3, borderRadius: radius),
                            alignment: Alignment.center,
                            child: Text(_format.format(widget.selectedAt!),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ))),
                        listener: (Widget hostWidget) {
                          _showDateTimePicker(context);
                        }),
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
        var selectedAt = timelines[index];
        widget.timelineMap[index] = selectedAt;
        return AmendTimelineItemWidget(
          index: index,
          paddingHorizontal: widget.paddingHorizontal!,
          startAt: nowAt,
          selectedAt: selectedAt,
          timelineMap: widget.timelineMap,
        );
      }, childCount: timelines.length),
    );
  }
}
