//
//  Header.h
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 26.03.2025.
//

#ifndef Header_h
#define Header_h

#include <cgraph/cgraph.h>
#include <gvc/gvcext.h>
#include <gvc/gvplugin.h>
#include <gvc/gvc.h>
#include <gvc/gvcint.h>
#include <common/geom.h>
#include <common/types.h>

Agdesc_t get_agdirected(void);

extern gvplugin_library_t gvplugin_dot_layout_LTX_library;
extern gvplugin_library_t gvplugin_core_LTX_library;

boxf getGraphBoundingBox(Agraph_t *graph);
double getND_width(Agnode_t *n);
double getND_height(Agnode_t *n);
pointf getND_coord(Agnode_t *n);
shape_desc *getND_shape(Agnode_t *n);
void *getND_shape_info(Agnode_t *n);
splines *getED_spl(Agedge_t *e);

void *get_shape_info(Agnode_t *n);

#endif /* Header_h */
