/**
 * @file
 * @brief implementation of dynamic attributes
 * @ingroup cgraph_attr
 * @ingroup cgraph_core
 */
 /*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at https://graphviz.org
 *************************************************************************/

#include	<cgraph/cghdr.h>
#include	<stdbool.h>
#include	<stdlib.h>
#include	<util/alloc.h>
#include	<util/streq.h>
#include	<util/unreachable.h>

/*
 * dynamic attributes
 */

/* to create a graph's data dictionary */

#define MINATTR	4		/* minimum allocation */

static void freesym(void *obj);

Dtdisc_t AgDataDictDisc = {
    (int) offsetof(Agsym_t, name),	/* use symbol name as key */
    -1,
    (int) offsetof(Agsym_t, link),
    NULL,
    freesym,
    NULL,
};

static char DataDictName[] = "_AG_datadict";
static void init_all_attrs(Agraph_t * g);
static Agdesc_t ProtoDesc = {.directed = true, .no_loop = true,
                             .no_write = true};
static Agraph_t *ProtoGraph;

Agdatadict_t *agdatadict(Agraph_t *g, bool cflag) {
    Agdatadict_t *rv = (Agdatadict_t *) aggetrec(g, DataDictName, 0);
    if (rv || !cflag)
	return rv;
    init_all_attrs(g);
    rv = (Agdatadict_t *) aggetrec(g, DataDictName, 0);
    return rv;
}

static Dict_t *agdictof(Agraph_t * g, int kind)
{
    Agdatadict_t *dd;
    Dict_t *dict;

    dd = agdatadict(g, false);
    if (dd)
	switch (kind) {
	case AGRAPH:
	    dict = dd->dict.g;
	    break;
	case AGNODE:
	    dict = dd->dict.n;
	    break;
	case AGINEDGE:
	case AGOUTEDGE:
	    dict = dd->dict.e;
	    break;
	default:
	    agerrorf("agdictof: unknown kind %d\n", kind);
	    dict = NULL;
	    break;
    } else
	dict = NULL;
    return dict;
}

/// @param is_html Is `value` an HTML-like string?
static Agsym_t *agnewsym(Agraph_t * g, const char *name, const char *value,
                         bool is_html, int id, int kind) {
    Agsym_t *sym = gv_alloc(sizeof(Agsym_t));
    sym->kind = (unsigned char) kind;
    sym->name = agstrdup(g, name);
    sym->defval = is_html ? agstrdup_html(g, value) : agstrdup(g, value);
    sym->id = id;
    return sym;
}

static void agcopydict(Dict_t * src, Dict_t * dest, Agraph_t * g, int kind)
{
    Agsym_t *sym, *newsym;

    assert(dtsize(dest) == 0);
    for (sym = dtfirst(src); sym; sym = dtnext(src, sym)) {
	const bool is_html = aghtmlstr(sym->defval);
	newsym = agnewsym(g, sym->name, sym->defval, is_html, sym->id, kind);
	newsym->print = sym->print;
	newsym->fixed = sym->fixed;
	dtinsert(dest, newsym);
    }
}

static Agdatadict_t *agmakedatadict(Agraph_t * g)
{
    Agraph_t *par;
    Agdatadict_t *parent_dd, *dd;

    dd = agbindrec(g, DataDictName, sizeof(Agdatadict_t), false);
    dd->dict.n = agdtopen(&AgDataDictDisc, Dttree);
    dd->dict.e = agdtopen(&AgDataDictDisc, Dttree);
    dd->dict.g = agdtopen(&AgDataDictDisc, Dttree);
    if ((par = agparent(g))) {
	parent_dd = agdatadict(par, false);
	assert(dd != parent_dd);
	dtview(dd->dict.n, parent_dd->dict.n);
	dtview(dd->dict.e, parent_dd->dict.e);
	dtview(dd->dict.g, parent_dd->dict.g);
    } else {
	if (ProtoGraph && g != ProtoGraph) {
	    /* it's not ok to dtview here for several reasons. the proto
	       graph could change, and the sym indices don't match */
	    parent_dd = agdatadict(ProtoGraph, false);
	    agcopydict(parent_dd->dict.n, dd->dict.n, g, AGNODE);
	    agcopydict(parent_dd->dict.e, dd->dict.e, g, AGEDGE);
	    agcopydict(parent_dd->dict.g, dd->dict.g, g, AGRAPH);
	}
    }
    return dd;
}

/* look up an attribute with possible viewpathing */
static Agsym_t *agdictsym(Dict_t * dict, char *name)
{
    Agsym_t key;
    key.name = name;
    return dtsearch(dict, &key);
}

/* look up attribute in local dictionary with no view pathing */
static Agsym_t *aglocaldictsym(Dict_t * dict, char *name)
{
    Agsym_t *rv;
    Dict_t *view;

    view = dtview(dict, NULL);
    rv = agdictsym(dict, name);
    dtview(dict, view);
    return rv;
}

Agsym_t *agattrsym(void *obj, char *name)
{
    Agattr_t *data;
    Agsym_t *rv;

    data = agattrrec(obj);
    if (data)
	rv = agdictsym(data->dict, name);
    else
	rv = NULL;
    return rv;
}

/* to create a graph's, node's edge's string attributes */

char *AgDataRecName = "_AG_strdata";

static int topdictsize(Agobj_t * obj)
{
    Dict_t *d;

    d = agdictof(agroot(agraphof(obj)), AGTYPE(obj));
    return d ? dtsize(d) : 0;
}

/* g can be either the enclosing graph, or ProtoGraph */
static Agrec_t *agmakeattrs(Agraph_t * context, void *obj)
{
    int sz;
    Agattr_t *rec;
    Agsym_t *sym;
    Dict_t *datadict;

    rec = agbindrec(obj, AgDataRecName, sizeof(Agattr_t), false);
    datadict = agdictof(context, AGTYPE(obj));
    assert(datadict);
    if (rec->dict == NULL) {
	rec->dict = agdictof(agroot(context), AGTYPE(obj));
	/* don't malloc(0) */
	sz = topdictsize(obj);
	if (sz < MINATTR)
	    sz = MINATTR;
	rec->str = gv_calloc((size_t)sz, sizeof(char *));
	/* doesn't call agxset() so no obj-modified callbacks occur */
	for (sym = dtfirst(datadict); sym; sym = dtnext(datadict, sym)) {
	    if (aghtmlstr(sym->defval)) {
	        rec->str[sym->id] = agstrdup_html(agraphof(obj), sym->defval);
	    } else {
	        rec->str[sym->id] = agstrdup(agraphof(obj), sym->defval);
	    }
	}
    } else {
	assert(rec->dict == datadict);
    }
    return (Agrec_t *) rec;
}

static void freeattr(Agobj_t * obj, Agattr_t * attr)
{
    int i, sz;
    Agraph_t *g;

    g = agraphof(obj);
    sz = topdictsize(obj);
    for (i = 0; i < sz; i++)
	agstrfree(g, attr->str[i], aghtmlstr(attr->str[i]));
    free(attr->str);
}

static void freesym(void *obj) {
    Agsym_t *sym;

    sym = obj;
    agstrfree(Ag_G_global, sym->name, false);
    agstrfree(Ag_G_global, sym->defval, aghtmlstr(sym->defval));
    free(sym);
}

Agattr_t *agattrrec(void *obj)
{
  return (Agattr_t *)aggetrec(obj, AgDataRecName, 0);
}


static void addattr(Agraph_t * g, Agobj_t * obj, Agsym_t * sym)
{
    Agattr_t *attr = agattrrec(obj);
    assert(attr != NULL);
    if (sym->id >= MINATTR)
	attr->str = gv_recalloc(attr->str, (size_t)sym->id, (size_t)sym->id + 1,
	                        sizeof(char *));
    if (aghtmlstr(sym->defval)) {
	attr->str[sym->id] = agstrdup_html(g, sym->defval);
    } else {
	attr->str[sym->id] = agstrdup(g, sym->defval);
    }
}

static Agsym_t *getattr(Agraph_t *g, int kind, char *name) {
  Agsym_t *rv = 0;
  Dict_t *dict;
  dict = agdictof(g, kind);
  if (dict) {
    rv = agdictsym(dict, name); // viewpath up to root
  }
  return rv;
}

static void unviewsubgraphsattr(Agraph_t *parent, char *name) {
  Agraph_t *subg;
  Agsym_t *psym, *lsym;
  Dict_t *ldict;

  psym = getattr(parent, AGRAPH, name);
  if (!psym) {
    return; // supposedly can't happen, see setattr()
  }
  for (subg = agfstsubg(parent); subg; subg = agnxtsubg(subg)) {
    ldict = agdatadict(subg, true)->dict.g;
    lsym = aglocaldictsym(ldict, name);
    if (lsym) {
      continue;
    }
    char *const value = agxget(subg, psym);
    const bool is_html = aghtmlstr(value);
    lsym = agnewsym(agroot(subg), name, value, is_html, psym->id, AGRAPH);
    dtinsert(ldict, lsym);
  }
}

static int agxset_(void *obj, Agsym_t *sym, const char *value, bool is_html);

/// @param is_html Is `value` an HTML-like string?
static Agsym_t *setattr(Agraph_t * g, int kind, char *name, const char *value,
                        bool is_html) {
    Agsym_t *rv;

    assert(value);
    Agraph_t *root = agroot(g);
    agdatadict(g, true);	/* force initialization of string attributes */
    Dict_t *ldict = agdictof(g, kind);
    Agsym_t *lsym = aglocaldictsym(ldict, name);
    if (lsym) {			/* update old local definition */
	if (g != root && streq(name, "layout"))
	    agwarningf("layout attribute is invalid except on the root graph\n");
        if (kind == AGRAPH) {
	    unviewsubgraphsattr(g,name);
        }
	agstrfree(g, lsym->defval, aghtmlstr(lsym->defval));
	lsym->defval = is_html ? agstrdup_html(g, value) : agstrdup(g, value);
	rv = lsym;
    } else {
	Agsym_t *psym = agdictsym(ldict, name); // search with viewpath up to root
	if (psym) {		/* new local definition */
	    lsym = agnewsym(g, name, value, is_html, psym->id, kind);
	    dtinsert(ldict, lsym);
	    rv = lsym;
	} else {		/* new global definition */
	    Dict_t *rdict = agdictof(root, kind);
	    Agsym_t *rsym = agnewsym(g, name, value, is_html, dtsize(rdict), kind);
	    dtinsert(rdict, rsym);
	    switch (kind) {
	    case AGRAPH:
		agapply(root, &root->base, (agobjfn_t)addattr, rsym, true);
		break;
	    case AGNODE:
		for (Agnode_t *n = agfstnode(root); n; n = agnxtnode(root, n))
		    addattr(g, &n->base, rsym);
		break;
	    case AGINEDGE:
	    case AGOUTEDGE:
		for (Agnode_t *n = agfstnode(root); n; n = agnxtnode(root, n))
		    for (Agedge_t *e = agfstout(root, n); e; e = agnxtout(root, e))
			addattr(g, &e->base, rsym);
		break;
	    default:
		UNREACHABLE();
	    }
	    rv = rsym;
	}
    }
    if (rv && kind == AGRAPH)
	agxset_(g, rv, value, is_html);
    agmethod_upd(g, g, rv);
    return rv;
}

/*
 * create or update an existing attribute and return its descriptor.
 * if the new value is NULL, this is only a search, no update.
 * when a new attribute is created, existing graphs/nodes/edges
 * receive its default value.
 */
static Agsym_t *agattr_(Agraph_t *g, int kind, char *name, const char *value,
                 bool is_html) {
    Agsym_t *rv;

    if (g == 0) {
	if (ProtoGraph == 0)
	    ProtoGraph = agopen(0, ProtoDesc, 0);
	g = ProtoGraph;
    }
    if (value)
	rv = setattr(g, kind, name, value, is_html);
    else
	rv = getattr(g, kind, name);
    return rv;
}

Agsym_t *agattr(Agraph_t *g, int kind, char *name, const char *value) {
  return agattr_(g, kind, name, value, false);
}

Agsym_t *agattr_html(Agraph_t *g, int kind, char *name, const char *value) {
  return agattr_(g, kind, name, value, true);
}

Agsym_t *agnxtattr(Agraph_t * g, int kind, Agsym_t * attr)
{
    Dict_t *d;
    Agsym_t *rv;

    if ((d = agdictof(g, kind))) {
	if (attr)
	    rv = dtnext(d, attr);
	else
	    rv = dtfirst(d);
    } else
	rv = 0;
    return rv;
}

/* Create or delete attributes associated with an object */

void agraphattr_init(Agraph_t * g)
{
    Agraph_t *context;

    g->desc.has_attrs = true;
    agmakedatadict(g);
    if (!(context = agparent(g)))
	context = g;
    agmakeattrs(context, g);
}

int agraphattr_delete(Agraph_t * g)
{
    Agdatadict_t *dd;
    Agattr_t *attr;

    Ag_G_global = g;
    if ((attr = agattrrec(g))) {
	freeattr(&g->base, attr);
	agdelrec(g, attr->h.name);
    }

    if ((dd = agdatadict(g, false))) {
	if (agdtclose(g, dd->dict.n)) return 1;
	if (agdtclose(g, dd->dict.e)) return 1;
	if (agdtclose(g, dd->dict.g)) return 1;
	agdelrec(g, dd->h.name);
    }
    return 0;
}

void agnodeattr_init(Agraph_t * g, Agnode_t * n)
{
    Agattr_t *data;

    data = agattrrec(n);
    if (!data || !data->dict)
	(void) agmakeattrs(g, n);
}

void agnodeattr_delete(Agnode_t * n)
{
    Agattr_t *rec;

    if ((rec = agattrrec(n))) {
	freeattr(&n->base, rec);
	agdelrec(n, AgDataRecName);
    }
}

void agedgeattr_init(Agraph_t * g, Agedge_t * e)
{
    Agattr_t *data;

    data = agattrrec(e);
    if (!data || !data->dict)
	(void) agmakeattrs(g, e);
}

void agedgeattr_delete(Agedge_t * e)
{
    Agattr_t *rec;

    if ((rec = agattrrec(e))) {
	freeattr(&e->base, rec);
	agdelrec(e, AgDataRecName);
    }
}

char *agget(void *obj, char *name)
{
    Agsym_t *const sym = agattrsym(obj, name);
    if (sym == NULL) {
	return NULL; // note was "", but this provides more info
    }
    Agattr_t *const data = agattrrec(obj);
    return data->str[sym->id];
}

char *agxget(void *obj, Agsym_t * sym)
{
    Agattr_t *const data = agattrrec(obj);
    assert(sym->id >= 0 && sym->id < topdictsize(obj));
    return data->str[sym->id];
}

int agset(void *obj, char *name, const char *value) {
    Agsym_t *sym;
    int rv;

    sym = agattrsym(obj, name);
    if (sym == NULL)
	rv = FAILURE;
    else
	rv = agxset(obj, sym, value);
    return rv;
}

static int agxset_(void *obj, Agsym_t *sym, const char *value, bool is_html) {
    Agraph_t *g;
    Agobj_t *hdr;
    Agattr_t *data;
    Agsym_t *lsym;

    g = agraphof(obj);
    hdr = obj;
    data = agattrrec(hdr);
    assert(sym->id >= 0 && sym->id < topdictsize(obj));
    agstrfree(g, data->str[sym->id], aghtmlstr(data->str[sym->id]));
    data->str[sym->id] = is_html ? agstrdup_html(g, value) : agstrdup(g, value);
    if (hdr->tag.objtype == AGRAPH) {
	/* also update dict default */
	Dict_t *dict;
	dict = agdatadict(g, false)->dict.g;
	if ((lsym = aglocaldictsym(dict, sym->name))) {
	    agstrfree(g, lsym->defval, aghtmlstr(lsym->defval));
	    lsym->defval = is_html ? agstrdup_html(g, value) : agstrdup(g, value);
	} else {
	    lsym = agnewsym(g, sym->name, value, is_html, sym->id, AGTYPE(hdr));
	    dtinsert(dict, lsym);
	}
    }
    agmethod_upd(g, obj, sym);
    return SUCCESS;
}

int agxset(void *obj, Agsym_t *sym, const char *value) {
  return agxset_(obj, sym, value, false);
}

int agxset_html(void *obj, Agsym_t *sym, const char *value) {
  return agxset_(obj, sym, value, true);
}

int agsafeset(void *obj, char *name, const char *value, const char *def) {
    Agsym_t *a;

    a = agattr(agraphof(obj), AGTYPE(obj), name, 0);
    if (!a)
	a = agattr(agraphof(obj), AGTYPE(obj), name, def);
    return agxset(obj, a, value);
}

static void agraphattr_init_wrapper(Agraph_t *g, Agobj_t *ignored1,
                                    void *ignored2) {
  (void)ignored1;
  (void)ignored2;

  agraphattr_init(g);
}

/*
 * attach attributes to the already created graph objs.
 * presumably they were already initialized, so we don't invoke
 * any of the old methods.
 */
static void init_all_attrs(Agraph_t * g)
{
    Agraph_t *root;
    Agnode_t *n;
    Agedge_t *e;

    root = agroot(g);
    agapply(root, &root->base, agraphattr_init_wrapper, NULL, true);
    for (n = agfstnode(root); n; n = agnxtnode(root, n)) {
	agnodeattr_init(g, n);
	for (e = agfstout(root, n); e; e = agnxtout(root, e)) {
	    agedgeattr_init(g, e);
	}
    }
}

/* Assumes attributes have already been declared.
 * Do not copy key attribute for edges, as this must be distinct.
 * Returns non-zero on failure or if objects have different type.
 */
int agcopyattr(void *oldobj, void *newobj)
{
    Agraph_t *g;
    Agsym_t *sym;
    Agsym_t *newsym;
    char* val;
    int r = 1;

    g = agraphof(oldobj);
    if (AGTYPE(oldobj) != AGTYPE(newobj))
	return 1;
    sym = 0;
    while ((sym = agnxtattr(g, AGTYPE(oldobj), sym))) {
	newsym = agattrsym(newobj, sym->name);
	if (!newsym)
	    return 1;
	val = agxget(oldobj, sym);
	if (aghtmlstr(val)) {
	    r = agxset_html(newobj, newsym, val);
	} else {
	    r = agxset(newobj, newsym, val);
	}
    }
    return r;
}
