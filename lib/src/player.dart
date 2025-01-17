import 'package:flutter/widgets.dart';
import 'package:kit_video_media/kit_video_media.dart';

import 'fnc.dart';

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
