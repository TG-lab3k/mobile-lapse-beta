//https://github.com/search?q=flutter+DatePicker

import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';

class MemoTimelineItemWidget extends StatelessWidget {
  static final itemKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(15.0));
    return Container(
        key: itemKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              //decoration: const BoxDecoration(color: colorPrimary2),
              child: Stack(
                children: [
                  Container(
                      width: 15,
                      height: 60,
                      alignment: Alignment.center,
                      child: VerticalDivider(color: colorPrimary2, width: 1.0)),
                  Positioned(
                    bottom: 1,
                    child: Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: colorPrimary3, borderRadius: radius),
                        child: const Text("2",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ))),
                  ),
                ],
              ),
            ),
            Container(
              //decoration: const BoxDecoration(color: colorPrimary2),
              margin: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  Container(
                      height: 60,
                      width: 200,
                      alignment: Alignment.center,
                      child: VerticalDivider(
                          color: Color.fromARGB(0x00, 0x00, 0x00, 0x00))),
                  Positioned(
                    bottom: 1,
                    child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        decoration: const BoxDecoration(
                            color: colorPrimary3, borderRadius: radius),
                        alignment: Alignment.center,
                        child: const Text("2023-05-28 00:18",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ))),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class MemoTimelineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("");
  }
}
