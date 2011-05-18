/*
 *  gridNode.h
 *  topicNet
 *
 *  Created by basak alper on 5/29/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef GRIDNODE_H
#define GRIDNODE_H 1

#include <vector>
#include "graphNode.h"
using namespace std;

class GridNode {
	
public:
	
	GridNode();
	~GridNode();
	
	
	void addGraphNode(GraphNode * gn); 
	vector<GraphNode *> graph_nodes;
		
};

#endif //GRIDNODE_H
