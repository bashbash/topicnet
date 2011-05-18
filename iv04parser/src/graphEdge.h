/*
 *  graphEdge.h
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef GRAPHEDGE_H
#define GRAPHEDGE_H 1

#include "graphNode.h"


class GraphEdge {
	
public:
	
	GraphEdge();
	GraphEdge(int idy, GraphNode * aend, GraphNode * bend);
	GraphEdge(int idy, string from, string to);
	~GraphEdge();
	
	GraphNode * get_from(){return fromnode;}
	GraphNode * get_to(){return tonode;}
	
	string from;
	string to;

	void setEnds(GraphNode * f, GraphNode * t);
	void setFrom(GraphNode * f){ fromnode = f;}
	void setTo(GraphNode * t){tonode = t;}
	int getEdgeid() { return edgeid; }
	
private:
	int edgeid;
	
	GraphNode * fromnode;
	GraphNode * tonode;
		
		
	
};

#endif //GRAPHEDGE_H