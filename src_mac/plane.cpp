/*
 *  plane.cpp
 *  topicNet
 *
 *  Created by basak alper on 1/8/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#include "plane.h"


Plane :: Plane()
{
}

Plane :: Plane(int idd, double z)
:planeid(idd), depth(z)
{
	
}

Plane :: ~Plane()
{
	
}



void Plane :: addGraphNode(GraphNode * gn){
	nodesonplane.push_back( gn );
}

//I need a vector helper function that removes an element with unknown index

void Plane :: removeGraphNode(GraphNode * gn){
	//how do I do this without knowing the index
	int pos = std::find(nodesonplane.begin(), nodesonplane.end(), gn) - nodesonplane.begin();
	
    if( pos < nodesonplane.size() ){
        //printf(" element is at position %i \n", pos);
		nodesonplane.erase(nodesonplane.begin()+pos);
	}
    else
        printf(" Plane :: removeGraphNode not found on old plane.\n");
}

void Plane :: setdepth(double z) { 
	depth = z ; 
	
	for (int nd=0; nd<nodesonplane.size(); nd++) {
		vec3d pos = nodesonplane.at(nd)->getPos();
		pos.z = depth;
		nodesonplane.at(nd)->setPos(pos);
	}
	
}
