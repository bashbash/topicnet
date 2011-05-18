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
	GraphEdge(int idy, double len, GraphNode * aend, GraphNode * bend);
	GraphEdge(int idy, double len, int from, int to);
	GraphEdge(int idy, string strfrom, string strto);
	~GraphEdge();
	
	
	void setweight(float w) {weight = w;}
	GraphNode * get_from(){return fromnode;}
	GraphNode * get_to(){return tonode;}
	
	int from;
	int to;
	
	string strfrom;
	string strto;

	void setEnds(GraphNode * f, GraphNode * t);
	void setFrom(GraphNode * f){ fromnode = f;}
	void setTo(GraphNode * t){tonode = t;}
	int getedgeid() { return edgeid; }
	
	
	bool getHighlight() { return highlight; }
	void setHighlight(bool h) { highlight = h ;}
	
	
private:
	int edgeid;
	double weight;
	double length;
	
	bool highlight;
	
	GraphNode * fromnode;
	GraphNode * tonode;
		
		
	
};

#endif //GRAPHEDGE_H