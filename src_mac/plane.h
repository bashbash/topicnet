/*
 *  plane.h
 *  topicNet
 *
 *  Created by basak alper on 1/8/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#ifndef PLANE_H
#define PLANE_H 1

#include <vector>
#include <algorithm>
#include "graphNode.h"
using namespace std;

class Plane {
	
public:
	
	Plane();
	Plane(int idd, double dd);
	~Plane();
	
	
	void addGraphNode(GraphNode * gn); 
	void removeGraphNode(GraphNode * gn);
	
	int getplaneid() { return planeid; }
	void setplaneid(int idd) { planeid = idd;}
	
	double getdepth() { return depth ; }
	void setdepth(double z);
	
	vector<GraphNode *> nodesonplane;
	

private:
	
	double depth; 
	int planeid;
	
};

#endif //PLANE_H
