import 'package:flutter/material.dart';
import 'package:lapse/business/memory/common/util/common_formats.dart';
import 'package:lapse/business/memory/home/schedule_service.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/theme/colors.dart';
import 'package:simple_tags/simple_tags.dart';

class ScheduleItemWidget extends StatelessWidget {
  ScheduleEventBo scheduleEventBo;

  ScheduleItemWidget(this.scheduleEventBo);

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
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //header
                Container(
                    child: Text(
                  "${scheduleEventBo.dayLabel}  ${CommonFormats.dHHmmFormat.format(scheduleEventBo.actionAt!)}  ${scheduleEventBo.week}",
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
                      maxLines: 1,
                      style: TextStyle(fontSize: 16, color: colorPrimary04),
                    ),
                  ),

                //tag
                if (scheduleEventBo.tagList?.isNotEmpty == true)
                  Container(child: buildTags(scheduleEventBo.tagList!)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              height: 50,
              width: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: IconButton(
                icon: Assets.image("ic_menu_ellipsis_horizontal.png"),
                onPressed: () {
                  //TODO
                  print("点击Item菜单");
                },
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
}