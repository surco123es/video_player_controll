import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kit_video_media/kit_video_media.dart';
import 'package:media_kit/media_kit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../video_player_controll.dart';
import 'languaje.dart';
import 'player.dart';

class DataPlayer {
  Duration currentPlay, totalPlay, bufferPlay;
  final List<StreamSubscription> _sub = [];
  bool returnPlay;
  int rateIndex;
  bool playing = false;
  DataPlayer({
    this.currentPlay = Duration.zero,
    this.totalPlay = Duration.zero,
    this.bufferPlay = Duration.zero,
    this.returnPlay = false,
    this.rateIndex = 2,
  });
  listen({required int token}) {
    _sub.addAll([
      managerPlayer.getController(token: token).player.stream.buffer.listen(
        (e) {
          bufferPlay = e;
        },
      ),
      managerPlayer.getController(token: token).player.stream.position.listen(
        (e) {
          currentPlay = e;
        },
      ),
      managerPlayer.getController(token: token).player.stream.duration.listen(
        (e) {
          if (totalPlay == Duration.zero) {
            managerPlayer.streamPlayer.sink
                .add(DataPlaying(token: token, load: true));
          }
          if (!playing) {
            managerPlayer.streamPlayer.sink.add(DataPlaying(
              token: token,
              load: true,
            ));
          }
        },
      ),
      managerPlayer.getController(token: token).player.stream.playing.listen(
        (e) {
          playing = e;
          print(e ? 'se esta reproduciendo' : 'se detuvo');
        },
      ),
    ]);
  }

  distroye() {
    for (StreamSubscription e in _sub) {
      e.cancel();
    }
  }
}

class ManagerController {
  final Map<int, VideoController> _controll = {};
  final Map<int, FormatMedia> _format = {};
  final Map<int, DataPlayer> _player = {};

  LanguageSetting language = LanguageSetting();
  int tokenFullScreen = 0;
  bool fullScreen = false;
  bool backFullScreen = false;
  StreamController<DataPlaying> streamPlayer =
      StreamController<DataPlaying>.broadcast();

  OverlayEntry? _fullscreenOverlay;

  setLanguage({required LanguageSetting lang}) {
    language = lang;
  }

  int token() {
    Random random = Random();
    int max = 9999999;
    int min = 1000000;
    int token = min + random.nextInt((max + 1) - 1);
    return token;
  }

  Future setController({
    required int token,
    Duration position = Duration.zero,
  }) async {
    _controll.addAll({
      token: VideoController(
        Player(),
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
        ),
      )
    });
    await _controll[token]!.player.open(
          Media(_format[token]!.format[_format[token]!.indexPlayer].urlVideo),
          play: false,
        );

    _player.addAll({token: DataPlayer()});
    _player[token]!.listen(token: token);

    late StreamSubscription sub;
    sub = _controll[token]!.player.stream.duration.listen(
      (e) async {
        if (e != Duration.zero) {
          await _controll[token]!.player.setAudioTrack(AudioTrack.uri(
              _format[token]!.format[_format[token]!.indexPlayer].urlAudio));
          await _controll[token]!.player.seek(position);
          if (videoPlayerControll.setting.autoPlay) {
            await _controll[token]!.player.play();
          }
          _controll[token]!
              .player
              .setVolume(videoPlayerControll.setting.volumen);
          repeat(token: token, repeat: videoPlayerControll.setting.repeat);
        }
        sub.cancel();
      },
    );
  }

  setIndexPlay({required int index, required int token}) {
    if (_format.containsKey(token)) {
      _format[token]!.indexPlayer = index;
    }
  }

  setCurrentTime({required int token}) {
    if (_player.containsKey(token)) {
      _player[token]!.currentPlay = _controll[token]!.player.state.position;
    }
  }

  setMedia({required FormatMedia v, required int token}) {
    if (_format.containsKey(token)) {
      _format[token] = v;
    } else {
      _format.addAll({token: v});
    }
  }

  setRatePlayer({required int index, required int token}) {
    if (_player.containsKey(token)) {
      _player[token]?.rateIndex = index;
    }
  }

  seek(Duration seek, {required int token}) {
    _controll[token]!.player.seek(seek);
  }

  repeat({required int token, bool repeat = false}) {
    _controll[token]!.player.setPlaylistMode(
          repeat ? PlaylistMode.single : PlaylistMode.none,
        );
  }

  DataPlayer getPlayer({required int token}) {
    return _player[token]!;
  }

  VideoController getController({required int token}) {
    if (_controll.containsKey(token)) {
      return _controll[token]!;
    } else {
      _controll.addAll({token: VideoController(Player())});
      return _controll[token]!;
    }
  }

  bool checkController({required int token}) {
    return _controll.containsKey(token);
  }

  dispose({required int token}) async {
    if (_controll.containsKey(token)) {
      await _controll[token]!.player.platform!.stop();
    }
  }

  FormatMedia? getMedia({required int token}) {
    return _format.containsKey(token) ? _format[token] : null;
  }

  Future purgePlayer({required int token, bool all = false}) async {
    if (!all) {
      await dispose(token: token);
      return;
    }
    _controll.forEach(
      (k, value) async {
        await dispose(token: token);
      },
    );
  }

  enterfullScreen(BuildContext context, {required int token}) async {
    tokenFullScreen = token;
    fullScreen = true;
    try {
      streamPlayer.sink.add(DataPlaying(token: token, fullScreen: true));
      _fullscreenOverlay = OverlayEntry(
        builder: (context) => Material(
          child: FullScreenWidget(token: token),
        ),
      );
      Overlay.of(context, rootOverlay: true).insert(_fullscreenOverlay!);
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait([
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          ),
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]),
        ]);
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await const MethodChannel('controller/kit_video_media').invokeMethod(
          'Utils.EnterNativeFullscreen',
        );
      }

      WakelockPlus.enable();
    } catch (e) {
      print(e);
    }
  }

  exitFullScreen(BuildContext context, {required int token}) async {
    fullScreen = false;
    backFullScreen = true;
    try {
      _fullscreenOverlay?.remove();
      _fullscreenOverlay = null;
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait([
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
          SystemChrome.setPreferredOrientations([]),
        ]);
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        await const MethodChannel('controller/kit_video_media').invokeMethod(
          'Utils.ExitNativeFullscreen',
        );
      }

      streamPlayer.sink.add(DataPlaying(token: token, exitFullScreen: true));
      WakelockPlus.disable();
    } catch (e) {
      print('algo paso aqui');
    }
  }

  setResolution({
    required int token,
    required int index,
  }) async {
    streamPlayer.sink.add(DataPlaying(
      token: token,
      updateResolution: true,
    ));
    Duration goCurrent = _player[token]!.currentPlay;
    bool play = _controll[token]!.player.state.playing;
    _format[token]!.indexPlayer = index;
    _controll[token]?.player.stop();
    late StreamSubscription sub;
    await _controll[token]
        ?.player
        .open(Media(_format[token]!.format[index].urlVideo), play: false);

    sub = _controll[token]!.player.stream.duration.listen(
      (e) {
        if (Duration.zero != e) {
          _controll[token]?.player.seek(goCurrent);
          if (_format[token]!.format[index].urlAudio != '') {
            _controll[token]?.player.setAudioTrack(
                AudioTrack.uri(_format[token]!.format[index].urlAudio));
          }
          if (play) {
            _controll[token]!.player.play();
          }
          sub.cancel();
          streamPlayer.sink.add(DataPlaying(
            token: token,
            loadResolution: true,
          ));
        }
      },
    );
  }
}
