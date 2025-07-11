/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at https://graphviz.org
 *************************************************************************/

/*
 *  graphics code generator wrapper
 *
 *  This library forms the socket for run-time loadable render plugins.
 */

#include "config.h"

#include <assert.h>
#include <string.h>
#include <common/const.h>
#include <common/macros.h>
#include <common/colorprocs.h>
#include <gvc/gvplugin_render.h>
#include <cgraph/cgraph.h>
#include <gvc/gvcint.h>
#include <common/geom.h>
#include <common/geomprocs.h>
#include <common/render.h>
#include <gvc/gvcproc.h>
#include <limits.h>
#include <stdlib.h>
#include <util/agxbuf.h>
#include <util/alloc.h>
#include <util/strcasecmp.h>
#include <util/streq.h>

extern bool mapbool(const char *s);

int gvrender_select(GVJ_t * job, const char *str)
{
    GVC_t *gvc = job->gvc;
    gvplugin_available_t *plugin;
    gvplugin_installed_t *typeptr;

    gvplugin_load(gvc, API_device, str, NULL);

    /* When job is created, it is zeroed out.
     * Some flags, such as OUTPUT_NOT_REQUIRED, may already be set,
     * so don't reset.
     */
    /* job->flags = 0; */
    plugin = gvc->api[API_device];
    if (plugin) {
	typeptr = plugin->typeptr;
	job->device.engine = typeptr->engine;
	job->device.features = typeptr->features;
	job->device.id = typeptr->id;
	job->device.type = plugin->typestr;

	job->flags |= job->device.features->flags;
    } else
	return NO_SUPPORT;	/* FIXME - should differentiate problem */

    /* The device plugin has a dependency on a render plugin,
     * so the render plugin should be available as well now */
    plugin = gvc->api[API_render];
    if (plugin) {
	typeptr = plugin->typeptr;
	job->render.engine = typeptr->engine;
	job->render.features = typeptr->features;
	job->render.type = plugin->typestr;

	job->flags |= job->render.features->flags;

	if (job->device.engine)
	    job->render.id = typeptr->id;
	else
	    /* A null device engine indicates that the device id is also the renderer id
	     * and that the renderer doesn't need "device" functions.
	     * Device "features" settings are still available */
	    job->render.id = job->device.id;
	return GVRENDER_PLUGIN;
    }
    job->render.engine = NULL;
    return NO_SUPPORT;		/* FIXME - should differentiate problem */
}

int gvrender_features(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;
    int features = 0;

    if (gvre) {
	features = job->render.features->flags;
    }
    return features;
}

/* gvrender_begin_job:
 * Return 0 on success
 */
int gvrender_begin_job(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvdevice_initialize(job))
	return 1;
    if (gvre) {
	if (gvre->begin_job)
	    gvre->begin_job(job);
    }
    return 0;
}

void gvrender_end_job(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_job)
	    gvre->end_job(job);
    }
    job->gvc->common.lib = NULL;	/* FIXME - minimally this doesn't belong here */
    gvdevice_finalize(job);
}

/* font modifiers */
#define REGULAR 0
#define BOLD    1
#define ITALIC  2

pointf gvrender_ptf(GVJ_t * job, pointf p)
{
    pointf rv, translation, scale;

    translation = job->translation;
    scale.x = job->zoom * job->devscale.x;
    scale.y = job->zoom * job->devscale.y;

    if (job->rotation) {
	rv.x = -(p.y + translation.y) * scale.x;
	rv.y = (p.x + translation.x) * scale.y;
    } else {
	rv.x = (p.x + translation.x) * scale.x;
	rv.y = (p.y + translation.y) * scale.y;
    }
    return rv;
}

/* transform an array of n points */
/*  *AF and *af must be preallocated */
/*  *AF can be the same as *af for inplace transforms */
pointf *gvrender_ptf_A(GVJ_t *job, pointf *af, pointf *AF, size_t n) {
    double t;
    pointf translation, scale;

    translation = job->translation;
    scale.x = job->zoom * job->devscale.x;
    scale.y = job->zoom * job->devscale.y;

    if (job->rotation) {
	for (size_t i = 0; i < n; i++) {
	    t = -(af[i].y + translation.y) * scale.x;
	    AF[i].y = (af[i].x + translation.x) * scale.y;
	    AF[i].x = t;
	}
    } else {
	for (size_t i = 0; i < n; i++) {
	    AF[i].x = (af[i].x + translation.x) * scale.x;
	    AF[i].y = (af[i].y + translation.y) * scale.y;
	}
    }
    return AF;
}

static int gvrender_comparestr(const void *s1, const void *s2)
{
  return strcasecmp(s1, *(char *const *)s2);
}

/* gvrender_resolve_color:
 * N.B. strcasecmp cannot be used in bsearch, as it will pass a pointer
 * to an element in the array features->knowncolors (i.e., a char**)
 * as an argument of the compare function, while the arguments to 
 * strcasecmp are both char*.
 */
static void gvrender_resolve_color(gvrender_features_t * features,
				   char *name, gvcolor_t * color)
{
    int rc;

    color->u.string = name;
    color->type = COLOR_STRING;
    if (!features->knowncolors
	||
	(bsearch(name, features->knowncolors, features->sz_knowncolors,
	  sizeof(char *), gvrender_comparestr)) == NULL) {
	/* if name was not found in known_colors */
	rc = colorxlate(name, color, features->color_type);
	if (rc != COLOR_OK) {
	    if (rc == COLOR_UNKNOWN) {
		agxbuf missedcolor = {0};
		agxbprint(&missedcolor, "color %s", name);
		if (emit_once(agxbuse(&missedcolor)))
		    agwarningf("%s is not a known color.\n", name);
		agxbfree(&missedcolor);
	    } else {
		agerrorf("error in colorxlate()\n");
	    }
	}
    }
}

void gvrender_begin_graph(GVJ_t *job) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	/* render specific init */
	if (gvre->begin_graph)
	    gvre->begin_graph(job);
    }
}

void gvrender_end_graph(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_graph)
	    gvre->end_graph(job);
    }
    gvdevice_format(job);
}

void gvrender_begin_page(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_page)
	    gvre->begin_page(job);
    }
}

void gvrender_end_page(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_page)
	    gvre->end_page(job);
    }
}

void gvrender_begin_layer(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_layer)
	    gvre->begin_layer(job, job->gvc->layerIDs[job->layerNum],
			      job->layerNum, job->numLayers);
    }
}

void gvrender_end_layer(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_layer)
	    gvre->end_layer(job);
    }
}

void gvrender_begin_cluster(GVJ_t *job) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_cluster)
	    gvre->begin_cluster(job);
    }
}

void gvrender_end_cluster(GVJ_t *job) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_cluster)
	    gvre->end_cluster(job);
    }
}

void gvrender_begin_nodes(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_nodes)
	    gvre->begin_nodes(job);
    }
}

void gvrender_end_nodes(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_nodes)
	    gvre->end_nodes(job);
    }
}

void gvrender_begin_edges(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_edges)
	    gvre->begin_edges(job);
    }
}

void gvrender_end_edges(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_edges)
	    gvre->end_edges(job);
    }
}

void gvrender_begin_node(GVJ_t *job) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_node)
	    gvre->begin_node(job);
    }
}

void gvrender_end_node(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_node)
	    gvre->end_node(job);
    }
}

void gvrender_begin_edge(GVJ_t *job) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_edge)
	    gvre->begin_edge(job);
    }
}

void gvrender_end_edge(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_edge)
	    gvre->end_edge(job);
    }
}

void gvrender_begin_anchor(GVJ_t * job, char *href, char *tooltip,
			   char *target, char *id)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_anchor)
	    gvre->begin_anchor(job, href, tooltip, target, id);
    }
}

void gvrender_end_anchor(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_anchor)
	    gvre->end_anchor(job);
    }
}

void gvrender_begin_label(GVJ_t * job, label_type type)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->begin_label)
	    gvre->begin_label(job, type);
    }
}

void gvrender_end_label(GVJ_t * job)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->end_label)
	    gvre->end_label(job);
    }
}

void gvrender_textspan(GVJ_t * job, pointf p, textspan_t * span)
{
    gvrender_engine_t *gvre = job->render.engine;
    pointf PF;

    if (span->str && span->str[0]
	&& (!job->obj		/* because of xdgen non-conformity */
	    || job->obj->pen != PEN_NONE)) {
	if (job->flags & GVRENDER_DOES_TRANSFORM)
	    PF = p;
	else
	    PF = gvrender_ptf(job, p);
	if (gvre) {
	    if (gvre->textspan)
		gvre->textspan(job, PF, span);
	}
    }
}

void gvrender_set_pencolor(GVJ_t * job, char *name)
{
    gvrender_engine_t *gvre = job->render.engine;
    gvcolor_t *color = &(job->obj->pencolor);
    char *cp = NULL;

    if ((cp = strchr(name, ':'))) // if it’s a color list, then use only first
	*cp = '\0';
    if (gvre) {
	gvrender_resolve_color(job->render.features, name, color);
	if (gvre->resolve_color)
	    gvre->resolve_color(job, color);
    }
    if (cp)			/* restore color list */
	*cp = ':';
}

void gvrender_set_fillcolor(GVJ_t * job, char *name)
{
    gvrender_engine_t *gvre = job->render.engine;
    gvcolor_t *color = &(job->obj->fillcolor);
    char *cp = NULL;

    if ((cp = strchr(name, ':'))) // if it’s a color list, then use only first
	*cp = '\0';
    if (gvre) {
	gvrender_resolve_color(job->render.features, name, color);
	if (gvre->resolve_color)
	    gvre->resolve_color(job, color);
    }
    if (cp)
	*cp = ':';
}

void gvrender_set_gradient_vals(GVJ_t *job, char *stopcolor, int angle,
                                double frac) {
    gvrender_engine_t *gvre = job->render.engine;
    gvcolor_t *color = &(job->obj->stopcolor);

    if (gvre) {
	gvrender_resolve_color(job->render.features, stopcolor, color);
	if (gvre->resolve_color)
	    gvre->resolve_color(job, color);
    }
    job->obj->gradient_angle = angle;
    job->obj->gradient_frac = frac;
}

void gvrender_set_style(GVJ_t * job, char **s)
{
    gvrender_engine_t *gvre = job->render.engine;
    obj_state_t *obj = job->obj;
    char *line, *p;

    obj->rawstyle = s;
    if (gvre) {
	if (s)
	    while ((p = line = *s++)) {
		if (streq(line, "solid"))
		    obj->pen = PEN_SOLID;
		else if (streq(line, "dashed"))
		    obj->pen = PEN_DASHED;
		else if (streq(line, "dotted"))
		    obj->pen = PEN_DOTTED;
		else if (streq(line, "invis") || streq(line, "invisible"))
		    obj->pen = PEN_NONE;
		else if (streq(line, "bold"))
		    obj->penwidth = PENWIDTH_BOLD;
		else if (streq(line, "setlinewidth")) {
		    while (*p)
			p++;
		    p++;
		    obj->penwidth = atof(p);
		} else if (streq(line, "filled"))
		    obj->fill = FILL_SOLID;
		else if (streq(line, "unfilled"))
		    obj->fill = FILL_NONE;
		else if (streq(line, "tapered"));
		else {
		    agwarningf(
			  "gvrender_set_style: unsupported style %s - ignoring\n",
			  line);
		}
	    }
    }
}

void gvrender_ellipse(GVJ_t *job, pointf *pf, int filled) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->ellipse && job->obj->pen != PEN_NONE) {
	    pointf af[] = {
		mid_pointf(pf[0], pf[1]), // center
		pf[1] // corner
	    };

	    if (!(job->flags & GVRENDER_DOES_TRANSFORM))
		gvrender_ptf_A(job, af, af, 2);
	    gvre->ellipse(job, af, filled);
	}
    }
}

void gvrender_polygon(GVJ_t *job, pointf *af, size_t n, int filled) {
    int noPoly = 0;
    gvcolor_t save_pencolor;

    gvrender_engine_t *gvre = job->render.engine;
    if (gvre) {
	if (gvre->polygon && job->obj->pen != PEN_NONE) {
	    if (filled & NO_POLY) {
		noPoly = 1;
		filled &= ~NO_POLY;
		save_pencolor = job->obj->pencolor;
		job->obj->pencolor = job->obj->fillcolor;
	    }
	    if (job->flags & GVRENDER_DOES_TRANSFORM)
		gvre->polygon(job, af, n, filled);
	    else {
		pointf *AF = gv_calloc(n, sizeof(pointf));
		gvrender_ptf_A(job, af, AF, n);
		gvre->polygon(job, AF, n, filled);
		free(AF);
	    }
	    if (noPoly)
		job->obj->pencolor = save_pencolor;
	}
    }
}


void gvrender_box(GVJ_t * job, boxf B, int filled)
{
    pointf A[4];

    A[0] = B.LL;
    A[2] = B.UR;
    A[1].x = A[0].x;
    A[1].y = A[2].y;
    A[3].x = A[2].x;
    A[3].y = A[0].y;

    gvrender_polygon(job, A, 4, filled);
}

void gvrender_beziercurve(GVJ_t *job, pointf *af, size_t n, int filled) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->beziercurve && job->obj->pen != PEN_NONE) {
	    if (job->flags & GVRENDER_DOES_TRANSFORM)
		gvre->beziercurve(job, af, n, filled);
	    else {
		pointf *AF = gv_calloc(n, sizeof(pointf));
		gvrender_ptf_A(job, af, AF, n);
		gvre->beziercurve(job, AF, n, filled);
		free(AF);
	    }
	}
    }
}

void gvrender_polyline(GVJ_t *job, pointf *af, size_t n) {
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	if (gvre->polyline && job->obj->pen != PEN_NONE) {
	    if (job->flags & GVRENDER_DOES_TRANSFORM)
		gvre->polyline(job, af, n);
	    else {
		pointf *AF = gv_calloc(n, sizeof(pointf));
		gvrender_ptf_A(job, af, AF, n);
		gvre->polyline(job, AF, n);
		free(AF);
	    }
	}
    }
}

void gvrender_comment(GVJ_t * job, char *str)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (!str || !str[0])
	return;

    if (gvre) {
	if (gvre->comment)
	    gvre->comment(job, str);
    }
}

static imagescale_t get_imagescale(char *s)
{
    if (*s == '\0')
	return IMAGESCALE_FALSE;
    if (!strcasecmp(s, "width"))
	return IMAGESCALE_WIDTH;
    if (!strcasecmp(s, "height"))
	return IMAGESCALE_HEIGHT;
    if (!strcasecmp(s, "both"))
	return IMAGESCALE_BOTH;
    if (mapbool(s))
	return IMAGESCALE_TRUE;
    return IMAGESCALE_FALSE;
}

static imagepos_t get_imagepos(char *s)
{
    if (*s == '\0')
	return IMAGEPOS_MIDDLE_CENTER;
    if (!strcasecmp(s, "tl"))
	return IMAGEPOS_TOP_LEFT;
    if (!strcasecmp(s, "tc"))
	return IMAGEPOS_TOP_CENTER;
    if (!strcasecmp(s, "tr"))
	return IMAGEPOS_TOP_RIGHT;
    if (!strcasecmp(s, "ml"))
	return IMAGEPOS_MIDDLE_LEFT;
    if (!strcasecmp(s, "mc"))
	return IMAGEPOS_MIDDLE_CENTER;
    if (!strcasecmp(s, "mr"))
	return IMAGEPOS_MIDDLE_RIGHT;
    if (!strcasecmp(s, "bl"))
	return IMAGEPOS_BOTTOM_LEFT;
    if (!strcasecmp(s, "bc"))
	return IMAGEPOS_BOTTOM_CENTER;
    if (!strcasecmp(s, "br"))
	return IMAGEPOS_BOTTOM_RIGHT;
    return IMAGEPOS_MIDDLE_CENTER;
}

/* gvrender_usershape:
 * Scale image to fill polygon bounding box according to "imagescale",
 * positioned at "imagepos"
 */
void gvrender_usershape(GVJ_t *job, char *name, pointf *a, size_t n,
                        bool filled, char *imagescale, char *imagepos) {
    gvrender_engine_t *gvre = job->render.engine;
    usershape_t *us;
    double iw, ih, pw, ph;
    double scalex, scaley;	/* scale factors */
    boxf b;			/* target box */
    point isz;
    imagepos_t position;

    assert(job);
    assert(name);
    assert(name[0]);

    if (!(us = gvusershape_find(name))) {
	if (find_user_shape(name)) {
	    if (gvre && gvre->library_shape)
		gvre->library_shape(job, name, a, n, filled);
	}
	return;
    }

    isz = gvusershape_size_dpi(us, job->dpi);
    if ((isz.x <= 0) && (isz.y <= 0))
	return;

    /* compute bb of polygon */
    b.LL = b.UR = a[0];
    for (size_t i = 1; i < n; i++) {
	expandbp(&b, a[i]);
    }

    pw = b.UR.x - b.LL.x;
    ph = b.UR.y - b.LL.y;
    ih = (double) isz.y;
    iw = (double) isz.x;

    scalex = pw / iw;
    scaley = ph / ih;

    switch (get_imagescale(imagescale)) {
    case IMAGESCALE_TRUE:
	/* keep aspect ratio fixed by just using the smaller scale */
	if (scalex < scaley) {
	    iw *= scalex;
	    ih *= scalex;
	} else {
	    iw *= scaley;
	    ih *= scaley;
	}
	break;
    case IMAGESCALE_WIDTH:
	iw *= scalex;
	break;
    case IMAGESCALE_HEIGHT:
	ih *= scaley;
	break;
    case IMAGESCALE_BOTH:
	iw *= scalex;
	ih *= scaley;
	break;
    case IMAGESCALE_FALSE:
    default:
	break;
    }

    /* if image is smaller in any dimension, apply the specified positioning */
    position = get_imagepos(imagepos);
    if (iw < pw) {
        switch (position) {
        case IMAGEPOS_TOP_LEFT:
        case IMAGEPOS_MIDDLE_LEFT:
        case IMAGEPOS_BOTTOM_LEFT:
            b.UR.x = b.LL.x + iw;
            break;
        case IMAGEPOS_TOP_RIGHT:
        case IMAGEPOS_MIDDLE_RIGHT:
        case IMAGEPOS_BOTTOM_RIGHT:
            b.LL.x += (pw - iw);
            b.UR.x = b.LL.x + iw;
            break;
        default:
            b.LL.x += (pw - iw) / 2.0;
            b.UR.x -= (pw - iw) / 2.0;
            break;
        }
    }
    if (ih < ph) {
        switch (position) {
        case IMAGEPOS_TOP_LEFT:
        case IMAGEPOS_TOP_CENTER:
        case IMAGEPOS_TOP_RIGHT:
            b.LL.y = b.UR.y - ih;
            break;
        case IMAGEPOS_BOTTOM_LEFT:
        case IMAGEPOS_BOTTOM_CENTER:
        case IMAGEPOS_BOTTOM_RIGHT:
            b.LL.y += ih;
            b.UR.y = b.LL.y - ih;
            break;
        default:
            b.LL.y += (ph - ih) / 2.0;
            b.UR.y -= (ph - ih) / 2.0;
            break;
        }
    }

    /* convert from graph to device coordinates */
    if (!(job->flags & GVRENDER_DOES_TRANSFORM)) {
	b.LL = gvrender_ptf(job, b.LL);
	b.UR = gvrender_ptf(job, b.UR);
    }

    if (b.LL.x > b.UR.x) {
	double d = b.LL.x;
	b.LL.x = b.UR.x;
	b.UR.x = d;
    }
    if (b.LL.y > b.UR.y) {
	double d = b.LL.y;
	b.LL.y = b.UR.y;
	b.UR.y = d;
    }
    if (gvre) {
	gvloadimage(job, us, b, filled, job->render.type);
    }
}

void gvrender_set_penwidth(GVJ_t * job, double penwidth)
{
    gvrender_engine_t *gvre = job->render.engine;

    if (gvre) {
	job->obj->penwidth = penwidth;
    }
}
