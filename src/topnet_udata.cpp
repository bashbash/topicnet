/*
 *  Topicnet_udata.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */


#include "topnet_udata.h"
#include "lua_utility.h"


void * Topicnet_udata_to_udata(lua_State *L, int idx) {
	return Topicnet_udata::to_udata(L, idx);
}

void * Topicnet_udata_to_base(lua_State *L, int idx) {
	return (Topicnet *)Topicnet_udata::to_udata(L, idx);
}

const char * Topicnet_udata :: name = "Topicnet";
const char * Topicnet_udata::superclass_table[] = {NULL};

#define LUA_METHOD(name, type) {#name, Self::name, udata::LuaMethod::type}

const udata::LuaMethod Topicnet_udata :: lua_methods[] = {
	{"new", Self::__new, udata::LuaMethod::METHOD},
	LUA_METHOD(loadData, METHOD),
	LUA_METHOD(randomizeGraph, METHOD),
	LUA_METHOD(initGraphLayout, METHOD),
	LUA_METHOD(drawGraph, METHOD),
	LUA_METHOD(drawGraphEdges, METHOD),
	LUA_METHOD(drawNeighEdges, METHOD),
	LUA_METHOD(drawGraphNodes, METHOD),
	LUA_METHOD(drawNeighNodes, METHOD),
	
	LUA_METHOD(neighNodes, METHOD), 
	
	LUA_METHOD(stepLayout, METHOD),
	LUA_METHOD(doLayout, METHOD),
	LUA_METHOD(graphsize, METHOD),
	LUA_METHOD(graphedgesize, METHOD),
	
	LUA_METHOD(selectedNode, METHOD),
	LUA_METHOD(getnodelabel, METHOD),
	LUA_METHOD(getnodeid, METHOD),
	LUA_METHOD(getnodepubs, METHOD),
	
	
	LUA_METHOD(highlightN1, METHOD),
	LUA_METHOD(bringN1, METHOD),
	LUA_METHOD(get1stNgh, METHOD),
	
	LUA_METHOD(moveGraph, METHOD),
	
	LUA_METHOD(graphnodepos, METHOD),
	LUA_METHOD(graphedge, METHOD),
	
	LUA_METHOD(graphnodeplane, METHOD),
	
	
	LUA_METHOD(addPlane, METHOD),
	LUA_METHOD(removePlane, METHOD),
	LUA_METHOD(movePlane, METHOD),
	LUA_METHOD(planeDepth, METHOD),
	LUA_METHOD(planeCount, METHOD),
	LUA_METHOD(addNodeToPlane, METHOD),
	
	{0, 0, (udata::LuaMethod::MethodType)0}
};

#undef LUA_METHOD

Topicnet_udata :: Topicnet_udata()
: Topicnet()
{}

Topicnet_udata :: ~Topicnet_udata()
{}

int Topicnet_udata :: __new(lua_State *L) {
	Self *s = new Self();
	Self::udata_push(L, s);
	
	return 1;
}

int Topicnet_udata :: loadData(lua_State *L) {
	
	Self *s = Self::to_udata(L, 1);
	if(s) {
		
		const char *filePath = lua_tostring(L, 2);
		string type = lua_tostring(L, 3);
		if (type == "author") {
			s->Base::loadAuthorData(filePath);
		}
		else if(type == "face") {
			s->Base::loadFaceData(filePath);
		}
		
		else if(type == "graphml") {
			s->Base::loadGraphMLdata(filePath);
		}

		
		
	}
	else{
		luaL_error(L, "Topicnet.loadData: invalid object or arguments");
	}
	return 0;
}

int Topicnet_udata :: randomizeGraph(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		bool treedee = lua_toboolean(L, 2);
		s->Base::getGraph()->ramdomizePositions(treedee);
	}
	else{
		luaL_error(L, "Topicnet.randomizeGraph: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: initGraphLayout(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		s->Base::initgraphlayout();
	}
	else{
		luaL_error(L, "Topicnet.initGraphLayout: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: stepLayout(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		bool threed = lua_toboolean(L, 2);
		double cool = lua_tonumber(L, 3);
		s->Base::steplayout(threed, cool);
	}
	else{
		luaL_error(L, "Topicnet.stepLayout: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: doLayout(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		s->Base::dolayout();
	}
	else{
		luaL_error(L, "Topicnet.doLayout: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: drawGraph(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		s->Base::drawgraph();
	}
	else{
		luaL_error(L, "Topicnet.drawGraph: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: drawNeighEdges(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodid = lua_tonumber(L, 2);
		bool shade = lua_toboolean(L, 3);
		double pntsz = lua_tonumber(L, 4);
		s->Base::getGraph()->drawneighboredges(nodid, shade, pntsz);
	}
	else{
		luaL_error(L, "Topicnet.drawNeighNodes: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: drawGraphEdges(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		bool forshade = lua_toboolean(L, 2);
		double thck = lua_tonumber(L, 3);
		//s->Base::drawgraphedges(forshade, thck);
		s->Base::getGraph()->drawedges(forshade, thck);
	}
	else{
		luaL_error(L, "Topicnet.drawGraphEdges: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: drawGraphNodes(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		bool treedee = lua_toboolean(L, 2);
		double pntsz = lua_tonumber(L, 3);
		s->Base::getGraph()->drawnodes(treedee, pntsz);
	}
	else{
		luaL_error(L, "Topicnet.drawGraphNodes: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: drawNeighNodes(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodid = lua_tonumber(L, 2);
		double pntsz = lua_tonumber(L, 3);
		s->Base::getGraph()->drawneighbornodes(nodid, pntsz);
	}
	else{
		luaL_error(L, "Topicnet.drawNeighNodes: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: neighNodes(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodid = lua_tonumber(L, 2);
		Graph* gr = s->Base::getGraph();
		if (nodid > -1 && nodid < gr->getSize()){
			vector<GraphNode *> neighs = gr->firstNghbrs(nodid);
			lua_newtable(L);
			for (int n=0; n<neighs.size(); n++) {
				lua_pushnumber(L, neighs.at(n)->getnodeid());
				lua_rawseti(L, -2, n+1);
			}
			return 1;
			
		}
	}
	else{
		luaL_error(L, "Topicnet.neighNodes: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: getnodelabel(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodeind = lua_tonumber(L, 2);
		bool lablen = lua_toboolean(L, 3);
		GraphNode * gn = s->Base::getGraph()->getGraphNode(nodeind);
		string label; 
		if (lablen) {
			label = gn->getLabel();
		}
		else {
			label = gn->getShortLabel();
		}

		
		lua_pushstring(L, label.c_str());
		
		return 1;
		
	}
	else{
		luaL_error(L, "Topicnet.getnodelabel: invalid object or arguments");
	}
	return 0;
}

int Topicnet_udata :: getnodeid(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodeind = lua_tonumber(L, 2);
		
		GraphNode * gn = s->Base::getGraph()->getGraphNode(nodeind);
		int intid = gn->getnodeid();
		lua_pushnumber(L, intid);
		//string label = gn->getstrid();
		//lua_pushstring(L, label.c_str());
		
		return 1;
		
	}
	else{
		luaL_error(L, "Topicnet.getnodeid: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: getnodepubs(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodeind = lua_tonumber(L, 2);
		
		GraphNode * gn = s->Base::getGraph()->getGraphNode(nodeind);
		string allpubs = gn->printPublications();
		
		lua_pushstring(L, allpubs.c_str());
		//printf("allpubs: %s", allpubs.c_str());
		
		return 1;
		
	}
	else{
		luaL_error(L, "Topicnet.getnodepubs: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: get1stNgh(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodeind = lua_tonumber(L, 2);
		vector<GraphNode *> fn = s->Base::getGraph()->firstNghbrs(nodeind);
		
		lua_newtable(L);
		
		for (int n=0; n<fn.size(); n++) {
			int nnind = fn.at(n)->getnodeid();
			lua_pushnumber(L, nnind);
			lua_rawseti(L, -2, n+1);
		}
		return 1;
		
	}
	return 0;
}

int Topicnet_udata :: highlightN1(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		
		int nodeind = lua_tonumber(L, 2);
		bool high = lua_toboolean(L, 3);
		
		if (nodeind > -1 && nodeind < s->Base::getGraph()->getSize()) {
			
		
			vector<GraphNode *> fn = s->Base::getGraph()->firstNghbrs(nodeind);
			for (int n=0; n<fn.size(); n++) {
				fn.at(n)->setHighlight(high);
			}
			
			GraphNode * gn = s->Base::getGraph()->getGraphNode(nodeind);
			vector<GraphEdge *> edgs = gn -> edgesvec();
			
			for (int e=0; e<edgs.size(); e++) {
				edgs.at(e)->setHighlight(high);
			}
			
		}
		
		
	}
	else{
		luaL_error(L, "Topicnet.highlightN1: invalid object or arguments");
	}
	return 0;
}




int Topicnet_udata :: bringN1(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int nodeind = lua_tonumber(L, 2);
		s->Base::bringN1(nodeind);
	}
	else{
		luaL_error(L, "Topicnet.bringN1: invalid object or arguments");
	}
	return 0;
}



int Topicnet_udata :: addPlane(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		double depth = lua_tonumber(L, 2)*0.5;
		s->Base :: addPlane(depth);
	}
	return 0;
}

int Topicnet_udata :: removePlane(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		s->Base :: removePlane();
	}
	return 0;
}

int Topicnet_udata :: movePlane(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int planeind = lua_tonumber(L, 2);
		double amount = lua_tonumber(L, 3);
		s->Base :: movePlane(planeind, amount);
	}
	else{
		luaL_error(L, "Topicnet.movePlane: invalid object or arguments");
	}
	
	return 0;
}

int Topicnet_udata :: planeCount(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int count = s->Base :: planeCount();
		lua_pushnumber(L, count);
		return 1;
	}
	else{
		luaL_error(L, "Topicnet.planeCount: invalid object or arguments");
	}
	
	return 0;
}


int Topicnet_udata :: planeDepth(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int planeind = lua_tonumber(L, 2);
		double depth = lua_tonumber(L, 3);
		if (depth) {
			s->Base:: setPlaneDepth(planeind, depth);
			return 0;
		}
		else {
			depth = s->Base::getPlaneDepth(planeind);
			lua_pushnumber(L, depth);
			return 1;
		}
	}
	else{
		luaL_error(L, "Topicnet.planeDepth: invalid object or arguments");
	}
	return 0;
}

int Topicnet_udata :: addNodeToPlane(lua_State * L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int planeind = lua_tonumber(L, 2);
		int node = lua_tonumber(L, 3);
		if (planeind && node) {
			s->Base:: addNodeToPlane(planeind, node);
			return 1;
		}
		else{
			luaL_error(L, "Topicnet.addNodeToPlane: invalid object or arguments");
			return 0;
		}
	}
	else{
		luaL_error(L, "Topicnet.addNodeToPlane: invalid object or arguments");
	}
	
	return 0;
}

int Topicnet_udata :: moveGraph(lua_State *L){
	Self *s = Self::to_udata(L, 1);
	if(s) {
		vec3d amount;
		int node = lua_tonumber(L, 2);
		if(node && lua::to_vec_t<double>(L, 3, 3, &amount.x)) {
			
		    //printf("move amnt x: %f \n", amount.x);
			s->Base::getGraph()->move(node, amount);
			return 1;
		}
		else{
			luaL_error(L, "Topicnet.moveGraph: invalid object or arguments");
		}
		 
	}
	return 0;
}





int Topicnet_udata :: selectedNode(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		
		int nodeindex = lua_tonumber(L, 2);
		
		if (nodeindex) {
			bool addmode = lua_toboolean(L, 3);
			if (! addmode || nodeindex == -1) {
				s->Base::getGraph()->clearSelectedNode();
			}
			s->Base::getGraph()->addSelectedNode(nodeindex);
						
		}
		else {
			vector<int> sels =  s->Base::getGraph()->getSelectedNodes();
			
			lua_newtable(L);
			
			for (int s=0; s<sels.size(); s++) {
				lua_pushnumber(L, sels.at(s));
				lua_rawseti(L, -2, s+1);
			}
			
			return 1;
		}

		
	}
	else{
		luaL_error(L, "Topicnet.selectedNode: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: graphsize(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		
		int sz = s->Base::getGraph()->getSize();
		lua_pushnumber(L, sz);
		return 1;
	}
	else{
		luaL_error(L, "Topicnet.graphsize: invalid object or arguments");
	}
	return 0;
}

int Topicnet_udata :: graphedgesize(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		
		int sz = s->Base::getGraph()->getEdgeSize();
		lua_pushnumber(L, sz);
		return 1;
	}
	else{
		luaL_error(L, "Topicnet.graphedgesize: invalid object or arguments");
	}
	return 0;
}


int Topicnet_udata :: graphedge(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int num = lua_tonumber(L, 2);
		GraphEdge* eg = s->Base::getGraph()->getGraphEdge(num);
		
		int from = eg->get_from()->getnodeid();
		int to = eg->get_to()->getnodeid();
			
		lua_newtable(L);
		lua_pushnumber(L, from);
		lua_rawseti(L, -2, 1);
		lua_pushnumber(L, to);
		lua_rawseti(L, -2, 2);
	}
	return 1;
}

int Topicnet_udata :: graphnodepos(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int num = lua_tonumber(L, 2);
		
		vec3d pos;
		if(lua::to_vec_t<double>(L, 3, 3, &pos.x)) {
			s->Base::setgraphnodepos(num, pos);
		}
		else {
			vec3d pos = s->Base::getgraphnodepos(num);
			string lab = s->Base::graphnodelabel(num);
			
			lua_newtable(L);
			lua_pushnumber(L, pos.x);
			lua_rawseti(L, -2, 1);
			lua_pushnumber(L, pos.y);
			lua_rawseti(L, -2, 2);
			lua_pushnumber(L, pos.z);
			lua_rawseti(L, -2, 3);
			lua_pushstring(L, lab.c_str());
			lua_rawseti(L, -2, 4);
			
		}
		return 1;
		
		
	}
	else{
		luaL_error(L, "Topicnet.graphnodepos: invalid object or arguments");
	}
	return 0;
}

int Topicnet_udata :: graphnodeplane(lua_State *L) {
	Self *s = Self::to_udata(L, 1);
	if(s) {
		int graphnode = lua_tonumber(L, 2);
		int plane = lua_tonumber(L, 3);
		if(plane){
			s->Base::getGraph()-> getGraphNode(graphnode) ->setPlane(plane); 
		}
		
		else {
			plane = s->Base::getGraph()-> getGraphNode(graphnode)->getPlane();
			lua_pushnumber(L, plane);
		}
		return 1;
		
		
	}
	else{
		luaL_error(L, "Topicnet.graphnodeplane: invalid object or arguments");
	}
	return 0;
}



