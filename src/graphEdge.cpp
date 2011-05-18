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
:	edgeid(-1), weight(1.0)
{
	
}

GraphEdge :: GraphEdge(int idy, double len, GraphNode * aend, GraphNode * bend) 
:	edgeid(idy), length(len), weight(1.0)
{
	fromnode = aend;
	tonode = bend;
	from = aend->getnodeid();
	to = bend->getnodeid();
	highlight = false;
}

GraphEdge :: GraphEdge(int idy, double len, int fr, int too)
:	length(len), weight(1.0)
{
	from = fr;
	to = too;
	edgeid = idy;
	highlight = false;
}

GraphEdge :: GraphEdge(int idy, string strfr, string strtoo)
:	length(1.0), weight(1.0)
{
	strfrom = strfr;
	strto = strtoo;
	edgeid = idy;
	highlight = false;
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

