import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';

import 'interface.dart';
import 'model.dart';

class PlayerControll {
  bool initController = false;
  SettingMedia setting = SettingMedia();
  ThemeControllData theme = ThemeControllData();
  goSetting({
    SettingMedia? config,
    ThemeControllData? themeSkin,
  }) {
    if (config != null) {
      setting = config;
    }
    if (themeSkin != null) {
      theme = themeSkin;
    }
  }

  init() async {
    try {
      if (initController) {
        return initController;
      }
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();
      initController = !initController;
    } catch (e) {
      print(e);
    }
    return initController;
  }
}
