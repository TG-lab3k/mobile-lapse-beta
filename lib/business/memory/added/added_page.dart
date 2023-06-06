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

class _AddedPageState extends State<AddedPage> {
  final itemKey = UniqueKey();
  final TextEditingController titleEditingController = TextEditingController();

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

  Widget buildPage(BuildContext context) {
    AppLocalizations localizations = TextI18ns.from(context);
    var topWidget = SliverToBoxAdapter(
        child: Container(
      //decoration: const BoxDecoration(color: colorPrimary2),
      child: Column(
        children: [
          TextField(
            maxLines: 1,
            decoration:
                InputDecoration(hintText: localizations.memAddedTitleHint),
            keyboardType: TextInputType.text,
            controller: titleEditingController,
          ),
          TextField(
            minLines: 5,
            maxLines: 5,
            decoration:
                InputDecoration(hintText: localizations.memAddedContentHint),
          ),
        ],
      ),
    ));

    var footerWidget = SliverToBoxAdapter(
        child: MaterialButton(
      onPressed: () {
        print(
            "-----MaterialButton------: ${titleEditingController.value.text}");
        Toasts.toast(titleEditingController.value.text);
      },
      child: Text(localizations.memAddedSubmit),
    ));

    var contentWidget = CustomScrollView(
      slivers: [topWidget, AmendTimelineWidget(),footerWidget],
    );

    return contentWidget;
  }
}
