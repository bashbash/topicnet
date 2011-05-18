/*
 *  gridNode.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/29/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "gridNode.h"

GridNode :: GridNode()
{
}

GridNode :: ~GridNode()
{
}

void GridNode :: addGraphNode(GraphNode * gn){
	graph_nodes.push_back( gn );
}
