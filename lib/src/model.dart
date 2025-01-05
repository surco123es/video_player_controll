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
  bool autoPlay, repeat, autoNextPlayer, fullScreen, multiPlayer;
  double volumen;

  ///esta parte es para configurar que el reproductor siga reproducciendo dentro de la app mientras se navega por la aplicacion.
  bool backgroundPlayer;

  ///es para seguir reproduciendo en segundo plano fuera de la aplicaion.
  bool playSleepBackground;

  ///es para reanudar la reproduccion.
  bool resumenBackgroundRestart;

  Size size;
  SettingMedia(
      {this.autoPlay = false,
      this.resumenBackgroundRestart = true,
      this.playSleepBackground = true,
      this.autoNextPlayer = false,
      this.fullScreen = true,
      this.repeat = false,
      this.multiPlayer = false,
      this.size = Size.zero,
      this.backgroundPlayer = false,
      this.volumen = 50});
}

class PlayVideo {
  SettingMedia setting;
  FormatMedia media;
  PlayVideo({
    required this.setting,
    required this.media,
  });
}

class DataPlaying {
  bool load, updateResolution, fullScreen, exitFullScreen;
  int token;

  DataPlaying({
    required this.token,
    this.load = false,
    this.updateResolution = false,
    this.fullScreen = false,
    this.exitFullScreen = false,
  });
}
