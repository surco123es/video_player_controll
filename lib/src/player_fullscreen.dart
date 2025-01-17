import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animation/animation/circle.dart';

import '../video_player_controll.dart';
import 'buttonControll.dart';
import 'player.dart';

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

  bool load = false;

  final LayerLink link = LayerLink();

  GlobalKey kg = GlobalKey();

  bool showSetting = false;

  ThemeControllData theme = videoPlayerControll.theme;

  StreamSubscription? sdt;

  late FormatMedia? media;

  @override
  void initState() {
    media = managerPlayer.getMedia(token: widget.token);
    sdt = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (widget.token != e.token) {
          return;
        }
        if (e.updateResolution) {
          setState(() {
            load = true;
          });
        } else if (e.loadResolution) {
          setState(() {
            load = false;
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
          Center(
            child: Visibility(
              visible: load,
              child: const CircleFlyOrbit(),
            ),
          ),
        ],
      ),
    );
  }
}
