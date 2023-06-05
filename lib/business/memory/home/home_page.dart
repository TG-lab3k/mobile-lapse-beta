import 'package:flutter/material.dart';
import 'package:lapse/business/memory/added/added_page.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/toasts.dart';

import 'home_timeline_item_widget.dart';

class MemoryHomePage extends StatefulWidget {
  const MemoryHomePage({super.key, this.title});

  final String? title;

  @override
  State<StatefulWidget> createState() => _MemoryHomePageState();
}

const double heightItem = 15;

class _MemoryHomePageState extends State<MemoryHomePage> {
  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(color: colorPrimary5),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
        child: AddedPage(), //HomeTimelineItemWidget(),
      ),
    );
  }
}
