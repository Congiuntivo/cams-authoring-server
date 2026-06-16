#ifndef FLUTTER_PLUGIN_FLUTTER_SOUND_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_SOUND_PLUGIN_H_

// flutter_sound's Linux plugin names its target and registration function after
// "taudio" rather than "flutter_sound". This shim bridges the mismatch so the
// generated plugin registrant compiles without modification.
#include <taudio/taudio_plugin.h>

static inline void flutter_sound_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  taudio_plugin_register_with_registrar(registrar);
}

#endif  // FLUTTER_PLUGIN_FLUTTER_SOUND_PLUGIN_H_
