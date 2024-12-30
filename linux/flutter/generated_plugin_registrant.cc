//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <kit_video_media/kit_video_media_plugin.h>
#include <media_kit_libs_linux/media_kit_libs_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) kit_video_media_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KitVideoMediaPlugin");
  kit_video_media_plugin_register_with_registrar(kit_video_media_registrar);
  g_autoptr(FlPluginRegistrar) media_kit_libs_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MediaKitLibsLinuxPlugin");
  media_kit_libs_linux_plugin_register_with_registrar(media_kit_libs_linux_registrar);
}
