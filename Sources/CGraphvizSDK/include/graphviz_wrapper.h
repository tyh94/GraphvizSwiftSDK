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
#include <dotgen/dotprocs.h>

extern gvplugin_library_t gvplugin_dot_layout_LTX_library;
extern gvplugin_library_t gvplugin_core_LTX_library;

GVC_t * loadGraphvizLibraries(void) ;

///NODES
pointf nd_coord(Agnode_t* n);
double nd_width(Agnode_t* n);
double nd_height(Agnode_t* n);
char *nd_label_text(Agnode_t* n);
void *nd_shape_info(Agnode_t *n);
shape_desc *nd_shape(Agnode_t *n);

///EDGES
short ed_count(Agedge_t* e);
textlabel_t* ed_label(Agedge_t* e);
textlabel_t* ed_head_label(Agedge_t* e);
textlabel_t* ed_tail_label(Agedge_t* e);
double ed_label_fontsize(Agedge_t* e);
double ed_headlabel_fontsize(Agedge_t* e);
double ed_taillabel_fontsize(Agedge_t* e);
pointf* ed_lp(Agedge_t* n);
pointf* ed_head_lp(Agedge_t* n);
pointf* ed_tail_lp(Agedge_t* n);
pointf* ed_xlp(Agedge_t* e);
pointf ed_headPort_pos(Agedge_t* e);
pointf ed_tailPort_pos(Agedge_t* e);
char* ed_label_text(Agedge_t* e);
char* ed_head_label_text(Agedge_t* e);
char* ed_tail_label_text(Agedge_t* e);
splines *ed_spl(Agedge_t *e);

///GRAPHS
boxf gd_bb(Agraph_t* g);
textlabel_t* gd_label(Agraph_t* g);
pointf* gd_lp(Agraph_t* g);
pointf* gd_lsize(Agraph_t* g);
char* gd_label_text(Agraph_t* g);

#endif /* Header_h */
