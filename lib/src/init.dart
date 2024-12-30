import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_player_controll/video_player_controll.dart';

import 'controller.dart';
import 'interface.dart';
import 'model.dart';
import 'player.dart';

typedef getToken = Function(int token);

class PlayerControll {
  bool _init = false;
  SettingMedia setting = SettingMedia();
  ThemeControllData _theme = ThemeControllData();
  Widget play({
    SettingMedia? config,
    ThemeControllData? theme,
    getToken? funcStart,
    Size size = Size.zero,
    required FormatMedia media,
    int token = 0,
  }) {
    if (!_init) {
      return const Text(
          'Lo sentimos no inicializo el reproductor coloque al dentro de la funcion main(){ videoPlayerControll.init();...}');
    }
    if (config != null) {
      setting = config;
    }
    if (setting.multiPlayer) {
      token = managerPlayer.token();
    } else {
      managerPlayer.purgePlayer(token: token, all: false);
    }
    if (theme != null) {
      _setTheme(theme: theme);
    }
    if (funcStart != null) {
      funcStart(token);
    }
    if (managerPlayer.checkController(token: token)) {
      pFunc.open(format: media, token: token);
    } else {
      managerPlayer.setMedia(v: media, token: token);
      managerPlayer.setController(token: token);
    }

    if (size == Size.zero) {
      size = const Size(720, 350);
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: PlayerControlMain(
        token: token,
      ),
    );
  }

  ThemeControllData getTheme() {
    return _theme;
  }

  _setTheme({required ThemeControllData theme}) {
    _theme = theme;
  }

  init() async {
    try {
      if (_init) {
        return _init;
      }
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();
      _init = !_init;
    } catch (e) {
      print(e);
    }
    return _init;
  }
}
