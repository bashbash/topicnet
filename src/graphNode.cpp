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
:label("empty"), level(1), nodeid(-1), fixed(false)
{
	color.set(1.0, 0.0, 0.0);
	position.set(0.0,0.0, 0.0);
	displacement.set(0.0,0.0, 0.0);
	plane = 0;
	highlight = false;
}

GraphNode :: GraphNode(int idd, int lev, vec3d p, string lab, space::Vec3f clr)
:label(lab), level(lev), nodeid(idd), fixed(false)
{
	color.set(clr);
	position.set(p);
	displacement.set(0.0,0.0, 0.0);
	plane = 0;
	highlight = false;
}

GraphNode :: GraphNode(int idd, string stid, string lab)
:label(lab), nodeid(idd), strid(stid)
{
	color.set(1.0, 0.0, 0.0);
	position.set(0.0, 0.0, 0.0);
	displacement.set(0.0,0.0, 0.0);
	plane = 0;
	highlight = false;
	
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


void GraphNode :: addPub(Article * a){
	pubs.push_back(a);
}


void GraphNode :: printPublications(){
	printf("pubsList: \n");
	
	for (int p =0; p< pubs.size(); p++){
		Article * tmp = pubs.at(p);
		//printf(" %i 'th id is:  \n", p);
		printf(" article %i: %s, %s \n", p+1, tmp->getId().c_str(), tmp->getTitle().c_str());
	}
	
}


void GraphNode :: printAdjacentNodes(){
	for (int a =0; a< adjacents.size(); a++){
		GraphNode * tmp = adjacents.at(a);
		printf("neighbors %i 'th id is: %i \n", a, tmp->getnodeid());
	}
	
	
}



void GraphNode :: accumDisp(vec3d ds){
	displacement = displacement + ds;
	
}

void GraphNode :: move(vec3d amnt){
	position = position + amnt;
}

	