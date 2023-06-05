import 'package:flutter/material.dart';
import 'package:lapse/theme/colors.dart';
import 'package:lapse/widget/skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AddedPage extends StatelessWidget {
  static final itemKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    String label = AppLocalizations.of(context)!.memAddedTitle;
    return Skeleton(title: label, body: Container());
  }

  
}
