//https://github.com/search?q=flutter+DatePicker

import 'package:flutter/material.dart';
import 'package:lapse/business/memory/added/amend_timeline_widget.dart';

class MemoTimelineItemWidget extends StatelessWidget {
  static final itemKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AmendTimelineWidget();
  }
}
