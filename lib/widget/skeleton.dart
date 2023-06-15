import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.title, this.body});

  final String? title;
  final Widget? body;

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
        title: Center(child: Text(title)),
        elevation: 0,
      ),
      body: widget.body,
    );
  }
}
