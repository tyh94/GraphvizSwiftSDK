/// @file
/// @ingroup public_apis
/// @ingroup common_render
/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at https://graphviz.org
 *************************************************************************/

#pragma once

#include <cdt/cdt.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

    typedef enum { FT_NULL,
	FT_BMP, FT_GIF, FT_PNG, FT_JPEG,
	FT_PDF, FT_PS, FT_EPS, FT_SVG, FT_XML,
	FT_RIFF, FT_WEBP, FT_ICO, FT_TIFF
    } imagetype_t;

    typedef enum {
	IMAGESCALE_FALSE,  /* no image scaling */
	IMAGESCALE_TRUE,   /* scale image to fit but keep aspect ratio */
	IMAGESCALE_WIDTH,  /* scale image width to fit, keep height fixed */
	IMAGESCALE_HEIGHT, /* scale image height to fit, keep width fixed */
	IMAGESCALE_BOTH    /* scale image to fit without regard for aspect ratio */
    } imagescale_t;

    typedef enum {
        IMAGEPOS_TOP_LEFT,      /* top left */
        IMAGEPOS_TOP_CENTER,    /* top center */
        IMAGEPOS_TOP_RIGHT,     /* top right */
        IMAGEPOS_MIDDLE_LEFT,   /* middle left */
        IMAGEPOS_MIDDLE_CENTER, /* middle center (true center, the default)*/
        IMAGEPOS_MIDDLE_RIGHT,  /* middle right */
        IMAGEPOS_BOTTOM_LEFT,   /* bottom left */
        IMAGEPOS_BOTTOM_CENTER, /* bottom center */
        IMAGEPOS_BOTTOM_RIGHT   /* bottom right */
    } imagepos_t;

    typedef struct usershape_s usershape_t;

    struct usershape_s {
	Dtlink_t link;
	const char *name;
	int macro_id;
	bool must_inline;
	bool nocache;
	FILE *f;
	imagetype_t type;
	char *stringtype;
	double x, y, w, h;
	int dpi;
	void *data;                   /* data loaded by a renderer */
	size_t datasize;              /* size of data (if mmap'ed) */
	void (*datafree)(usershape_t *us); /* renderer's function for freeing data */
    };

#ifdef __cplusplus
}
#endif
