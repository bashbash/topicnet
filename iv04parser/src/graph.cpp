/*
 *  graph.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/30/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "graph.h"


Graph :: Graph()
{
}

Graph :: ~Graph()
{
	
}

void Graph :: addGraphNode(GraphNode * gn){
	adjlist.push_back( gn );
}

void Graph :: addGraphEdge(GraphEdge * ge){
	edgelist.push_back( ge );
}

int Graph:: getSize(){ 
	return adjlist.size();
}


GraphEdge* Graph :: getGraphEdge(int index){
	GraphEdge* edg;
	try {
		edg = edgelist.at(index);
		if( !edg ) throw "Graph:getGraphEdge edge index empty !";
	}
	catch( char * str ) {
		printf("Graph:getGraphEdge Exception raised: %s \n", str);
	}
	return edg;
	
}


GraphNode* Graph ::getGraphNode(int index){
	GraphNode* nd;
	try {
		nd = adjlist.at(index);
		if( !nd ) throw "Graph:getGraphNode node index empty !";
	}
	catch( char * str ) {
		printf("Graph:getGraphNode Exception raised: %s \n", str);
	}
	return nd;
	
}





void Graph :: preprocess(){
	//we want all the edges to have pointer to the nodes its connecting
	//we also want all nodes to know about its adjacency nodes
	//we will do so by traversing all the edges
	
	/*
	for (int e=0; e< edgelist.size(); e++) {
		GraphEdge * thedg = edgelist.at(e);
		int frid = thedg->from;
		int toid = thedg->to;
		
		bool foundfrom = false;
		bool foundto = false;
		GraphNode * fromend;
		GraphNode * toend;
		//find these nodes in the adjlist
		for (int a=0; a<adjlist.size(); a++) {
			GraphNode * nd = adjlist.at(a);
			if (!foundfrom && nd->getnodeid() == frid) {
				fromend = nd;
				thedg->setFrom(fromend);
				fromend->addAdjacentEdge(thedg);
				foundfrom = true;
			}
			if (!foundto && nd->getnodeid() == toid) {
				toend = nd;
				thedg->setTo(toend);
				toend->addAdjacentEdge(thedg);
				foundto = true;
			}
			if(foundto && foundfrom){
				fromend -> addAdjacentNode(toend);
				toend->addAdjacentNode(fromend);
				
				break;
			}
			
		}
	}
	*/
}


vector<GraphNode * > Graph :: firstNghbrs(int nodeind){
	vector<GraphNode * > thenodes;
	if (nodeind > -1.0 && nodeind < adjlist.size()) {
		GraphNode * gn = adjlist.at(nodeind);
		thenodes = gn -> nodesvec();
	}
	
	return thenodes;
}



