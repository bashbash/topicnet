/*
 *  grid2d.h
 *  topicNet
 *
 *  Created by basak alper on 1/12/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#ifndef GRID2D_H
#define GRID2D_H 1

#include <fstream>
#include "gridNode.h"
#include "graph.h"
#include <OpenGL/gl.h>		// Header File For The OpenGL32 Library
#include <OpenGL/glu.h>		// Header File For The GLu32 Library
#include "vec/vec3.h"
using namespace std;

class Grid2D {
	
public:
	
	Grid2D();
	Grid2D(int grsize, double dimen);
	~Grid2D();
	
	GridNode * getgridnode(int i, int j);
	bool findgridnode(vec3d pos, GridNode * gn);
	
	void cleargrid();
	bool getgridindex(vec3d pos, int &i, int &j);
	void addGraphNode(GraphNode * nd);
	void addGraph(Graph * thegraph);
	void drawGrid();
	void drawGridNode(int ix, int iy);
    double getdim(){return dim;}
	int getgridsize(){return gridsize;}
	
private:
	
	int gridsize;
	double dim; //
	GridNode ***grids;
	
};

#endif //Grid2D_H
