import 'package:flutter/material.dart';

enum TypeFormat {
  audio,
  video,
  audioVideo,
}

class ResolutionFormat {
  String format, urlVideo, urlAudio, resolution;
  TypeFormat type;
  ResolutionFormat({
    required this.format,
    required this.resolution,
    required this.type,
    required this.urlVideo,
    this.urlAudio = '',
  });
}

class FormatMedia {
  String title;
  int indexPlayer;
  List<ResolutionFormat> format;
  FormatMedia({
    required this.title,
    required this.indexPlayer,
    required this.format,
  });
}

class SettingMedia {
  bool autoPlay,
      repeat,
      autoNextPlayer,
      fullScreen,
      multiPlayer,
      backgroundPlayer,
      playBackground,
      resumenBackgroundRestart;

  Size size;
  SettingMedia({
    this.autoPlay = false,
    this.resumenBackgroundRestart = true,
    this.playBackground = true,
    this.autoNextPlayer = false,
    this.fullScreen = true,
    this.repeat = false,
    this.multiPlayer = false,
    this.size = Size.zero,
    this.backgroundPlayer = false,
  });
}

class PlayVideo {
  SettingMedia setting;
  FormatMedia media;
  PlayVideo({
    required this.setting,
    required this.media,
  });
}
