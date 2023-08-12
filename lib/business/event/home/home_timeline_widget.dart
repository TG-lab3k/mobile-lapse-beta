import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lapse/business/event/home/home_service.dart';
import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const double heightItem = 15;

const _TAG = "HomeTimelineItemWidget";

class HomeTimelineItemWidget extends StatefulWidget {
  EventBo memoryContentBo;

  HomeTimelineItemWidget(this.memoryContentBo);

  @override
  State createState() => _HomeTimelineItemState();
}

class _HomeTimelineItemState extends State<HomeTimelineItemWidget> {
  @override
  Widget build(BuildContext context) {
    var memoryTitle = widget.memoryContentBo.title;
    var title = memoryTitle != null ? memoryTitle! : "";
    var memoryContent = widget.memoryContentBo.content;
    var content = memoryContent != null ? memoryContent! : "";
    return Container(
      decoration: const BoxDecoration(
          color: colorPrimary6,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(title,
                maxLines: 1,
                style: TextStyle(fontSize: 14, color: colorPrimary8)),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                maxLines: 1,
                style: TextStyle(fontSize: 12, color: colorPrimary8),
              )),
          ProgressWidget(widget.memoryContentBo.schedules),
        ],
      ),
    );
  }
}

class ProgressWidget extends StatefulWidget {
  List<ScheduleBo>? scheduleBoList;

  ProgressWidget(this.scheduleBoList);

  @override
  State<StatefulWidget> createState() {
    return _ProgressState();
  }
}

class _ProgressState extends State<ProgressWidget> {
  @override
  Widget build(BuildContext context) {
    List<ScheduleBo>? scheduleBoList = widget.scheduleBoList;
    var size = scheduleBoList?.length;
    var scheduleCount = size != null ? size : 0;
    print("#_ProgressState#  @build  scheduleCount:$scheduleCount");
    if (scheduleCount == 0) {
      return Container(
        height: heightItem,
        alignment: Alignment.center,
        child: const Divider(height: 2.0, color: colorPrimary5),
      );
    } else {
      var scheduleBos = scheduleBoList!;
      List<Widget> progressItemList = [];
      for (var i = 0; i < scheduleBos.length; i++) {
        progressItemList.add(ProgressItemWidget(scheduleBos[i], i));
      }
      var progressWidget = Row(children: progressItemList);
      return Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Stack(
            children: [
              Container(
                height: heightItem,
                alignment: Alignment.center,
                child: const Divider(height: 2.0, color: colorPrimary5),
              ),
              progressWidget
            ],
          ));
    }
  }
}

class ProgressItemWidget extends StatelessWidget {
  ScheduleBo scheduleBo;
  int index;

  ProgressItemWidget(this.scheduleBo, this.index);

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15.0));
    var nowAt = DateTime.now().millisecondsSinceEpoch;
    var checkAt = scheduleBo.doneAt;
    var actionAt = scheduleBo.actionAt!;
    var actionColor = colorPrimary2;
    if (checkAt != null) {
      actionColor = colorPrimary1;
    } else if (actionAt <= nowAt) {
      actionColor = colorPrimary3;
    }
    double margeLeft = index * 10;
    return Container(
        height: heightItem,
        width: heightItem,
        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(margeLeft, 0, 0, 0),
        decoration: BoxDecoration(color: actionColor, borderRadius: radius),
        child: Text((index + 1).toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            )));
  }
}

class HomeTimelineWidget extends StatefulWidget {
  HomeState? homeState;
  VoidCallback? onRefreshList;
  final RefreshController refreshController;

  HomeTimelineWidget(this.refreshController,
      {this.homeState, this.onRefreshList});

  @override
  State createState() {
    print("#HomeTimelineWidget# ------ @createState");
    return _HomeTimelineState();
  }
}

class _HomeTimelineState extends State<HomeTimelineWidget> {
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
    List<EventBo>? memoryContents = widget.homeState?.memoryContents;
    List<EventBo> contents =
        memoryContents != null ? memoryContents : [];

    return ListView.builder(
        itemCount: contents.length,
        itemBuilder: (BuildContext itemContext, int index) {
          var contentBo = contents[index];
          print(
              "$_TAG @_buildTimelineContent schedules: ${contentBo.schedules?.length}");
          return Clickable(
            host: HomeTimelineItemWidget(contentBo),
            listener: (_) {
              context.go("/lapse/memory/detail/${contentBo.id}");
            },
          );
        });
  }
}
