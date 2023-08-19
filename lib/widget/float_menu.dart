import 'dart:ui';

import 'package:flutter/material.dart';

class FloatMenu {
  OverlayEntry? _overlayEntry;

  FloatMenu.open(BuildContext context, GlobalKey anchorPointKey,
      double childWidth, Widget child,
      {int offsetX = 0, int offsetY = 0}) {
    var renderBox = anchorPointKey.currentContext?.findRenderObject();
    if (renderBox == null) {
      return;
    }

    var screenSize = window.physicalSize;
    var screenWidth = screenSize.width;
    var screenHeight = screenSize.height;
    final position = renderBox!.getTransformTo(null).getTranslation();
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            ModalBarrier(
              onDismiss: () {
                close();
              },
            ),
            Positioned(
              left: position.x - offsetX,
              top: position.y + offsetY,
              width: childWidth,
              child: Material(
                elevation: 4.0,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    var overlayState = Overlay.of(context);
    overlayState?.insert(overlayEntry);
    close();
    _overlayEntry = overlayEntry;
  }

  close() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }
}
