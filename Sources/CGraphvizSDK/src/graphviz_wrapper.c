//
//  wrapper.c
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 26.03.2025.
//

#include <gvc/gvc.h>
#include <common/types.h>

extern gvplugin_library_t gvplugin_dot_layout_LTX_library;
// extern gvplugin_library_t gvplugin_neato_layout_LTX_library;
extern gvplugin_library_t gvplugin_core_LTX_library;

Agdesc_t get_agdirected(void) {
    return Agdirected;
}

boxf getGraphBoundingBox(Agraph_t *graph) {
    return GD_bb(graph);
}

double getND_width(Agnode_t *n) {
    return ND_width(n);
}

double getND_height(Agnode_t *n) {
    return ND_height(n);
}

pointf getND_coord(Agnode_t *n) {
    return ND_coord(n);
}

shape_desc *getND_shape(Agnode_t *n) {
    return ND_shape(n);
}

void *getND_shape_info(Agnode_t *n) {
    ND_shape_info(n);
}

splines *getED_spl(Agedge_t *e) {
    return ED_spl(e);
}

void *get_shape_info(Agnode_t *n) {
    return ND_shape_info(n);
}

