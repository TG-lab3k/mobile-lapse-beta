import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.title, this.body, this.actions});

  final String? title;
  final Widget? body;
  final List<Widget>? actions;

  @override
  State<StatefulWidget> createState() {
    return _SkeletonState();
  }
}

class _SkeletonState extends State<Skeleton> {
  @override
  Widget build(BuildContext context) {
    String title = "";
    if (widget.title != null) {
      title = widget.title!;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        actions: widget.actions,
      ),
      body: widget.body,
    );
  }
}
