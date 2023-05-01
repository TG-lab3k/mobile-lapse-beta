import 'package:flutter/material.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/timeline/timeline_status.dart';

class WeightPoint {
  String label = "";
  TimelineStatus status = TimelineStatus.todo;
  int weight = 0;
  double? _startX;
}

class _WeightTimelineLiteWidgetState extends State<WeightTimelineLiteWidget> {
  var _timelines = <WeightPoint>[];
  final GlobalKey<_WeightTimelineLiteWidgetState> _weightTimelineLiteKey =
      GlobalKey<_WeightTimelineLiteWidgetState>();
  double? _width;

  set timelines(value) {
    _timelines = value;
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_setContainerWidth);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(WeightTimelineLiteWidget oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_setContainerWidth);
    super.didUpdateWidget(oldWidget);
  }

  _setContainerWidth(_) {
    _width = _weightTimelineLiteKey.currentContext?.size?.width;
  }

  @override
  Widget build(BuildContext context) {
    _measurePoints();
    var timelineViews = _buildTimelines();
    return Stack(
      key: _weightTimelineLiteKey,
      children: [
        Assets.image("line_horizontal.png"),
        Row(children: timelineViews)
      ],
    );
  }

  _buildTimelines() {
    final points = _timelines;
    var size = points?.length ?? 0;
    if (size == 0) {
      return <Widget>[];
    }

    var widgets = <Widget>[];
    const radius = BorderRadius.all(Radius.circular(20.0));
    for (int i = 0; i < size; i++) {
      var point = points[i];
      var pointWidget = Container(
          alignment: Alignment.center,
          decoration:
              const BoxDecoration(color: colorPrimary1, borderRadius: radius),
          child: Text(point.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19.0,
              )));
      widgets[i] = pointWidget;
    }
    return widgets;
  }

  _measurePoints() {
    final points = _timelines;
    var size = points?.length ?? 0;
    if (size == 0) {
      return;
    }

    var width = _width ?? 0;
    if (width == 0) {
      return;
    }

    var totalWeight = 0;
    for (var point in points) {
      totalWeight += point.weight;
    }

    var weightUnit = (width / totalWeight).floor();
    var usedWeight = 0;
    for (int i = 0; i < size; i++) {
      var point = points[i];
      var weight = point.weight;
      point._startX = (usedWeight * weightUnit) as double;
      usedWeight += weight;
    }
  }
}

class WeightTimelineLiteWidget extends StatefulWidget {
  const WeightTimelineLiteWidget({super.key});

  @override
  State createState() {
    return _WeightTimelineLiteWidgetState();
  }
}
