/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at https://graphviz.org
 *************************************************************************/

#include "config.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <cgraph/cgraph.h>     /* for agerr() and friends */
#include <neatogen/delaunay.h>
#include <util/alloc.h>
#include <util/sort.h>

#ifdef HAVE_GTS
#include <gts.h>

static int triangle_is_hole(void *triangle, void *ignored) {
    GtsTriangle *t = triangle;
    (void)ignored;

    GtsEdge *e1, *e2, *e3;
    GtsVertex *v1, *v2, *v3;

    gts_triangle_vertices_edges(t, NULL, &v1, &v2, &v3, &e1, &e2, &e3);

    if ((GTS_IS_CONSTRAINT(e1) && GTS_SEGMENT(e1)->v1 != v1) ||
	(GTS_IS_CONSTRAINT(e2) && GTS_SEGMENT(e2)->v1 != v2) ||
	(GTS_IS_CONSTRAINT(e3) && GTS_SEGMENT(e3)->v1 != v3))
	return TRUE;

    return FALSE;
}

static unsigned delaunay_remove_holes(GtsSurface *surface) {
    return gts_surface_foreach_face_remove(surface, triangle_is_hole, NULL);
}

/* Derived classes for vertices and faces so we can assign integer ids
 * to make it easier to identify them. In particular, this allows the
 * segments and faces to refer to vertices using the order in which
 * they were passed in. 
 */
typedef struct {
    GtsVertex v;
    int idx;
} GVertex;

typedef struct {
    GtsVertexClass parent_class;
} GVertexClass;

static GtsVertexClass *g_vertex_class(void) {
    static GVertexClass *klass = NULL;

    if (klass == NULL) {
	GtsObjectClassInfo vertex_info = {
	    .name = "GVertex",
	    .object_size = sizeof(GVertex),
	    .class_size = sizeof(GVertexClass),
	};
	klass = gts_object_class_new(GTS_OBJECT_CLASS(gts_vertex_class()),
				     &vertex_info);
    }

    return &klass->parent_class;
}

typedef struct {
    GtsFace v;
    int idx;
} GFace;

typedef struct {
    GtsFaceClass parent_class;
} GFaceClass;

static GtsFaceClass *g_face_class(void) {
    static GFaceClass *klass = NULL;

    if (klass == NULL) {
	GtsObjectClassInfo face_info = {
	    .name = "GFace",
	    .object_size = sizeof(GFace),
	    .class_size = sizeof(GFaceClass),
	};
	klass = gts_object_class_new(GTS_OBJECT_CLASS(gts_face_class()),
				     &face_info);
    }

    return &klass->parent_class;
}

/* destroy:
 * Destroy each edge using v, then destroy v
 */
static void
destroy (GtsVertex* v)
{
    GSList * i;

    i = v->segments;
    while (i) {
	GSList * next = i->next;
	gts_object_destroy (i->data);
	i = next;
    }
    g_assert (v->segments == NULL);
    gts_object_destroy(GTS_OBJECT(v));
}

/* tri:
 * Main entry point to using GTS for triangulation.
 * Input is npt points with x and y coordinates stored either separately
 * in x[] and y[] (sepArr != 0) or consecutively in x[] (sepArr == 0).
 * Optionally, the input can include nsegs line segments, whose endpoint
 * indices are supplied in segs[2*i] and segs[2*i+1] yielding a constrained
 * triangulation.
 *
 * The return value is the corresponding gts surface, which can be queries for
 * the triangles and line segments composing the triangulation.
 */
static GtsSurface*
tri(double *x, double *y, int npt, int *segs, int nsegs, int sepArr)
{
    int i;
    GtsSurface *surface;
    GVertex **vertices = gv_calloc(npt, sizeof(GVertex *));
    GtsEdge **edges = gv_calloc(nsegs, sizeof(GtsEdge *));
    GSList *list = NULL;
    GtsVertex *v1, *v2, *v3;
    GtsTriangle *t;
    GtsVertexClass *vcl = g_vertex_class();
    GtsEdgeClass *ecl = GTS_EDGE_CLASS (gts_constraint_class ());

    if (sepArr) {
	for (i = 0; i < npt; i++) {
	    GVertex *p = (GVertex *) gts_vertex_new(vcl, x[i], y[i], 0);
	    p->idx = i;
	    vertices[i] = p;
	}
    }
    else {
	for (i = 0; i < npt; i++) {
	    GVertex *p = (GVertex *) gts_vertex_new(vcl, x[2*i], x[2*i+1], 0);
	    p->idx = i;
	    vertices[i] = p;
	}
    }

    /* N.B. Edges need to be created here, presumably before the
     * the vertices are added to the face. In particular, they cannot
     * be added created and added vi gts_delaunay_add_constraint() below.
     */
    for (i = 0; i < nsegs; i++) {
	edges[i] = gts_edge_new(ecl,
		 (GtsVertex *)vertices[segs[2 * i]],
		 (GtsVertex *)vertices[segs[2 * i + 1]]);
    }

    for (i = 0; i < npt; i++)
	list = g_slist_prepend(list, vertices[i]);
    t = gts_triangle_enclosing(gts_triangle_class(), list, 100.);
    g_slist_free(list);

    gts_triangle_vertices(t, &v1, &v2, &v3);

    surface = gts_surface_new(gts_surface_class(), g_face_class(),
                              gts_edge_class(), gts_vertex_class());
    gts_surface_add_face(surface, gts_face_new(gts_face_class(),
					       t->e1, t->e2, t->e3));

    for (i = 0; i < npt; i++) {
	GtsVertex *v4 = (GtsVertex *)vertices[i];
	GtsVertex *v = gts_delaunay_add_vertex(surface, v4, NULL);

	/* if v != NULL, it is a previously added pt with the same
	 * coordinates as v4, in which case we replace v4 with v
	 */
	if (v && v4 != v) {
	    gts_vertex_replace(v4, v);
	}
    }

    for (i = 0; i < nsegs; i++) {
	gts_delaunay_add_constraint(surface,GTS_CONSTRAINT(edges[i]));
    }

    /* destroy enclosing triangle */
    gts_allow_floating_vertices = TRUE;
    gts_allow_floating_edges = TRUE;
    destroy(v1);
    destroy(v2);
    destroy(v3);
    gts_allow_floating_edges = FALSE;
    gts_allow_floating_vertices = FALSE;

    if (nsegs)
	delaunay_remove_holes(surface);

    free (edges);
    free(vertices);
    return surface;
}

typedef struct {
    int n;
    v_data *delaunay;
} estats;
    
static int cnt_edge(void *edge, void *stats) {
    GtsSegment *e = edge;
    estats *sp = stats;

    sp->n++;
    if (sp->delaunay) {
	sp->delaunay[((GVertex*)e->v1)->idx].nedges++;
	sp->delaunay[((GVertex*)e->v2)->idx].nedges++;
    }

    return 0;
}

static void
edgeStats (GtsSurface* s, estats* sp)
{
    gts_surface_foreach_edge(s, cnt_edge, sp);
}

static int add_edge(void *edge, void *data) {
    GtsSegment *e = edge;
    v_data *delaunay = data;

    int source = ((GVertex*)e->v1)->idx;
    int dest = ((GVertex*)e->v2)->idx;

    delaunay[source].edges[delaunay[source].nedges++] = dest;
    delaunay[dest].edges[delaunay[dest].nedges++] = source;

    return 0;
}

static v_data *delaunay_triangulation(double *x, double *y, int n) {
    GtsSurface* s = tri(x, y, n, NULL, 0, 1);
    int i, nedges;
    estats stats;

    if (!s) return NULL;

    v_data *delaunay = gv_calloc(n, sizeof(v_data));

    for (i = 0; i < n; i++) {
	delaunay[i].ewgts = NULL;
	delaunay[i].nedges = 1;
    }

    stats.n = 0;
    stats.delaunay = delaunay;
    edgeStats (s, &stats);
    nedges = stats.n;
    int *edges = gv_calloc(2 * nedges + n, sizeof(int));

    for (i = 0; i < n; i++) {
	delaunay[i].edges = edges;
	edges += delaunay[i].nedges;
	delaunay[i].edges[0] = i;
	delaunay[i].nedges = 1;
    }
    gts_surface_foreach_edge(s, add_edge, delaunay);

    gts_object_destroy (GTS_OBJECT (s));

    return delaunay;
}

typedef struct {
    int n;
    int* edges;
} estate;

static int addEdge(void *edge, void *state) {
    GtsSegment *e = edge;
    estate *es = state;

    int source = ((GVertex*)e->v1)->idx;
    int dest = ((GVertex*)e->v2)->idx;

    es->edges[2 * es->n] = source;
    es->edges[2 * es->n + 1] = dest;
    es->n += 1;

    return 0;
}

static int vcmp(const void *x, const void *y, void *values) {
    const int *a = x;
    const int *b = y;
    const double *_vals = values;
    double va = _vals[*a];
    double vb = _vals[*b];

    if (va < vb) return -1;
    if (va > vb) return 1;
    return 0;
}

/* delaunay_tri:
 * Given n points whose coordinates are in the x[] and y[]
 * arrays, compute a Delaunay triangulation of the points.
 * The number of edges in the triangulation is returned in pnedges.
 * The return value itself is an array e of 2*(*pnedges) integers,
 * with edge i having points whose indices are e[2*i] and e[2*i+1].
 *
 * If the points are collinear, GTS fails with 0 edges.
 * In this case, we sort the points by x coordinates (or y coordinates
 * if the points form a vertical line). We then return a "triangulation"
 * consisting of the n-1 pairs of adjacent points.
 */
int *delaunay_tri(double *x, double *y, int n, int* pnedges)
{
    GtsSurface* s = tri(x, y, n, NULL, 0, 1);
    int nedges;
    int* edges;
    estats stats;
    estate state;

    if (!s) return NULL;

    stats.n = 0;
    stats.delaunay = NULL;
    edgeStats (s, &stats);
    *pnedges = nedges = stats.n;

    if (nedges) {
	edges = gv_calloc(2 * nedges, sizeof(int));
	state.n = 0;
	state.edges = edges;
	gts_surface_foreach_edge(s, addEdge, &state);
    }
    else {
	int* vs = gv_calloc(n, sizeof(int));
	int* ip;
	int i, hd, tl;

	*pnedges = nedges = n-1;
	ip = edges = gv_calloc(2 * nedges, sizeof(int));

	for (i = 0; i < n; i++)
	    vs[i] = i;

	gv_sort(vs, n, sizeof(int), vcmp, x[0] == x[1] /* vertical line? */ ? y : x);

	tl = vs[0];
	for (i = 1; i < n; i++) {
	    hd = vs[i];
	    *ip++ = tl;
	    *ip++ = hd;
	    tl = hd;
	}

	free (vs);
    }

    gts_object_destroy (GTS_OBJECT (s));

    return edges;
}

static int cntFace(void *face, void *data) {
    GFace *fp = face;
    int *ip = data;

    fp->idx = *ip;
    *ip += 1;

    return 0;
}

typedef struct {
    GtsSurface* s;
    int* faces;
    int* neigh;
} fstate;

typedef struct {
    int nneigh;
    int* neigh;
} ninfo;

static int addNeighbor(void *face, void *ni) {
    GFace *f = face;
    ninfo *es = ni;

    es->neigh[es->nneigh] = f->idx;
    es->nneigh++;

    return 0;
}

static int addFace(void *face, void *state) {
    GFace *f = face;
    fstate *es = state;

    int i, myid = f->idx;
    int* ip = es->faces + 3*myid;
    int* neigh = es->neigh + 3*myid;
    ninfo ni;
    GtsVertex *v1, *v2, *v3;

    gts_triangle_vertices (&f->v.triangle, &v1, &v2, &v3);
    *ip++ = ((GVertex*)v1)->idx;
    *ip++ = ((GVertex*)v2)->idx;
    *ip++ = ((GVertex*)v3)->idx;

    ni.nneigh = 0;
    ni.neigh = neigh;
    gts_face_foreach_neighbor((GtsFace*)f, 0, addNeighbor, &ni);
    for (i = ni.nneigh; i < 3; i++)
	neigh[i] = -1;

    return 0;
}

static int addTri(void *face, void *state) {
    GFace *f = face;
    fstate *es = state;

    int myid = f->idx;
    int* ip = es->faces + 3*myid;
    GtsVertex *v1, *v2, *v3;

    gts_triangle_vertices (&f->v.triangle, &v1, &v2, &v3);
    *ip++ = ((GVertex*)v1)->idx;
    *ip++ = ((GVertex*)v2)->idx;
    *ip++ = ((GVertex*)v3)->idx;

    return 0;
}

/* mkSurface:
 * Given n points whose coordinates are in x[] and y[], and nsegs line
 * segments whose end point indices are given in segs, return a surface
 * corresponding the constrained Delaunay triangulation.
 * The surface records the line segments, the triangles, and the neighboring
 * triangles.
 */
surface_t* 
mkSurface (double *x, double *y, int n, int* segs, int nsegs)
{
    GtsSurface* s = tri(x, y, n, segs, nsegs, 1);
    estats stats;
    estate state;
    fstate statf;
    int nfaces = 0;

    if (!s) return NULL;

    surface_t *sf = gv_alloc(sizeof(surface_t));
    stats.n = 0;
    stats.delaunay = NULL;
    edgeStats (s, &stats);
    nsegs = stats.n;
    segs = gv_calloc(2 * nsegs, sizeof(int));

    state.n = 0;
    state.edges = segs;
    gts_surface_foreach_edge(s, addEdge, &state);

    gts_surface_foreach_face(s, cntFace, &nfaces);

    int *faces = gv_calloc(3 * nfaces, sizeof(int));
    int *neigh = gv_calloc(3 * nfaces, sizeof(int));

    statf.faces = faces;
    statf.neigh = neigh;
    gts_surface_foreach_face(s, addFace, &statf);

    sf->nedges = nsegs;
    sf->edges = segs;
    sf->nfaces = nfaces;
    sf->faces = faces;
    sf->neigh = neigh;

    gts_object_destroy (GTS_OBJECT (s));

    return sf;
}

/* get_triangles:
 * Given n points whose coordinates are stored as (x[2*i],x[2*i+1]),
 * compute a Delaunay triangulation of the points.
 * The number of triangles in the triangulation is returned in tris.
 * The return value t is an array of 3*(*tris) integers,
 * with triangle i having points whose indices are t[3*i], t[3*i+1] and t[3*i+2].
 */
int* 
get_triangles (double *x, int n, int* tris)
{
    GtsSurface* s;
    int nfaces = 0;
    fstate statf;

    if (n <= 2) return NULL;

    s = tri(x, NULL, n, NULL, 0, 0);
    if (!s) return NULL;

    gts_surface_foreach_face(s, cntFace, &nfaces);
    statf.faces = gv_calloc(3 * nfaces, sizeof(int));
    gts_surface_foreach_face(s, addTri, &statf);

    gts_object_destroy (GTS_OBJECT (s));

    *tris = nfaces;
    return statf.faces;
}

void 
freeSurface (surface_t* s)
{
    free (s->edges);
    free (s->faces);
    free (s->neigh);
    free(s);
}
#elif defined(HAVE_TRIANGLE)
#define TRILIBRARY
#include <triangle.c>
#include <assert.h>
#include <sparse/general.h>

int*
get_triangles (double *x, int n, int* tris)
{
    struct triangulateio mid, vorout;
    int i;

    if (n <= 2) return NULL;

    struct triangulateio in = {.numberofpoints = n};
    in.pointlist = gv_calloc(in.numberofpoints * 2, sizeof(REAL));

    for (i = 0; i < n; i++){
	in.pointlist[i*2] = x[i*2];
	in.pointlist[i*2 + 1] = x[i*2 + 1];
    }
    mid.pointlist = NULL; // Not needed if -N switch used.
    mid.pointattributelist = NULL;
    mid.pointmarkerlist = NULL; /* Not needed if -N or -B switch used. */
    mid.trianglelist = NULL; // Not needed if -E switch used.
    mid.triangleattributelist = NULL;
    mid.neighborlist = NULL; // Needed only if -n switch used.
    mid.segmentlist = NULL;
    mid.segmentmarkerlist = NULL;
    mid.edgelist = NULL; // Needed only if -e switch used.
    mid.edgemarkerlist = NULL; // Needed if -e used and -B not used.
    vorout.pointlist = NULL; // Needed only if -v switch used.
    vorout.pointattributelist = NULL;
    vorout.edgelist = NULL; // Needed only if -v switch used.
    vorout.normlist = NULL; // Needed only if -v switch used.

    /* Triangulate the points.  Switches are chosen to read and write a  */
    /*   PSLG (p), preserve the convex hull (c), number everything from  */
    /*   zero (z), assign a regional attribute to each element (A), and  */
    /*   produce an edge list (e), a Voronoi diagram (v), and a triangle */
    /*   neighbor list (n).                                              */

    triangulate("Qenv", &in, &mid, &vorout);
    assert (mid.numberofcorners == 3);

    *tris = mid.numberoftriangles;
    
    free(in.pointlist);
    free(in.pointattributelist);
    free(in.pointmarkerlist);
    free(in.regionlist);
    free(mid.pointlist);
    free(mid.pointattributelist);
    free(mid.pointmarkerlist);
    free(mid.triangleattributelist);
    free(mid.neighborlist);
    free(mid.segmentlist);
    free(mid.segmentmarkerlist);
    free(mid.edgelist);
    free(mid.edgemarkerlist);
    free(vorout.pointlist);
    free(vorout.pointattributelist);
    free(vorout.edgelist);
    free(vorout.normlist);

    return mid.trianglelist;
}

// maybe it should be replaced by RNG - relative neighborhood graph, or by GG - gabriel graph
int* 
delaunay_tri (double *x, double *y, int n, int* nedges)
{
    int i;

    struct triangulateio in = {
	.numberofpoints = n,
	.pointlist = gv_calloc(2 * n, sizeof(REAL))
    };
    for (i = 0; i < n; i++) {
	in.pointlist[2 * i] = x[i];
	in.pointlist[2 * i + 1] = y[i];
    }

    struct triangleio out = {.numberofpoints = n};

    triangulate("zQNEeB", &in, &out, NULL);

    *nedges = out.numberofedges;
    free (in.pointlist);
    free (in.pointattributelist);
    free (in.pointmarkerlist);
    free (in.trianglearealist);
    free (in.triangleattributelist);
    free (in.neighborlist);
    free (in.segmentlist);
    free (in.segmentmarkerlist);
    free (in.holelist);
    free (in.regionlist);
    free (in.edgemarkerlist);
    free (in.normlist);
    free (out.pointattributelist);
    free (out.pointmarkerlist);
    free (out.trianglearealist);
    free (out.triangleattributelist);
    free (out.neighborlist);
    free (out.segmentlist);
    free (out.segmentmarkerlist);
    free (out.holelist);
    free (out.regionlist);
    free (out.edgemarkerlist);
    free (out.normlist);
    return out.edgelist;
}

static v_data *delaunay_triangulation(double *x, double *y, int n) {
    int nedges;
    int source, dest;
    int* edgelist = delaunay_tri (x, y, n, &nedges);
    int i;

    v_data *delaunay = gv_calloc(n, sizeof(v_data));
    int *edges = gv_calloc(2 * nedges + n, sizeof(int));

    for (i = 0; i < n; i++) {
	delaunay[i].ewgts = NULL;
	delaunay[i].nedges = 1;
    }

    for (i = 0; i < 2 * nedges; i++)
	delaunay[edgelist[i]].nedges++;

    for (i = 0; i < n; i++) {
	delaunay[i].edges = edges;
	edges += delaunay[i].nedges;
	delaunay[i].edges[0] = i;
	delaunay[i].nedges = 1;
    }
    for (i = 0; i < nedges; i++) {
	source = edgelist[2 * i];
	dest = edgelist[2 * i + 1];
	delaunay[source].edges[delaunay[source].nedges++] = dest;
	delaunay[dest].edges[delaunay[dest].nedges++] = source;
    }

    free(edgelist);
    return delaunay;
}

surface_t* 
mkSurface (double *x, double *y, int n, int* segs, int nsegs)
{
    agerrorf("mkSurface not yet implemented using Triangle library\n");
    assert (0);
    return 0;
}
void 
freeSurface (surface_t* s)
{
    agerrorf("freeSurface not yet implemented using Triangle library\n");
    assert (0);
}
#else
static char* err = "Graphviz built without any triangulation library\n";
int* get_triangles (double *x, int n, int* tris)
{
    (void)x;
    (void)n;
    (void)tris;

    agerrorf("get_triangles: %s\n", err);
    return 0;
}
static v_data *delaunay_triangulation(double *x, double *y, int n) {
    (void)x;
    (void)y;
    (void)n;

    agerrorf("delaunay_triangulation: %s\n", err);
    return 0;
}
int *delaunay_tri(double *x, double *y, int n, int* nedges)
{
    (void)x;
    (void)y;
    (void)n;
    (void)nedges;

    agerrorf("delaunay_tri: %s\n", err);
    return 0;
}
surface_t* 
mkSurface (double *x, double *y, int n, int* segs, int nsegs)
{
    (void)x;
    (void)y;
    (void)n;
    (void)segs;
    (void)nsegs;

    agerrorf("mkSurface: %s\n", err);
    return 0;
}
void 
freeSurface (surface_t* s)
{
    (void)s;

    agerrorf("freeSurface: %s\n", err);
}
#endif

static void remove_edge(v_data * graph, int source, int dest)
{
    int i;
    for (i = 1; i < graph[source].nedges; i++) {
	if (graph[source].edges[i] == dest) {
	    graph[source].edges[i] = graph[source].edges[--graph[source].nedges];
	    break;
	}
    }
}

v_data *UG_graph(double *x, double *y, int n) {
    v_data *delaunay;
    int i;
    double dist_ij, dist_ik, dist_jk, x_i, y_i, x_j, y_j;
    int j, k, neighbor_j, neighbor_k;

    if (n == 2) {
	int *edges = gv_calloc(4, sizeof(int));
	delaunay = gv_calloc(n, sizeof(v_data));
	delaunay[0].ewgts = NULL;
	delaunay[0].edges = edges;
	delaunay[0].nedges = 2;
	delaunay[0].edges[0] = 0;
	delaunay[0].edges[1] = 1;
	delaunay[1].edges = edges + 2;
	delaunay[1].ewgts = NULL;
	delaunay[1].nedges = 2;
	delaunay[1].edges[0] = 1;
	delaunay[1].edges[1] = 0;
	return delaunay;
    } else if (n == 1) {
	int *edges = gv_calloc(1, sizeof(int));
	delaunay = gv_calloc(n, sizeof(v_data));
	delaunay[0].ewgts = NULL;
	delaunay[0].edges = edges;
	delaunay[0].nedges = 1;
	delaunay[0].edges[0] = 0;
	return delaunay;
    }

    delaunay = delaunay_triangulation(x, y, n);

    // remove all edges v-u if there is w, neighbor of u or v, that is closer to both u and v than dist(u,v)
    for (i = 0; i < n; i++) {
        x_i = x[i];
        y_i = y[i];
        for (j = 1; j < delaunay[i].nedges;) {
            neighbor_j = delaunay[i].edges[j];
            x_j = x[neighbor_j];
            y_j = y[neighbor_j];
            dist_ij = (x_j - x_i) * (x_j - x_i) + (y_j - y_i) * (y_j - y_i);
            // now look at i'th neighbors to see whether there is a node in the "forbidden region"
            // we will also go through neighbor_j's neighbors when we traverse the edge from its other side
            bool removed = false;
            for (k = 1; k < delaunay[i].nedges && !removed; k++) {
                neighbor_k = delaunay[i].edges[k];
                dist_ik = (x[neighbor_k] - x_i) * (x[neighbor_k] - x_i) +
                    (y[neighbor_k] - y_i) * (y[neighbor_k] - y_i);
                if (dist_ik < dist_ij) {
                    dist_jk = (x[neighbor_k] - x_j) * (x[neighbor_k] - x_j) +
                        (y[neighbor_k] - y_j) * (y[neighbor_k] - y_j);
                    if (dist_jk < dist_ij) {
                        // remove the edge beteween i and neighbor j
                        delaunay[i].edges[j] = delaunay[i].edges[--delaunay[i].nedges];
                        remove_edge(delaunay, neighbor_j, i);
                        removed = true;
                    }
                }
            }
            if (!removed) {
                j++;
            }
        }
    }
    return delaunay;
}

void freeGraph (v_data * graph)
{
    if (graph != NULL) {
	free(graph[0].edges);
	free(graph[0].ewgts);
	free(graph);
    }
}

void freeGraphData(vtx_data * graph)
{
    if (graph != NULL) {
	free(graph[0].edges);
	free(graph[0].ewgts);
#ifdef DIGCOLA
	free(graph[0].edists);
#endif
	free(graph);
    }
}

