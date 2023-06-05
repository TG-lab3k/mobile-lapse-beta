import 'package:flutter/material.dart';

typedef OnWidgetClickedListener = void Function(Widget hostWidget);

class Clickable extends StatelessWidget {
  final Widget host;
  OnWidgetClickedListener? listener;

  Clickable({required this.host, this.listener});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          listener?.call(host);
        },
        child: host);
  }
}
