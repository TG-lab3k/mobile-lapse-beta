import 'package:flutter/material.dart';
import 'package:lapse/business/memory/home/home_service.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/theme/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const double heightItem = 15;

class HomeTimelineItemWidget extends StatefulWidget {
  MemoryContentBo memoryContentBo;

  HomeTimelineItemWidget(this.memoryContentBo);

  @override
  State createState() => _HomeTimelineItemState();
}

class _HomeTimelineItemState extends State<HomeTimelineItemWidget> {
  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15.0));

    var memoryTitle = widget.memoryContentBo.title;
    var title = memoryTitle != null ? memoryTitle! : "";
    var memoryContent = widget.memoryContentBo.content;
    var content = memoryContent != null ? memoryContent! : "";
    return Container(
      decoration: const BoxDecoration(
          color: colorPrimary6,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(title),
          ),
          Container(alignment: Alignment.centerLeft, child: Text(content)),
          Stack(
            children: [
              Container(
                height: heightItem,
                alignment: Alignment.center,
                child: const Divider(height: 2.0, color: colorPrimary5),
              ),
              Row(children: [
                Container(
                    height: heightItem,
                    width: heightItem,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: colorPrimary1, borderRadius: radius),
                    child: const Text("1",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ))),
                Container(
                    height: heightItem,
                    width: heightItem,
                    margin: const EdgeInsets.only(left: 20),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: colorPrimary3, borderRadius: radius),
                    child: const Text("2",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        )))
              ])
            ],
          )
        ],
      ),
    );
  }
}

class HomeTimelineWidget extends StatefulWidget {
  HomeState? homeState;

  HomeTimelineWidget({this.homeState});

  @override
  State createState() => _HomeTimelineState();
}

class _HomeTimelineState extends State<HomeTimelineWidget> {
  @override
  Widget build(BuildContext context) {
    RefreshController refreshController =
        RefreshController(initialRefresh: false);
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      header: WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: _buildTimelineContent(),
      physics: BouncingScrollPhysics(),
    );
  }

  Widget _buildTimelineContent() {
    List<MemoryContentBo>? memoryContents = widget.homeState?.memoryContents;
    var contents = memoryContents != null ? memoryContents : [];

    return ListView.builder(
        itemCount: contents.length,
        itemBuilder: (BuildContext context, int index) {
          return HomeTimelineItemWidget(contents[index]);
        });
  }
}
