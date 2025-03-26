//
//  wrapper.c
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 26.03.2025.
//

#include <gvc/gvc.h>

extern gvplugin_library_t gvplugin_dot_layout_LTX_library;
// extern gvplugin_library_t gvplugin_neato_layout_LTX_library;
extern gvplugin_library_t gvplugin_core_LTX_library;

Agdesc_t get_agdirected(void) {
    return Agdirected;
}
