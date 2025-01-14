import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../video_player_controll.dart';

typedef VoidCallback = void Function();
typedef ShowFunc = void Function(bool show);

/// Material design seek bar.
class SeekBar extends StatefulWidget {
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final int token;
  const SeekBar({
    super.key,
    this.onSeekStart,
    this.onSeekEnd,
    required this.token,
  });

  @override
  State<SeekBar> createState() => _SeekBar();
}

class _SeekBar extends State<SeekBar> {
  bool hover = false;
  bool click = false;
  double slider = 0.0;
  ThemeControllData theme = videoPlayerControll.getTheme();

  late bool playing = false;
  late Duration position = Duration.zero;
  late Duration duration = Duration.zero;
  late Duration buffer = Duration.zero;

  final List<StreamSubscription> subscriptions = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(() {
          duration = managerPlayer
              .getController(token: widget.token)
              .player
              .state
              .duration;
          buffer = managerPlayer
              .getController(token: widget.token)
              .player
              .state
              .buffer;
          position = managerPlayer
              .getController(token: widget.token)
              .player
              .state
              .position;
          playing = managerPlayer
              .getController(token: widget.token)
              .player
              .state
              .playing;
        });
        subcri();
      },
    );
  }

  subcri() {
    subscriptions.addAll(
      [
        managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .playing
            .listen((event) {
          setState(() {
            playing = event;
          });
        }),
        managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .completed
            .listen((event) {
          setState(() {
            position = Duration.zero;
          });
        }),
        managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .position
            .listen((event) {
          setState(() {
            if (!click) position = event;
          });
        }),
        managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .duration
            .listen((event) {
          setState(() {
            duration = event;
          });
        }),
        managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .buffer
            .listen((event) {
          setState(() {
            buffer = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPointerDown() {
    widget.onSeekStart?.call();
    setState(() {
      click = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      click = false;
    });
    managerPlayer
        .getController(token: widget.token)
        .player
        .seek(duration * slider);
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      position = duration * slider;
    });
  }

  void onHover(PointerHoverEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onEnter(PointerEnterEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onExit(PointerExitEvent e, BoxConstraints constraints) {
    setState(() {
      hover = false;
      slider = 0.0;
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      child: LayoutBuilder(
        builder: (context, constraints) => MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => onHover(e, constraints),
          onEnter: (e) => onEnter(e, constraints),
          onExit: (e) => onExit(e, constraints),
          child: Listener(
            onPointerMove: (e) => onPointerMove(e, constraints),
            onPointerDown: (e) => onPointerDown(),
            onPointerUp: (e) => onPointerUp(),
            child: Container(
              color: const Color(0x00000000),
              width: constraints.maxWidth,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedContainer(
                    width: constraints.maxWidth,
                    height:
                        hover ? theme.seekBarHeigthHover : theme.seekBarHeigth,
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 500),
                    color: Colors.amber,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          width: constraints.maxWidth * slider,
                          color: Colors.amberAccent,
                        ),
                        Container(
                          width: constraints.maxWidth * bufferPercent,
                          color: Colors.orange,
                        ),
                        Container(
                          width: click
                              ? constraints.maxWidth * slider
                              : constraints.maxWidth * positionPercent,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: click
                        ? (constraints.maxWidth - 8 / 2) * slider
                        : (constraints.maxWidth - 8 / 2) * positionPercent,
                    child: AnimatedContainer(
                      width: hover || click ? 8 : 0.0,
                      height: hover || click ? 8 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(
                          8 / 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A material design play/pause button.
class PlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final int token;

  /// Overriden icon color for [MaterialSkipPreviousButton].
  final Color? iconColor;

  const PlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    required this.token,
  });

  @override
  State<PlayOrPauseButton> createState() => _playOrPauseButton();
}

class _playOrPauseButton extends State<PlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  ThemeControllData theme = videoPlayerControll.getTheme();
  bool play = false;
  late final animation = AnimationController(
    vsync: this,
    value: managerPlayer.getController(token: widget.token).player.state.playing
        ? 1
        : 0,
    duration: const Duration(milliseconds: 200),
  );

  StreamSubscription<bool>? subscription;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        play = managerPlayer
            .getController(token: widget.token)
            .player
            .state
            .playing;
        if (play) {
          animation.forward();
        }
        subin();
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  subin() {
    subscription ??= managerPlayer
        .getController(token: widget.token)
        .player
        .stream
        .playing
        .listen((e) {
      if (e) {
        animation.forward();
      } else {
        animation.reverse();
      }
    });
  }

  @override
  void dispose() {
    animation.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        managerPlayer.getController(token: widget.token).player.playOrPause();
      },
      iconSize: theme.iconSize,
      color: theme.colorButtonIcon,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: AnimatedIcon(
        progress: animation,
        icon: AnimatedIcons.play_pause,
        size: theme.iconSize,
        color: theme.colorButtonIcon,
      ),
    );
  }
}
//volumen control

/// Material design volume button & slider.
class VolumeButton extends StatefulWidget {
  /// Icon size for the volume button.
  final double? iconSize;
  final int token;

  /// Icon color for the volume button.
  final Color? iconColor;

  /// Mute icon.
  final Widget? volumeMuteIcon;

  /// Low volume icon.
  final Widget? volumeLowIcon;

  /// High volume icon.
  final Widget? volumeHighIcon;

  /// Width for the volume slider.
  final double? sliderWidth;

  const VolumeButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.volumeMuteIcon,
    this.volumeLowIcon,
    this.volumeHighIcon,
    this.sliderWidth,
    required this.token,
  });

  @override
  State<VolumeButton> createState() => _VolumeButton();
}

class _VolumeButton extends State<VolumeButton>
    with SingleTickerProviderStateMixin {
  double volume = 5;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(() {
          volume = managerPlayer
              .getController(token: widget.token)
              .player
              .state
              .volume;
        });
        subin();
      },
    );
  }

  StreamSubscription<double>? subscription;
  ThemeControllData theme = videoPlayerControll.getTheme();

  bool hover = false;

  bool mute = false;
  double _volume = 0.0;

  subin() {
    subscription ??= managerPlayer
        .getController(token: widget.token)
        .player
        .stream
        .volume
        .listen((event) {
      setState(() {
        volume = event;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) {
        setState(() {
          hover = true;
        });
      },
      onExit: (e) {
        setState(() {
          hover = false;
        });
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy < 0) {
              managerPlayer.getController(token: widget.token).player.setVolume(
                    (volume + 5.0).clamp(0.0, 100.0),
                  );
            }
            if (event.scrollDelta.dy > 0) {
              managerPlayer.getController(token: widget.token).player.setVolume(
                    (volume - 5.0).clamp(0.0, 100.0),
                  );
            }
          }
        },
        child: Row(
          children: [
            const SizedBox(width: 4.0),
            IconButton(
              onPressed: () async {
                if (mute) {
                  await managerPlayer
                      .getController(token: widget.token)
                      .player
                      .setVolume(_volume);
                  mute = !mute;
                } else if (volume == 0.0) {
                  _volume = 100.0;
                  await managerPlayer
                      .getController(token: widget.token)
                      .player
                      .setVolume(100.0);
                  mute = false;
                } else {
                  _volume = volume;
                  if (widget.token != 0) {}
                  await managerPlayer
                      .getController(token: widget.token)
                      .player
                      .setVolume(0.0);
                  mute = !mute;
                }

                setState(() {});
              },
              padding: theme.paddingButtonIcon,
              iconSize: theme.iconSize,
              color: theme.colorButtonIcon,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              icon: AnimatedSwitcher(
                duration: theme.transitionDuration,
                child: volume == 0.0
                    ? (widget.volumeMuteIcon ??
                        const Icon(
                          Icons.volume_off,
                          key: ValueKey(Icons.volume_off),
                        ))
                    : volume < 50.0
                        ? (widget.volumeLowIcon ??
                            const Icon(
                              Icons.volume_down,
                              key: ValueKey(Icons.volume_down),
                            ))
                        : (widget.volumeHighIcon ??
                            const Icon(
                              Icons.volume_up,
                              key: ValueKey(Icons.volume_up),
                            )),
              ),
            ),
            AnimatedOpacity(
              opacity: hover ? 1.0 : 0.0,
              duration: theme.transitionDuration,
              child: AnimatedContainer(
                width:
                    hover ? (12.0 + (widget.sliderWidth ?? 52.0) + 18.0) : 12.0,
                duration: theme.transitionDuration,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 12.0),
                      SizedBox(
                        width: widget.sliderWidth ?? 52.0,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 1.2,
                            inactiveTrackColor: theme.colorVolumen,
                            activeTrackColor: theme.activeColorVolumen,
                            thumbColor: theme.colorVolumen,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 15 / 2,
                              elevation: 0.0,
                              pressedElevation: 0.0,
                            ),
                            trackShape: _CustomTrackShape(),
                            overlayColor: const Color(0x00000000),
                          ),
                          child: Slider(
                            value: volume.clamp(0, 100),
                            min: 0,
                            max: 100,
                            onChanged: (v) async {
                              await managerPlayer
                                  .getController(token: widget.token)
                                  .player
                                  .setVolume(v);
                              mute = false;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 18.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight;
    final left = offset.dx;
    final top = offset.dy + (parentBox.size.height - height!) / 2;
    final width = parentBox.size.width;
    return Rect.fromLTWH(
      left,
      top,
      width,
      height,
    );
  }
}

//fullScreem Buttom

class FullScreemButton extends StatelessWidget {
  final Widget? icon;
  int token;
  final double? iconSize;

  final Color? iconColor;
  ThemeControllData theme = videoPlayerControll.getTheme();

  FullScreemButton({
    super.key,
    this.icon,
    this.iconSize,
    this.iconColor,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => managerPlayer.fullScreen
          ? managerPlayer.exitFullScreen(context, token: token)
          : managerPlayer.enterfullScreen(
              context,
              token: token,
            ),
      padding: theme.paddingButtonIcon,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      icon: icon ??
          (managerPlayer.fullScreen
              ? const Icon(Icons.fullscreen_exit)
              : const Icon(Icons.fullscreen)),
      iconSize: theme.iconSize,
      color: theme.colorButtonIcon,
    );
  }
}

class SettingButton extends StatefulWidget {
  LayerLink link;
  ShowFunc onChange;
  int token;
  SettingButton({
    super.key,
    required this.link,
    required this.onChange,
    required this.token,
  });

  @override
  State<SettingButton> createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {
  late FormatMedia media;
  late OverlayEntry settingShow;

  int maxHeigth = 0;

  bool showSetting = false;
  late StreamSubscription sub;
  ThemeControllData theme = videoPlayerControll.getTheme();
  @override
  void initState() {
    media = managerPlayer.getMedia(token: widget.token)!;
    sub = managerPlayer.streamPlayer.stream.listen(
      (e) {
        if (!e.load) {
          setState(() {});
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    if (showSetting) {
      {
        settingShow.remove();
      }
    }
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return CompositedTransformTarget(
      link: widget.link,
      child: TapRegion(
        onTapInside: (_) {
          if (showSetting) {
            settingShow.remove();
          } else {
            settingShow = OverlayEntry(
              builder: (context) => SettingAndPlayer(
                link: widget.link,
                media: media,
                token: widget.token,
                hide: () {
                  settingShow.remove();
                  showSetting = !showSetting;
                },
              ),
            );
            Overlay.of(context).insert(settingShow);
          }
          showSetting = !showSetting;
          widget.onChange(showSetting);
        },
        child: Row(
          children: [
            Icon(
              Icons.settings,
              color: theme.colorButtonIcon,
              size: theme.iconSize,
            ),
            if (media.format.length > 1)
              Text(
                media.format[media.indexPlayer].resolution,
                style: TextStyle(
                  color: theme.colorButtonIcon,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ),
      ),
    );
  }
}

class SettingAndPlayer extends StatefulWidget {
  final LayerLink link;
  final FormatMedia media;
  final VoidCallback hide;
  final int token;

  const SettingAndPlayer({
    super.key,
    required this.link,
    required this.media,
    required this.token,
    required this.hide,
  });

  @override
  State<SettingAndPlayer> createState() => _SettingAndPlayerState();
}

class _SettingAndPlayerState extends State<SettingAndPlayer> {
  ThemeControllData theme = videoPlayerControll.getTheme();
  Offset position = Offset.zero;
  GlobalKey gKey = GlobalKey();
  Timer? timerCall;
  int visible = 0;
  late int activeItemResolution;
  late int activeItemSpeedRate;

  @override
  void initState() {
    super.initState();
    activeItemResolution = widget.media.indexPlayer;
    activeItemSpeedRate =
        managerPlayer.getPlayer(token: widget.token).rateIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPosition();
    });
  }

  void getPosition() {
    RenderBox rn = gKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      position = Offset(-(rn.size.width / 2), -(rn.size.height + 10));
    });
  }

  @override
  void dispose() {
    timerCall?.cancel();
    super.dispose();
  }

  Widget buildSettingTitle({required int visibleIndex, required String title}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            visible = visible == visibleIndex ? 0 : visibleIndex;
            timerCall = Timer(const Duration(milliseconds: 50), () {
              getPosition();
            });
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          width: double.infinity,
          decoration: visible == visibleIndex
              ? theme.activeItemMenu
              : theme.subResolutionDecoration,
          padding: EdgeInsets.all(theme.subPaddingResolution),
          child: Text(
            title,
            style: visible == visibleIndex
                ? theme.activeItemMenuText
                : theme.resolutionStyleTextItems,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          CompositedTransformFollower(
            offset: position,
            link: widget.link,
            child: TapRegion(
              onTapOutside: (_) {
                timerCall = Timer(const Duration(milliseconds: 200), () {
                  widget.hide();
                });
              },
              child: Container(
                key: gKey,
                width: 200,
                decoration: theme.resolutionDecoration,
                padding: EdgeInsets.all(theme.paddingResolution),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.media.format.length > 1)
                        buildSettingTitle(
                          visibleIndex: 1,
                          title: managerPlayer.language.resolution,
                        ),
                      if (visible == 1)
                        SizedBox(
                          height: widget.media.format.length > 6 ? 180 : null,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: widget.media.format
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (e.key !=
                                              managerPlayer
                                                  .getMedia(
                                                      token: widget.token)!
                                                  .indexPlayer) {
                                            managerPlayer.setResolution(
                                              token: widget.token,
                                              index: e.key,
                                            );
                                          }
                                          setState(() {
                                            activeItemResolution = e.key;
                                          });
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: activeItemResolution ==
                                                  e.key
                                              ? theme.activeItemListMenu
                                              : theme
                                                  .subResolutionDecorationItem,
                                          padding: EdgeInsets.all(
                                              theme.paddingResolution),
                                          child: Text(
                                            e.value.resolution,
                                            style: activeItemResolution == e.key
                                                ? theme.activeItemMenuText
                                                : theme
                                                    .resolutionStyleTextItems,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      buildSettingTitle(
                        visibleIndex: 2,
                        title: managerPlayer.language.speedRate,
                      ),
                      if (visible == 2)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            5,
                            (index) {
                              String tl = '0';
                              double rt = 0.25 * (index + 2);
                              if (index == 0) {
                                tl = '-0.5';
                              } else if (index == 1) {
                                tl = '0.25';
                              } else if (index == 2) {
                                tl = '0';
                              } else if (index == 3) {
                                tl = '0.25';
                              } else if (index == 4) {
                                tl = '0.5';
                              }
                              return GestureDetector(
                                onTap: () {
                                  managerPlayer
                                      .getController(token: widget.token)
                                      .player
                                      .setRate(rt);
                                  managerPlayer.setRatePlayer(
                                    index: index,
                                    token: widget.token,
                                  );
                                  setState(() {
                                    activeItemSpeedRate = index;
                                  });
                                },
                                child: Container(
                                  decoration: activeItemSpeedRate == index
                                      ? theme.activeItemListMenu
                                      : theme.subResolutionDecorationItem,
                                  padding:
                                      EdgeInsets.all(theme.paddingResolution),
                                  child: Text(
                                    tl,
                                    style: activeItemSpeedRate == index
                                        ? theme.activeItemMenuText
                                        : theme.resolutionStyleTextItems,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolumenAndBrightControll extends StatefulWidget {
  int token;
  VolumenAndBrightControll({
    required this.token,
    super.key,
  });

  @override
  State<VolumenAndBrightControll> createState() => _BtnManagerDurationState();
}

class _BtnManagerDurationState extends State<VolumenAndBrightControll> {
  GlobalKey gKey = GlobalKey();
  Size pSize = Size.zero;

  int duration = 0;
  bool pause = false;
  late StreamSubscription sub;
  double vPlay = 0;
  double vBack = 0;
  double vNext = 0;

  double goDirection = 0;

  int owlBright = 0;

  bool brightOn = false;

  int onBright = 0;
  int bright = 0;
  int onVolumen = 0;
  int volumen = 0;

  bool showBright = false;
  bool showVolumen = false;

  Size getSize() {
    RenderBox rd = gKey.currentContext!.findRenderObject() as RenderBox;
    return rd.size;
  }

  goPositionPlaying({required bool back}) {
    if (duration == 0) {
      managerPlayer
          .getController(token: widget.token)
          .player
          .state
          .duration
          .inSeconds;
    }
    int inSecond = managerPlayer
        .getController(token: widget.token)
        .player
        .state
        .position
        .inSeconds;

    managerPlayer.getController(token: widget.token).player.seek(
          Duration(seconds: back ? inSecond - 10 : inSecond + 10),
        );
  }

  @override
  void initState() {
    super.initState();
    managerPlayer.getController(token: widget.token).player.state.playing;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        try {
          await initFunc();
        } catch (e) {
          print(e);
        }
      },
    );
    sub = managerPlayer
        .getController(token: widget.token)
        .player
        .stream
        .playing
        .listen(
      (e) {
        setState(() {
          pause = e;
        });
      },
    );
  }

  initFunc() async {
    double v = 0;
    if (Platform.isWindows) {
    } else {
      v = await ScreenBrightness.instance.application;
      brightOn = true;
    }
    bright = v.ceil();
  }

  pauseOrPlay() {
    managerPlayer.getController(token: widget.token).player.playOrPause();
  }

  @override
  void dispose() {
    sub.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      key: gKey,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: brightOn
              ? GestureDetector(
                  onDoubleTap: () {
                    goPositionPlaying(back: true);
                  },
                  onVerticalDragStart: (d) {
                    pSize = getSize();
                    goDirection = d.localPosition.dy;
                    showBright = true;
                  },
                  onVerticalDragUpdate: (d) {
                    if (goDirection > d.localPosition.dy) {
                      bright = bright <= 99 ? bright + 1 : 100;
                    } else {
                      bright = bright <= 1 ? 1 : bright - 1;
                    }
                    goDirection = d.localPosition.dy;
                    ScreenBrightness.instance
                        .setApplicationScreenBrightness(1 / (100 / bright));
                    if (owlBright != bright) {
                      owlBright = bright;
                      setState(() {});
                    }
                  },
                  onVerticalDragEnd: (d) {
                    showBright = false;
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: showBright ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ]),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  bright < 50
                                      ? Icons.light_mode_outlined
                                      : Icons.light_mode_rounded,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  bright.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    pauseOrPlay();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              pauseOrPlay();
            },
            onDoubleTap: () {
              goPositionPlaying(back: false);
            },
            onVerticalDragStart: (d) {
              pSize = getSize();
              goDirection = d.localPosition.dy;
              showVolumen = true;
            },
            onVerticalDragUpdate: (d) {
              if (goDirection > d.localPosition.dy) {
                volumen = volumen <= 99 ? volumen + 1 : 100;
              } else {
                volumen = volumen <= 1 ? 1 : volumen - 1;
              }

              goDirection = d.localPosition.dy;
              managerPlayer
                  .getController(token: widget.token)
                  .player
                  .setVolume(volumen.toDouble());
              if (owlBright != volumen) {
                owlBright = volumen;
                setState(() {});
              }
            },
            onVerticalDragEnd: (d) {
              setState(() {
                showVolumen = false;
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: showVolumen ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              spreadRadius: 0,
                              blurStyle: BlurStyle.outer,
                            ),
                          ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            volumen > 50
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            volumen.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayOrPauseAnimation extends StatefulWidget {
  int token;
  PlayOrPauseAnimation({
    super.key,
    required this.token,
  });

  @override
  State<PlayOrPauseAnimation> createState() => _PlayOrPauseAnimationState();
}

class _PlayOrPauseAnimationState extends State<PlayOrPauseAnimation> {
  bool play = false;
  late StreamSubscription sub;
  double opacity = 0;
  @override
  void initState() {
    play =
        managerPlayer.getController(token: widget.token).player.state.playing;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        sub = managerPlayer
            .getController(token: widget.token)
            .player
            .stream
            .playing
            .listen(
          (e) {
            setState(() {
              opacity = 1;
              play = e;
            });
          },
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: opacity,
        onEnd: () {
          setState(() {
            opacity = 0;
          });
        },
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [
              BoxShadow(blurRadius: 5),
            ],
          ),
          child: Icon(
            play ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 35,
          ),
        ),
      ),
    );
  }
}
