import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:lapse/business/memory/added/learning_curve.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';

final DateFormat _format = DateFormat('yyyy-MM-dd HH:mm');

class AmendTimelineItemWidget extends StatefulWidget {
  AmendTimelineItemWidget({
    required this.index,
    required this.paddingHorizontal,
    required this.startAt,
    this.selectedAt,
  });

  final int index;
  final double paddingHorizontal;
  final DateTime startAt;
  DateTime? selectedAt;

  @override
  State createState() {
    return _AmendTimelineItemState(
        index: index,
        paddingHorizontal: paddingHorizontal,
        startAt: startAt,
        selectedAt: selectedAt);
  }
}

class _AmendTimelineItemState extends State<AmendTimelineItemWidget> {
  _AmendTimelineItemState({
    required this.index,
    required this.paddingHorizontal,
    required this.startAt,
    this.selectedAt,
  });

  final int index;
  final double paddingHorizontal;
  final DateTime startAt;
  DateTime? selectedAt;

  bool? _showTitle = true;

  DateTimePickerLocale? _locale = DateTimePickerLocale.zh_cn;

  String? _dateTimePickerFormat;

  void _showDateTimePicker(BuildContext context) {
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
        showTitle: _showTitle!,
      ),
      pickerMode: DateTimePickerMode.datetime,
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          selectedAt = dateTime;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15.0));
    return Container(
        decoration: BoxDecoration(color: colorPrimary6),
        padding:
            EdgeInsets.fromLTRB(paddingHorizontal, 0, paddingHorizontal, 0),
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
                        child: Text("${index + 1}",
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
                            child: Text(_format.format(selectedAt!),
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

class AmendTimelineWidget extends StatelessWidget {
  AmendTimelineWidget({this.paddingHorizontal});

  double? paddingHorizontal = 10;

  @override
  Widget build(BuildContext context) {
    var nowAt = DateTime.now();
    var timelines = LearningCurve.memoryCurve(nowAt);
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var selectedAt = timelines[index];
        return AmendTimelineItemWidget(
          index: index,
          paddingHorizontal: paddingHorizontal!,
          startAt: nowAt,
          selectedAt: selectedAt,
        );
      }, childCount: timelines.length),
    );
  }
}
