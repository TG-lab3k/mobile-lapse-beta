import 'package:flutter/material.dart';
import 'package:lapse/business/memory/home/schedule_item_widget.dart';
import 'package:lapse/business/memory/home/schedule_service.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SchedulePage extends StatefulWidget {
  ScheduleState? scheduleState;
  final VoidCallback? onRefreshList;
  final RefreshController refreshController;

  SchedulePage(this.scheduleState, this.refreshController, this.onRefreshList);

  @override
  State createState() {
    return SchedulePageState();
  }
}

class SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: colorPrimary5),
      child: SmartRefresher(
        controller: widget.refreshController,
        enablePullUp: false,
        enablePullDown: true,
        header: WaterDropHeader(
          waterDropColor: colorPrimary1,
        ),
        onRefresh: () async {
          widget.onRefreshList?.call();
        },
        child: _buildTimelineContent(context),
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildTimelineContent(BuildContext context) {
    List<ScheduleEventBo>? scheduleEventList =
        widget.scheduleState?.scheduleEventList;
    List<ScheduleEventBo> scheduleList =
        scheduleEventList != null ? scheduleEventList : [];

    return ListView.builder(
        itemCount: scheduleList.length,
        itemBuilder: (BuildContext itemContext, int index) {
          var eventBo = scheduleList[index];
          return Clickable(
            host: ScheduleItemWidget(eventBo),
            listener: (_) {
              //TODO
            },
          );
        });
  }
}
