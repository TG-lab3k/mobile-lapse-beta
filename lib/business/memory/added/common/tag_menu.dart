import 'package:flutter/material.dart';

//https://juejin.cn/post/6844904115764658189
class TagMenu {
  static TagMenu register(BuildContext context, FocusNode focusNode,
      TextEditingController contentEditingController) {
    return TagMenu._(context, focusNode, contentEditingController);
  }

  BuildContext? _context;
  FocusNode? _focusNode;
  TextEditingController? _contentEditingController;
  OverlayEntry? overlayEntry;

  TagMenu._(BuildContext context, FocusNode focusNode,
      TextEditingController contentEditingController) {
    this._context = context;
    this._focusNode = focusNode;
    this._contentEditingController = contentEditingController;
    contentEditingController.addListener(_listenTextChanged);
    focusNode.addListener(_listenTextChanged);
  }

  updateBuildContext(BuildContext context) {
    this._context = context;
  }

  dispose() {
    _contentEditingController?.removeListener(_listenTextChanged);
    _contentEditingController?.dispose();
    _focusNode?.removeListener(_listenTextChanged);

    overlayEntry?.remove();
    overlayEntry = null;
  }

  _listenTextChanged() {
    if (_focusNode?.hasFocus == true) {
      var text = _contentEditingController?.value?.text;
      print(
          "#_listenTextChanged# _______ text: $text, ${text?.endsWith("#") == true}");
      if (text?.isNotEmpty == true && text?.endsWith("#") == true) {
        overlayEntry = _createOverlayEntry();
        Overlay.of(_context!)?.insert(overlayEntry!);
        print("#_listenTextChanged# _______ 1111");
      }
    } else {
      print("#_listenTextChanged# _______ lose focus！！！");
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _focusNode?.context?.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    print(
        "#_createOverlayEntry# _______ width: ${size.width}, height: ${size.height}, dx: ${offset.dx}, dy: ${offset.dy}");
    return OverlayEntry(builder: (BuildContext context) {
      return Positioned(
          left: offset.dx,
          top: offset.dy + 20,
          width: size.width,
          child: Material(
            elevation: 4.0,
            child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    title: Text('英语/单词'),
                  ),
                  ListTile(
                    title: Text('数学/逻辑思维'),
                  )
                ]),
          ));
    });
  }
}
