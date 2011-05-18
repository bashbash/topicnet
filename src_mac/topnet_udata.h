/*
 *  Topicnet_udata.h
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */


#ifndef TOPNET_DATA_UDATA_H
#define TOPNET_DATA_UDATA_H 1

#include "lua_topnet_udata.h"
#include "topnet.h"

class Topicnet_udata : public Topicnet, public udata::Udata<Topicnet_udata> {
private:
	typedef Topicnet_udata		Self;
	typedef Topicnet			Base;
	
public:
	Topicnet_udata();
	virtual ~Topicnet_udata();
	
	static int __new(lua_State * L);
    static int loadData(lua_State * L);
	
	
	
	static int drawGraph(lua_State * L);
	static int drawGraphEdges(lua_State * L);
	static int drawNeighEdges(lua_State * L);
	static int drawGraphNodes(lua_State * L);
	static int drawNeighNodes(lua_State * L);
	
	static int neighNodes(lua_State * L);
	
	static int stepLayout(lua_State * L);
	static int doLayout(lua_State * L);
	static int graphsize(lua_State * L);
	static int randomizeGraph(lua_State * L);
	static int initGraphLayout(lua_State * L);
	
	
	static int selectedNode(lua_State * L);
	
	static int highlightN1(lua_State * L);
    	
	static int bringN1(lua_State * L);
	
	static int graphnodepos(lua_State * L);
	
	static int graphnodeplane(lua_State * L);
	
	static int getnodelabel(lua_State * L);
	static int getnodeid(lua_State * L);
	

	static int addPlane(lua_State * L);
	static int removePlane(lua_State * L);
	static int planeDepth(lua_State * L);
	static int planeCount(lua_State * L);
	static int addNodeToPlane(lua_State * L);
	static int movePlane(lua_State * L);
	
	static int moveGraph(lua_State * L);

	static int get1stNgh(lua_State * L);
	
	static const udata::LuaMethod * getLuaMethods() {return lua_methods;}
	static const char ** getSuperclassTable() {return superclass_table;}
	static const char *name;
		
protected:
	static const udata::LuaMethod lua_methods[];
	static const char *superclass_table[];
};



#endif //TOPNET_DATA_UDATA_H