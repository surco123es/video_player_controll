import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_video_media/kit_video_media.dart';
import 'package:loading_animation/animation/circle.dart';

import '../video_player_controll.dart';
import 'buttonControll.dart';
import 'controller.dart';

class PlayerControlMain extends StatefulWidget {
  bool fullScreen;
  int token;
  PlayerControlMain({
    super.key,
    this.fullScreen = false,
    required this.token,
  });

  @override
  State<PlayerControlMain> createState() => _PlayerControlMainState();
}

class _PlayerControlMainState extends State<PlayerControlMain> {
  bool fullScream = false;
  Timer? futurePlayer;
  bool rebuild = false;
  final LayerLink link = LayerLink();
  GlobalKey kg = GlobalKey();
  bool showSetting = false;
  ThemeControllData theme = videoPlayerControll.getTheme();
  bool load = false;
  bool rendePlayer = true;
  StreamSubscription? sdt;
  late FormatMedia? media;
  Size getSize() {
    RenderBox? r = kg.currentContext?.findRenderObject() as RenderBox;
    return r.size;
  }

  @override
  void initState() {
    if (widget.fullScreen) {
      load = true;
    }
    if (managerPlayer.checkController(token: widget.token)) {
      load = true;
    }
    sdt = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (e.load && !widget.fullScreen) {
          load = true;
          futurePlayer = Timer(
            const Duration(seconds: 1),
            () {
              setState(() {
                rendePlayer = false;
              });
            },
          );
        } else if (e.updateResolution) {
          setState(() {
            rebuild = true;
            rendePlayer = true;
          });
          futurePlayer = Timer(
            const Duration(milliseconds: 500),
            () {
              setState(() {
                rebuild = false;
                rendePlayer = false;
              });
            },
          );
        } else if (e.fullScreen && !widget.fullScreen) {
          setState(() {
            fullScream = true;
          });
        } else if (e.exitFullScreen && !widget.fullScreen) {
          setState(() {
            fullScream = false;
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
      if (!widget.fullScreen && !videoPlayerControll.setting.playBackground) {
        managerPlayer.dispose(token: widget.token);
      }
    }
    futurePlayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = managerPlayer.getMedia(token: widget.token);
    return Container(
      color: Colors.black,
      key: kg,
      child: Stack(
        children: [
          fullScream
              ? const SizedBox()
              : PlayerControllWidget(
                  token: widget.token,
                ),
          if (load)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: VolumenAndBrightControll(
                token: widget.token,
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
                      token: widget.token,
                    ),
                    Row(
                      children: [
                        PlayOrPauseButton(
                          token: widget.token,
                        ),
                        VolumeButton(
                          token: widget.token,
                        ),
                        const Spacer(),
                        SettingButton(
                          link: link,
                          token: widget.token,
                          onChange: (show) {
                            showSetting = show;
                          },
                        ),
                        FullScreemButton(
                          token: widget.token,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (load) PlayOrPauseAnimation(token: widget.token),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: load ? 0 : 1,
              child: const CircleFlyOrbit(),
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerControllWidget extends StatelessWidget {
  int token;
  PlayerControllWidget({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: managerPlayer.getController(token: token),
      controls: NoVideoControls,
      pauseUponEnteringBackgroundMode:
          !videoPlayerControll.setting.backgroundPlayer,
      resumeUponEnteringForegroundMode:
          videoPlayerControll.setting.resumenBackgroundRestart,
    );
  }
}
