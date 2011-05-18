/*
 *  grid2d.cpp
 *  topicNet
 *
 *  Created by basak alper on 1/12/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#include "grid2d.h"


Grid2D :: Grid2D()
:gridsize(10), dim(1.0)
{
	
	grids =  new GridNode**[gridsize];
	//assume we first traverse in x
	for (int x=0; x<gridsize; x++) {
		grids[x] = new GridNode *[gridsize];
		//then traverse in y
		for (int y=0; y<gridsize; y++) {
			grids[x][y] = new GridNode [gridsize]; 
		}
	}
	
	
}

Grid2D :: Grid2D(int grsize, double dimen)
{
	dim = dimen;
	gridsize = grsize;
	grids =  new GridNode**[gridsize];
	//assume we first traverse in x
	for (int x=0; x<gridsize; x++) {
		grids[x] = new GridNode * [gridsize];
		//then traverse in y
		for (int y=0; y<gridsize; y++) {
			grids[x][y] = new GridNode [gridsize]; 
		}
	}
}


Grid2D :: ~Grid2D()
{
	for (int x=0; x<gridsize; x++) 
	{
		for (int y=0; y<gridsize; y++) 
		{
			delete grids[x][y];
		}
		delete grids[x];
	}
	delete grids;
}


void Grid2D :: cleargrid()
{
	for (int x=0; x<gridsize; x++) 
	{
		for (int y=0; y<gridsize; y++) 
		{
			GridNode * g = grids[x][y];
			g->graph_nodes.erase(g->graph_nodes.begin(), g->graph_nodes.end());
		}
		
	}
}



bool Grid2D :: findgridnode(space::Vec3d pos, GridNode * gn){
	double div = dim / gridsize;
	if (pos.x == dim) pos.x -= 0.0001;
	if (pos.y == dim) pos.y -= 0.0001;
	
	int indx = (int) (pos.x / div);
	int indy = (int) (pos.y / div);
		
	if ((indx< 0 || indy<0 ) || (indx>= gridsize || indy>= gridsize)) {
		printf("find grid node failed %f, %f  \n", pos.x, pos.y);
		return false;
	}
	else{
		gn = grids[indx][indy];
		return  true;
	}
}

bool Grid2D :: getgridindex(space::Vec3d pos, int &i, int &j){
	double div = dim / gridsize;
	if (pos.x == dim) pos.x -= 0.0001;
	if (pos.y == dim) pos.y -= 0.0001;
	if (pos.z == dim) pos.z -= 0.0001;
	
	i = (int) (pos.x / div);
	j = (int) (pos.y / div);
	
	if ((i< 0 || j<0 ) || (i>= gridsize || j>= gridsize)) {
		printf("getgridindex failed %f, %f   \n", pos.x, pos.y);
		return false;
	}
	else{
		return  true;
	}
}
GridNode * Grid2D :: getgridnode(int i, int j){
	return grids[i][j];
}


void Grid2D :: addGraphNode(GraphNode * nd){
	GridNode * grnd = new GridNode();
	bool found = findgridnode(nd->getPos(), grnd);
	if(found)
		grnd->graph_nodes.push_back(nd);
	else {
		printf("add graph node failed \n");
	}

}

void Grid2D :: addGraph(Graph * thegraph){
	for(int n=0; n< thegraph->getNumNodes(); n++){
		GraphNode * gnd = thegraph->getGraphNode(n);
		addGraphNode(gnd);
	}
}

void Grid2D :: drawGridNode(int ix, int iy){
	float xs = (float)(ix * dim) / gridsize;
	//xs = xs - (dim * 0.5);
	float xf = (float)((ix+1) * dim) / gridsize;
	//xf = xf - (dim * 0.5);
	float ys = (float)(iy * dim) / gridsize;
	//ys = ys - (dim * 0.5);
	float yf = (float)((iy+1) * dim) / gridsize;
	//yf = yf - (dim * 0.5);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
	glDisable(GL_DEPTH_TEST);
	
	
	glBegin(GL_QUADS);
	glColor4f(1.0, 0.2, 0.2, 0.3);
	glVertex3f(xs, ys, 0.0);
	
	glColor4f(1.0, 0.8, 0.2, 0.3);
	glVertex3f(xf, ys, 0.0);
	
	glColor4f(0.3, 0.9, 0.2, 0.3);
	glVertex3f(xf, yf, 0.0);
	
	glColor4f(0.1, 0.3, 0.9, 0.3);
	glVertex3f(xs, yf, 0.0);

	
	glEnd();
	
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_BLEND);
}

void Grid2D :: drawGrid(){
	for (int xx=0; xx<gridsize; xx++) {
		for (int yy=0; yy<gridsize; yy++) {
			drawGridNode(xx, yy);
		}
	}
}
