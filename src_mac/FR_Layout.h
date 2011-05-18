/*
 *  FR_layout.h
 *  topicNet
 *
 *  Created by basak alper on 5/31/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef FR_LAYOUT_H
#define FR_LAYOUT_H 1

#include "graph.h"
#include "grid.h"

class FR_Layout{
	
public:
	
	FR_Layout();
	FR_Layout(int itr, double ar, double temp);
	
	
	~FR_Layout();
	
	void layout(Graph * thegraph, Grid * thegrid);
	void step(bool threed, double coolfact, Graph * thegraph, Grid * thegrid);
	
	void calculateRepulsiveForces(Graph * thegraph, Grid * thegrid);
	void calculateRepulsiveForcesWithoutGrid(Graph * thegraph);
	
	void calculateAttractiveForces(Graph * thegraph);
		
	void calculateK(Graph * thegraph);
	
	double fa(double dist){ return dist*dist/ K ;} 
	double fr(double dist){ return Ksqr / dist ;} //remove minus
	
private:

	int numiter; //number of iterations to do
	double area;
	double temparature;
	double K;
	double Ksqr;
	
};

#endif //FR_LAYOUT_H