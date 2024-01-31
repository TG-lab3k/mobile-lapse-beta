import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSettingArgs {
  List<String>? defaultDatetimeList;
}

class TimeSettingPageRoute {
  static void openTimeSettingPage(BuildContext context, TimeSettingArgs args) {
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

class _TimeSettingPage extends StatelessWidget {
  TimeSettingArgs? args;

  _TimeSettingPage(this.args);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildDatetimeWidget(),
        ],
      ),
    );
  }

  Widget _buildDatetimeWidget() {
    DateTime _firstDay = DateTime.now();
    DateTime _focusedDay = DateTime.now();
    DateTime _lastDay =
        DateTime(_focusedDay.year + 3, _focusedDay.month, _focusedDay.day);
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: _firstDay,
      lastDay: _lastDay,
    );
  }
}
