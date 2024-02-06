import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:lapse/business/event/common/util/common_formats.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimeSettingArgs {
  List<String>? defaultDatetimeList;

  TimeSettingArgs(this.defaultDatetimeList);
}

class TimeSettingPageRoute {
  static void openTimeSettingPage(BuildContext context, TimeSettingArgs? args) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: ((BuildContext context) {
          return SingleChildScrollView(
            child: _TimeSettingPage(args),
          );
        }));
  }
}

class _TimeSettingPage extends StatefulWidget {
  final TimeSettingArgs? args;

  _TimeSettingPage(this.args);

  @override
  _TimeSettingPageState createState() => _TimeSettingPageState();
}

class _TimeSettingPageState extends State<_TimeSettingPage> {
  DateTime? _focusedDay;
  DateTime? _firstDay;
  DateTime? _lastDay;
  DateTime? _reminderTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch +
          Duration(minutes: 10).inMilliseconds);
  String? _dateTimePickerFormat;
  DateTimePickerLocale _locale = DateTimePickerLocale.zh_cn;

  @override
  void initState() {
    super.initState();
    var nowAt = DateTime.now();
    _focusedDay = nowAt;
    _firstDay = nowAt;
    _lastDay = DateTime(nowAt.year + 3, nowAt.month, nowAt.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildDateWidget(),
          _buildTimeWidget(),
          _buildRepeatWidget(),
        ],
      ),
    );
  }

  Widget _buildDateWidget() {
    return TableCalendar(
        locale: 'zh_CN',
        focusedDay: _focusedDay!,
        firstDay: _firstDay!,
        lastDay: _lastDay!,
        selectedDayPredicate: (day) {
          return isSameDay(_focusedDay!, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = selectedDay;
          });
        });
  }

  Widget _buildTimeWidget() {
    return Container(
      child: Row(
        children: <Widget>[
          Text("时间:"),
          Container(
              margin: const EdgeInsets.only(left: 10),
              child: Clickable(
                host: Text(CommonFormats.dHHmmFormat.format(_reminderTime!)),
                listener: (Widget hostWidget) {
                  _showDateTimePicker(context, DateTime.now(), _reminderTime!);
                },
              ))
        ],
      ),
    );
  }

  Widget _buildRepeatWidget() {
    return Container(
      child: Text("Repeat"),
    );
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
      locale: _locale,
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
}
