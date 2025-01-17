import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation/loading_animation.dart';

import '../video_player_controll.dart';
import 'buttonControll.dart';
import 'player.dart';

class PlayerMedia extends StatefulWidget {
  getToken? funcStart;
  Size size = Size.zero;
  FormatMedia media;

  PlayerMedia({
    super.key,
    this.funcStart,
    this.size = Size.zero,
    required this.media,
  });

  @override
  State<PlayerMedia> createState() => _PlayerControlMainState();
}

class _PlayerControlMainState extends State<PlayerMedia> {
  int token = 0;

  bool fullScreen = false;
  Timer? futurePlayer;
  bool rebuild = false;
  final LayerLink link = LayerLink();
  GlobalKey kg = GlobalKey();
  bool showSetting = false;
  ThemeControllData theme = videoPlayerControll.theme;
  bool load = false;
  StreamSubscription? sdt;
  late FormatMedia? media;
  Size getSize() {
    RenderBox? r = kg.currentContext?.findRenderObject() as RenderBox;
    return r.size;
  }

  @override
  void initState() {
    if (videoPlayerControll.setting.multiPlayer) {
      token = managerPlayer.token();
    }
    if (widget.funcStart != null) {
      widget.funcStart!(token);
    }
    if (managerPlayer.checkController(token: token)) {
      pFunc.open(format: widget.media, token: token);
    } else {
      managerPlayer.setMedia(v: widget.media, token: token);
      managerPlayer.setController(token: token);
    }

    if (widget.size == Size.zero) {
      widget.size = const Size(720, 350);
    }

    sdt = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (token != e.token) {
          return;
        }
        if (e.load) {
          setState(() {
            load = true;
          });
        } else if (e.updateResolution) {
          setState(() {
            load = false;
          });
        } else if (e.loadResolution) {
          setState(() {
            load = true;
          });
        } else if (e.fullScreen) {
          setState(() {
            fullScreen = true;
          });
        } else if (e.exitFullScreen) {
          setState(() {
            fullScreen = false;
          });
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    if (sdt != null) {
      sdt!.cancel();
    }
    if (!videoPlayerControll.setting.backgroundPlayer && !fullScreen) {
      managerPlayer.dispose(token: token);
    }
    futurePlayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!videoPlayerControll.initController) {
      return const Text(
          'Lo sentimos no inicializo el reproductor coloque al dentro de la funcion main(){ videoPlayerControll.init();...}');
    }
    media = managerPlayer.getMedia(token: token);
    if (media == null) {
      return const Center(child: Text('Error: Media not found'));
    }
    return Container(
      color: Colors.black,
      key: kg,
      width: widget.size.width,
      height: widget.size.height,
      child: Stack(
        children: [
          if (!fullScreen)
            PlayerControllWidget(
              token: token,
            ),
          if (load)
            Positioned.fill(
              child: VolumenAndBrightControll(
                token: token,
              ),
            ),
          if (load)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: theme.barControll,
                child: Column(
                  children: [
                    SeekBar(
                      token: token,
                    ),
                    Row(
                      children: [
                        PlayOrPauseButton(
                          token: token,
                        ),
                        VolumeButton(
                          token: token,
                        ),
                        const Spacer(),
                        SettingButton(
                          link: link,
                          token: token,
                          onChange: (show) {
                            showSetting = show;
                          },
                        ),
                        FullScreemButton(
                          token: token,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (load) PlayOrPauseAnimation(token: token),
          Center(
            child: Visibility(
              visible: !load,
              child: const CircleFlyOrbit(),
            ),
          ),
        ],
      ),
    );
  }
}
