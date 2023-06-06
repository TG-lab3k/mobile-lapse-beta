import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:lapse/widget/toasts.dart';

const String MIN_DATETIME = '2010-05-15 09:23:10';
const String MAX_DATETIME = '2019-06-03 21:11:00';
const String INIT_DATETIME = '2023-05-20 09:30:00';

//https://github.com/search?q=flutter+DatePicker

class AmendTimelineItemWidget extends StatelessWidget {
  AmendTimelineItemWidget(
      {required this.index, required this.paddingHorizontal});

  final int index;
  final double paddingHorizontal;

  bool? _showTitle = true;

  DateTimePickerLocale? _locale = DateTimePickerLocale.zh_cn;

  late DateTime _dateTime = DateTime.parse(INIT_DATETIME);

  void _showDateTimePicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime.parse(MIN_DATETIME),
      maxDateTime: DateTime.now(),
      initialDateTime: _dateTime,
      dateFormat: "M月-d日 H时:m分",
      locale: _locale!,
      pickerTheme: DateTimePickerTheme(
        showTitle: _showTitle!,
      ),
      pickerMode: DateTimePickerMode.datetime,
      // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        //Toasts.toast(_dateTime.toString());
      },
      onConfirm: (dateTime, List<int> index) {
        Toasts.toast(_dateTime.toString());
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
                            child: const Text("2023-05-28 00:18",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ))),
                        listener: (Widget hostWidget) {
                          Toasts.toast("第$index的Item被点击");
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
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return AmendTimelineItemWidget(
          index: index,
          paddingHorizontal: paddingHorizontal!,
        );
      }, childCount: 8),
    );
  }
}
