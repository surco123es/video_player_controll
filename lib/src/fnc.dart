import 'package:media_kit/media_kit.dart';

import 'controller.dart';
import 'init.dart';
import 'model.dart';

class FuncPlayerManager {
  open({required FormatMedia format, required int token}) async {
    if (!managerPlayer.checkController(token: token)) {
      print('no existe el reproductor');
      return;
    }
    await managerPlayer.getController(token: token).player.stop();
    managerPlayer.setMedia(v: format, token: token);
    await managerPlayer
        .getController(token: token)
        .player
        .open(Media(format.format[format.indexPlayer].urlVideo), play: false);
    Future.delayed(
      const Duration(milliseconds: 250),
      () async {
        if (format.format[format.indexPlayer].urlAudio != '') {
          await managerPlayer.getController(token: token).player.setAudioTrack(
              AudioTrack.uri(format.format[format.indexPlayer].urlAudio));
        }
        if (videoPlayerControll.setting.autoPlay) {
          managerPlayer.getController(token: token).player.play();
        }
      },
    );
  }

  play({
    int token = 0,
  }) {
    bool stus = managerPlayer.checkController(token: token);
    if (stus) {
      managerPlayer.getController(token: token).player.play();
    }
  }

  pause({
    int token = 0,
  }) {
    bool stus = managerPlayer.checkController(token: token);
    if (stus) {
      managerPlayer.getController(token: token).player.pause();
    }
  }

  stop({
    int token = 0,
  }) {
    bool stus = managerPlayer.checkController(token: token);
    if (stus) {
      managerPlayer.getController(token: token).player.stop();
    }
  }

  volumen({
    required double volumen,
    int token = 0,
  }) {
    bool stus = managerPlayer.checkController(token: token);
    if (stus) {
      managerPlayer.getController(token: token).player.setVolume(volumen);
    }
  }

  seek({
    required Duration position,
    int token = 0,
  }) {
    bool stus = managerPlayer.checkController(token: token);
    if (stus) {
      managerPlayer.getController(token: token).player.seek(position);
    }
  }
}

FuncPlayerManager pFunc = FuncPlayerManager();
PlayerControll videoPlayerControll = PlayerControll();
ManagerController managerPlayer = ManagerController();
