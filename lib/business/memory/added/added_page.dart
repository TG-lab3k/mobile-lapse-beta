import 'package:flutter/material.dart';
import 'package:lapse/business/memory/added/amend_timeline_widget.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:lapse/widget/skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lapse/widget/toasts.dart';
import 'package:lapse/theme/colors.dart';

class AddedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddedPageState();
  }
}

const double paddingStart = 16;
const double paddingTop = 15;

class _AddedPageState extends State<AddedPage> {
  final itemKey = UniqueKey();
  final TextEditingController _titleEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Toasts.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    String label = TextI18ns.from(context).memAddedTitle;
    return Skeleton(title: label, body: buildPage(context));
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 10, color: colorPrimary2),
        fillColor: Colors.transparent,
        filled: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: InputBorder.none);
  }

  Widget buildPage(BuildContext context) {
    final AppLocalizations localizations = TextI18ns.from(context);
    const radius = Radius.circular(8.0);

    const textFieldStyle = TextStyle(fontSize: 16, color: colorPrimary7);
    var topWidget = SliverToBoxAdapter(
        child: Container(
            decoration: const BoxDecoration(color: colorPrimary5),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 00),
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
                decoration: const BoxDecoration(
                    color: colorPrimary6,
                    borderRadius:
                        BorderRadius.only(topLeft: radius, topRight: radius)),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        paddingStart, paddingTop, paddingStart, 0),
                    child: Column(children: [
                      Container(
                          decoration: const BoxDecoration(
                              color: colorPrimary5,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                          child: TextField(
                            maxLines: 1,
                            style: textFieldStyle,
                            decoration: buildInputDecoration(
                                localizations.memAddedTitleHint),
                            keyboardType: TextInputType.text,
                            controller: _titleEditingController,
                          )),
                      Container (
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        decoration: const BoxDecoration(
                            color: colorPrimary5,
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        child: TextField(
                          minLines: 8,
                          maxLines: 8,
                          style: textFieldStyle,
                          decoration: buildInputDecoration(
                              localizations.memAddedContentHint),
                        ),
                      ),
                    ])))));

    var contentWidget = Stack(
      children: [
        CustomScrollView(
          slivers: [
            topWidget,
            AmendTimelineWidget(paddingHorizontal: paddingStart * 2),
          ],
        ),
        Positioned(
          bottom: 50,
          child: Container(
            child: MaterialButton(
              onPressed: () {
                print(
                    "-----MaterialButton------: ${_titleEditingController.value.text}");
                Toasts.toast(_titleEditingController.value.text);
              },
              child: Text(localizations.memAddedSubmit),
            ),
          ),
        )
      ],
    );

    return contentWidget;
  }
}
