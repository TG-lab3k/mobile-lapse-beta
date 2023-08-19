import 'package:flutter/material.dart';
import 'package:lapse/business/event/common/util/common_formats.dart';
import 'package:lapse/business/event/home/schedule_service.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/clickable.dart';
import 'package:lapse/widget/float_menu.dart';
import 'package:simple_tags/simple_tags.dart';

class ScheduleItemWidget extends StatelessWidget {
  ScheduleEventBo scheduleEventBo;
  GlobalKey _itemMenuKey = GlobalKey();
  FloatMenu? _itemMenu;

  ScheduleService? scheduleService;

  ScheduleItemWidget(this.scheduleEventBo, {this.scheduleService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: colorPrimary6,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scheduleEventBo.expired)
            Container(
              height: 50,
              width: 1.5,
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(0xb2, 0xfa, 0x01, 0x01)),
            ),
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //header
                    Container(
                        child: Text(
                      "${scheduleEventBo.dayLabel}  ${CommonFormats.dHHmmFormat.format(scheduleEventBo.actionAt!)}  ${scheduleEventBo.week}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorPrimary03,
                      ),
                    )),
                    //title
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        "${scheduleEventBo.eventTitle}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorPrimary03,
                        ),
                      ),
                    ),

                    //content
                    if (scheduleEventBo.eventContent?.isNotEmpty == true)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Text(
                          "${scheduleEventBo.eventContent}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16, color: colorPrimary04),
                        ),
                      ),

                    //tag
                    if (scheduleEventBo.tagList?.isNotEmpty == true)
                      Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: buildTags(scheduleEventBo.tagList!)),
                  ],
                ),
              )),
          Expanded(
            flex: 0,
            child: Container(
              alignment: Alignment.topRight,
              height: 40,
              width: 40,
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
              child: IconButton(
                key: _itemMenuKey,
                icon: Assets.image("ic_menu_ellipsis_horizontal.png"),
                onPressed: () => openItemMenu(context, scheduleEventBo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTags(List<String> tagList) {
    return SimpleTags(
      content: tagList,
      wrapSpacing: 4,
      wrapRunSpacing: 4,
      tagContainerPadding: EdgeInsets.all(6),
      tagTextStyle: TextStyle(
          fontSize: 11, color: Color.fromARGB(0xff, 0x1b, 0xdb, 0x96)),
      tagContainerDecoration: BoxDecoration(
        color: Color.fromARGB(0x1a, 0x66, 0xde, 0xb3),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    );
  }

  void openItemMenu(
      BuildContext context, ScheduleEventBo scheduleEventBo) async {
    _itemMenu = FloatMenu.open(
        context,
        _itemMenuKey,
        80,
        offsetX: 60,
        offsetY: 20,
        ListView(padding: EdgeInsets.zero, shrinkWrap: true, children: <Widget>[
          Clickable(
              host: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text("完成",
                    style: TextStyle(fontSize: 14, color: colorPrimary03)),
              ),
              listener: (_) {
                _itemMenu?.close();
                scheduleService?.doneSchedule(
                    scheduleEventBo.eventId!, scheduleEventBo.scheduleId!);
              }),
          Clickable(
              host: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text("删除",
                    style: TextStyle(fontSize: 14, color: colorPrimary03)),
              ),
              listener: (_) {
                _itemMenu?.close();
                scheduleService?.removeSchedule(
                    scheduleEventBo.eventId!, scheduleEventBo.scheduleId!);
              }),
        ]));
  }
}
