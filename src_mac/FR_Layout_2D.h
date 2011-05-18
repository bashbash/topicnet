/*
 *  FR_Layout_2D.h
 *  topicNet
 *
 *  Created by basak alper on 12/15/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef FR_LAYOUT_2D_H
#define FR_LAYOUT_2D_H 1

#include "graph.h"
#include "grid.h"

class FR_Layout_2D{
	
public:
	
	FR_Layout_2D();
	FR_Layout_2D(int itr, double mdel, double ar, double cool, bool w);
	
	
	~FR_Layout_2D();
	
	void layout(Graph * thegraph, Grid * thegrid);
	void step(bool threed, double coolfact, Graph * thegraph, Grid * thegrid);
	
	void calculateRepulsiveForces(Graph * thegraph, Grid * thegrid, double ksq);
	
	void calculateAttractiveForces(Graph * thegraph, double k);
	
	void calculateK(Graph * thegraph);
	
	double fa(double k, double dist){ return dist*dist/k ;} 
	double fr(double ksq, double dist){ return ksq / dist ;} //remove minus
	
private:
	
	
	//how to store result?? just update disp of each node
	int numiter;		//number of iterations to do
	double maxdelta;	//The maximum distance to move a vertex in an iteration.
	double area;
	double coolexp;		//The cooling exponent of the simulated annealing.
	double repulserad;  //Determines the radius at which vertex-vertex repulsion cancels out attraction of adjacent vertices.
	bool weighted;		//if true the attraction along the edges will be multiplied by weight
	double k;
	double ksqr;
	
};

#endif //FR_LAYOUT_2D_H