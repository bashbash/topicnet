/*
 *  grid.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "grid.h"

Grid :: Grid()
:gridsize(10), dim(1.0)
{
	
	grids =  new GridNode***[gridsize];
	//assume we first traverse in x
	for (int x=0; x<gridsize; x++) {
		grids[x] = new GridNode ** [gridsize];
		//then traverse in y
		for (int y=0; y<gridsize; y++) {
			grids[x][y] = new GridNode * [gridsize]; //making same number of nodes in x, y, z 
			for (int z=0; z<gridsize; z++) {
				grids[x][y][z] = new GridNode [gridsize];
			}
		}
	}
	
	
}

Grid :: Grid(int grsize, double dimen)
{
	dim = dimen;
	gridsize = grsize;
	grids =  new GridNode***[gridsize];
	//assume we first traverse in x
	for (int x=0; x<gridsize; x++) {
		grids[x] = new GridNode ** [gridsize];
		//then traverse in y
		for (int y=0; y<gridsize; y++) {
			grids[x][y] = new GridNode * [gridsize]; //making same number of nodes in x, y, z 
			for (int z=0; z<gridsize; z++) {
				grids[x][y][z] = new GridNode [gridsize];
			}
		}
	}
	
	
}


Grid :: ~Grid()
{
	for (int x=0; x<gridsize; x++) {
		for (int y=0; y<gridsize; y++) {
			for (int z=0; z<gridsize; z++) {
				delete grids[x][y][z];
			}
			delete grids[x][y];
		}
		delete grids[x];
	}
	delete grids;
}


void Grid :: cleargrid()
{
	for (int x=0; x<gridsize; x++) {
		for (int y=0; y<gridsize; y++) {
			for (int z=0; z<gridsize; z++) {
				GridNode * g = grids[x][y][z];
				g->graph_nodes.erase(g->graph_nodes.begin(), g->graph_nodes.end());
			}
		}
	}
}

GridNode* Grid :: findgridnode(space::Vec3d pos){
	double div = dim / gridsize;
	if (pos.x == dim) pos.x -= 0.0001;
	if (pos.y == dim) pos.y -= 0.0001;
	if (pos.z == dim) pos.z -= 0.0001;
	
	int indx = (int) (pos.x / div);
	int indy = (int) (pos.y / div);
	int indz = (int) (pos.z / div);
	
	if ((indx< 0 || indy<0 || indz<0) || (indx>= gridsize || indy>= gridsize || indz>= gridsize)) {
		printf("find grid node failed here %f, %f, %f  \n", pos.x, pos.y, pos.z);
		return grids[0][0][0];
	}
	else{
		//printf("grid index %d, %d, %d \n", indx, indy, indz);
		return grids[indx][indy][indz];
		
	}
}


bool Grid :: findgridnode(space::Vec3d pos, GridNode * gn){
	double div = dim / gridsize;
	if (pos.x == dim) pos.x -= 0.0001;
	if (pos.y == dim) pos.y -= 0.0001;
	if (pos.z == dim) pos.z -= 0.0001;
	
	int indx = (int) (pos.x / div);
	int indy = (int) (pos.y / div);
	int indz = (int) (pos.z / div);
	
	if ((indx< 0 || indy<0 || indz<0) || (indx>= gridsize || indy>= gridsize || indz>= gridsize)) {
		printf("find grid node failed %f, %f, %f  \n", pos.x, pos.y, pos.z);
		return false;
	}
	else{
		printf("found grid node %d, %d, %d  \n", indx, indy, indz);
		gn = grids[indx][indy][indz];
		return  true;
	}
}

bool Grid :: getgridindex(space::Vec3d pos, int &i, int &j, int &k){
	double div = dim / gridsize;
	if (pos.x == dim) pos.x -= 0.0001;
	if (pos.y == dim) pos.y -= 0.0001;
	if (pos.z == dim) pos.z -= 0.0001;
	
	i = (int) (pos.x / div);
	j = (int) (pos.y / div);
	k = (int) (pos.z / div);
	if ((i< 0 || j<0 || k<0) || (i>= gridsize || j>= gridsize || k>= gridsize)) {
		printf("getgridindex failed %f, %f, %f  \n", pos.x, pos.y, pos.z);
		return false;
	}
	else{
		return  true;
	}
}
GridNode * Grid :: getgridnode(int i, int j, int k){
	return grids[i][j][k];
}


void Grid :: addGraphNode(GraphNode * nd){
	GridNode * grnd = findgridnode(nd->getPos());
	grnd->graph_nodes.push_back(nd);
	
}

void Grid :: addGraph(Graph * thegraph){
	for(int n=0; n< thegraph->getNumNodes(); n++){
		GraphNode * gnd = thegraph->getGraphNode(n);
		addGraphNode(gnd);
	}
}

void Grid :: drawGridNode(int ix, int iy, int iz){
	float xs = (float)(ix * dim) / gridsize;
	//xs = xs - (dim * 0.5);
	float xf = (float)((ix+1) * dim) / gridsize;
	//xf = xf - (dim * 0.5);
	float ys = (float)(iy * dim) / gridsize;
	//ys = ys - (dim * 0.5);
	float yf = (float)((iy+1) * dim) / gridsize;
	//yf = yf - (dim * 0.5);
	float zs = (float)(iz * dim) / gridsize;
	//zs = zs - (dim * 0.5);
	float zf = (float)((iz+1) * dim) / gridsize;
	//zf = zf - (dim * 0.5);
	
	//printf("draw grid node limits x: %f, %f y: %f, %f z: %f, %f \n", xs, xf, ys, yf, zs, zf);
	
	float verts[8][3] = {
		{xs, ys, zs},
		{xf, ys, zs},
		{xf, yf, zs},
		{xs, yf, zs},
		
		{xs, ys, zf},
		{xf, ys, zf},
		{xf, yf, zf},
		{xs, yf, zf},
	};
	
	GLfloat norms[6][3] = {
		{0, 0, -1},
		{1, 0, 0},
		{0, 0, 1},
		{-1, 0, 0},
		{0, -1, 0},
		{0, 1, 0},
	};
	
	int faces[6][4] = {
		{3, 2, 1, 0},
		{1, 2, 6, 5},
		{5, 6, 7, 4},
		{4, 7, 3, 0},
		{5, 4, 0, 1},
		{7, 6, 2, 3},
	};	
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
	glDisable(GL_DEPTH_TEST);
	
	
	glBegin(GL_QUADS);
	for ( int f=0; f<6; f++){
		glNormal3f(norms[f][1], norms[f][1], norms[f][1]);
		for (int v=0; v<4; v++) {
			//glColor4f(f* 0.15, v*0.2, 0.2, 0.2);
			glColor4f(0.2*v + 0.2, 0.35, 0.2, 0.3);
			glVertex3f(verts[faces[f][v]][0], verts[faces[f][v]][1], verts[faces[f][v]][2]);
		}
	}
	glEnd();
	
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_BLEND);
	
}

void Grid :: drawGrid(){
	for (int xx=0; xx<gridsize; xx++) {
		for (int yy=0; yy<gridsize; yy++) {
			//for (int zz=0; zz<gridsize; zz++) {
				drawGridNode(xx, yy, 0);
			//}
		}
	}
}
