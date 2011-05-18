/*
 *  grid.h
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef GRID_H
#define GRID_H 1

#include <fstream>
#include "gridNode.h"
#include "graph.h"
#include "vec/vec3.h"
//#include "space/vec/vec3.h"
using namespace std;

class Grid {
	
public:
	
	Grid();
	Grid(int grsize, double dimen);
	~Grid();

	GridNode * findgridnode(vec3d pos);
	GridNode * getgridnode(int i, int j, int k);
	bool findgridnode(vec3d pos, GridNode * gn);
	
	void cleargrid();
	bool getgridindex(vec3d pos, int &i, int &j, int &k);
	void addGraphNode(GraphNode * nd);
	void addGraph(Graph * thegraph);
	void drawGrid();
	void drawGridNode(int ix, int iy, int iz);
    double getdim(){return dim;}
	int getgridsize(){return gridsize;}
	
private:
	
	int gridsize;
	double dim; //
	GridNode ****grids;
	
};

#endif //GRID_H
