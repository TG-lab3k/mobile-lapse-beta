import 'package:flutter/material.dart';
import 'package:lapse/infra/asset/assets.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lapse/theme/colors.dart';

class CreatorPageRoute {
  static void openCreatorPage(
    BuildContext buildContext,
  ) {
    showModalBottomSheet(
        context: buildContext,
        isScrollControlled: true,
        builder: ((BuildContext context) {
          return SingleChildScrollView(
            child: CreatorPage(),
          );
        }));
  }
}

class CreatorPage extends StatelessWidget {
  final TextEditingController _taskCreatorEditingController =
      TextEditingController();
  FocusNode __taskCreatorFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = TextI18ns.from(context);
    const textFieldStyle = TextStyle(fontSize: 16, color: colorPrimary7);
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          //Input View
          Container(
            child: TextField(
              minLines: 10,
              maxLines: 10,
              style: textFieldStyle,
              cursorColor: colorPrimary8,
              controller: _taskCreatorEditingController,
              focusNode: __taskCreatorFocusNode,
              decoration: _buildInputDecoration(localizations.eventContentHint),
            ),
          ),
          Row(
            children: [
              InkWell(
                child: Container(
                    padding: EdgeInsets.all(18),
                    child: ClipOval(
                      child: Assets.image("ic_appmenu_drawer.png"),
                    )),
                onTap: () async {
                  //TODO open datetime panel
                },
              ),
              InkWell(
                child: Text('#'),
                onTap: () async {
                  //TODO
                },
              ),
              InkWell(
                child: Text('添加'),
                onTap: () async {
                  //TODO
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 10, color: colorPrimary2),
        fillColor: Colors.transparent,
        filled: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: InputBorder.none);
  }
}
