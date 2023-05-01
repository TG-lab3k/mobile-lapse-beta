import 'package:flutter/widgets.dart';

class _Resources {
  Map<String, dynamic>? i18nMap;

  initialize() {}

  String imagePath(String name) {
    return "assets/images/$name";
  }

  Image image(String name) {
    return Image.asset(imagePath(name));
  }

  String text(String key) {
    return i18nMap?[key];
  }
}

class Assets {
  static final _Resources _res = _Resources();
  static bool initialized = false;

  const Assets._private();

  static initialize() {
    if (initialized) {
      return;
    }
    initialized = true;
    _res.initialize();
  }

  static imagePath(String name) => _res.imagePath(name);

  static image(String name) => _res.image(name);

  static text(String name) => _res.text(name);
}
