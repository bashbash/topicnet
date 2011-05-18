/*
 *  graphEdge.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "graphEdge.h"

GraphEdge :: GraphEdge()
:	edgeid(-1)
{
}

GraphEdge :: GraphEdge(int idy, GraphNode * aend, GraphNode * bend) 
:	edgeid(idy)
{
	fromnode = aend;
	tonode = bend;
	from = aend->getNodeid();
	to = bend->getNodeid();
}

GraphEdge :: GraphEdge(int idy, string fr, string too)
: edgeid(idy)
{
	from = fr;
	to = too;
}


GraphEdge :: ~GraphEdge()
{
	delete fromnode;
	delete tonode;
}

void GraphEdge :: setEnds(GraphNode * f, GraphNode * t){
	fromnode = f;
	tonode = t;
}

