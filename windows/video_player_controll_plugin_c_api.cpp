#include "include/video_player_controll/video_player_controll_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "video_player_controll_plugin.h"

void VideoPlayerControllPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  video_player_controll::VideoPlayerControllPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
