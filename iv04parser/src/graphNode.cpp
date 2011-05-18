/*
 *  GraphNode.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "graphNode.h"


GraphNode :: GraphNode()
:label("empty"), level(1), nodeid(""), intid(0)
{
}

GraphNode :: GraphNode(int indid, string idd,  string lab)
:label(lab), level(1), nodeid(idd), intid(indid)
{
}




GraphNode :: ~GraphNode()
{
	//delete dynamic arrays
}



void GraphNode :: printname(){
	printf("node id and name $i \n", nodeid);
}

void GraphNode :: addAdjacentNode(GraphNode * n){
	adjacents.push_back(n);
}

void GraphNode :: addAdjacentEdge(GraphEdge * e){
	adjedges.push_back(e);
}


void GraphNode :: printAdjacentNodes(){
	for (int a =0; a< adjacents.size(); a++){
		GraphNode * tmp = adjacents.at(a);
		printf("neighbors %i 'th id is: %i \n", a, tmp->getNodeid());
	}
	
	
}

	