import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:table_calendar/table_calendar.dart';

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
          return Builder(builder: (BuildContext context) {
            return SingleChildScrollView(
              child: _TimeSettingPage(args),
            );
          });
        }));
  }
}

enum _RepeatType {
  None('无', 0),
  Ebbinghaus('艾宾浩斯遗忘曲线', 1);

  const _RepeatType(this.label, this.value);

  final String label;
  final int value;
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
  TimeOfDay? _selectedTime;

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
    ThemeData appThemeData = Theme.of(context);
    return Container(
        child: Row(
      children: <Widget>[
        Text("时间: "),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Theme(
            data: appThemeData.copyWith(
                primaryColor: colorPrimary03,
                colorScheme: appThemeData.colorScheme
                    .copyWith(
                      primary: colorPrimary03,
                      secondary: colorPrimary03,
                    )
                    .copyWith(secondary: colorPrimary03)),
            child: Builder(
              builder: (context) {
                return Clickable(
                  host: Text(_selectedTime?.format(context) ?? "请选择"),
                  listener: (Widget hostWidget) {
                    _selectTime(context, TimeOfDay.now());
                  },
                );
              },
            ),
          ),
        )
      ],
    ));
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initTime) async {
    _selectedTime = initTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initTime,
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );

    print("#_selectTime# picked: ${picked?.format(context)}");
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildRepeatWidget() {
    return Container(
      child: Row(
        children: [
          Text("重复类型: "),
          DropdownMenu<_RepeatType>(
              initialSelection: _RepeatType.None,
              requestFocusOnTap: false,
              dropdownMenuEntries: _RepeatType.values
                  .map<DropdownMenuEntry<_RepeatType>>((_RepeatType tye) {
                return DropdownMenuEntry<_RepeatType>(
                    value: tye, label: tye.label);
              }).toList(),
              onSelected: (item) {
                print("#selectRepeat# item: ${item?.label}");
              })
        ],
      ),
    );
  }
}
