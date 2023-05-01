import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';

const double heightItem = 15;

class HomeTimelineItemWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15.0));
    return SizedBox(
        height: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 70,
            decoration: const BoxDecoration(color: colorPrimary6),
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text("第一组"),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("cap, baby, yes")),
                Stack(
                  children: [
                    Container(
                      height: heightItem,
                      alignment: Alignment.center,
                      child:
                      const Divider(height: 2.0, color: colorPrimary5),
                    ),
                    Row(children: [
                      Container(
                          height: heightItem,
                          width: 15,
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
                          height: 15,
                          width: 15,
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
          ),
        ));
  }
}
