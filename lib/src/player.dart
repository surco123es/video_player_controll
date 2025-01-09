import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kit_video_media/kit_video_media.dart';
import 'package:loading_animation/animation/circle.dart';

import '../video_player_controll.dart';
import 'buttonControll.dart';

class PlayerControlMain extends StatefulWidget {
  int token;
  PlayerControlMain({
    super.key,
    required this.token,
  });

  @override
  State<PlayerControlMain> createState() => _PlayerControlMainState();
}

class _PlayerControlMainState extends State<PlayerControlMain> {
  bool fullScreen = false;
  Timer? futurePlayer;
  bool rebuild = false;
  final LayerLink link = LayerLink();
  GlobalKey kg = GlobalKey();
  bool showSetting = false;
  ThemeControllData theme = videoPlayerControll.getTheme();
  bool load = false;
  StreamSubscription? sdt;
  late FormatMedia? media;
  Size getSize() {
    RenderBox? r = kg.currentContext?.findRenderObject() as RenderBox;
    return r.size;
  }

  @override
  void initState() {
    if (managerPlayer.checkController(token: widget.token)) {
      load = true;
    }
    sdt = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (e.load) {
          load = true;
        } else if (e.updateResolution) {
          setState(() {
            rebuild = true;
          });
          futurePlayer = Timer(
            const Duration(milliseconds: 500),
            () {
              setState(() {
                rebuild = false;
              });
            },
          );
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
      print('dispose');
      managerPlayer.dispose(token: widget.token);
    }
    futurePlayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    media = managerPlayer.getMedia(token: widget.token);
    if (media == null) {
      return const Center(child: Text('Error: Media not found'));
    }
    return Container(
      color: Colors.black,
      key: kg,
      child: Stack(
        children: [
          if (!fullScreen)
            PlayerControllWidget(
              token: widget.token,
            ),
          if (load)
            Positioned.fill(
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

class FullScreenWidget extends StatefulWidget {
  int token;
  FullScreenWidget({
    super.key,
    required this.token,
  });

  @override
  State<FullScreenWidget> createState() => _fullScreenWidgetState();
}

class _fullScreenWidgetState extends State<FullScreenWidget> {
  Timer? futurePlayer;

  bool rebuild = false;

  final LayerLink link = LayerLink();

  GlobalKey kg = GlobalKey();

  bool showSetting = false;

  ThemeControllData theme = videoPlayerControll.getTheme();

  StreamSubscription? sdt;

  late FormatMedia? media;

  @override
  void initState() {
    media = managerPlayer.getMedia(token: widget.token);
    sdt = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (e.updateResolution) {
          setState(() {
            rebuild = true;
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
    futurePlayer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      return const Center(child: Text('Error: Media not found'));
    }
    return Container(
      color: Colors.black,
      key: kg,
      child: Stack(
        children: [
          PlayerControllWidget(
            token: widget.token,
          ),
          Positioned.fill(
            child: VolumenAndBrightControll(
              token: widget.token,
            ),
          ),
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
          PlayOrPauseAnimation(token: widget.token),
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
          !videoPlayerControll.setting.playSleepBackground,
      resumeUponEnteringForegroundMode:
          videoPlayerControll.setting.resumenBackgroundRestart,
    );
  }
}
