/*
 *  FR_layout.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/31/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "FR_Layout.h"

typedef space::Vec3d vec3d;

FR_Layout :: FR_Layout()
{
}

FR_Layout ::FR_Layout(int itr,  double ar, double temp )
:numiter(itr), area(ar), temparature(temp)
{
}

FR_Layout :: ~FR_Layout()
{
	
}


void FR_Layout :: calculateK(Graph * gr){
	printf("FRLayout: calculate constants, graph area: %f \n", area);
	K = sqrt(AREA/gr->getNumNodes());
	Ksqr = K*K; //multiply by a scalar to get more repulsive force
	printf("graph constants K: %f, Ksqr: %f \n", K, Ksqr);
}



void FR_Layout :: layout(Graph * thegraph, Grid * thegrid){
	//area := W * L; { W and L are the width and length of the frame }
	//G := (V, E); { the vertices are assigned random initial positions }
	
	calculateK(thegraph);
	
	for(int it=0; it<numiter; it++){
		// calculate repulsive forces
		calculateRepulsiveForces(thegraph, thegrid);
		// calculate attractive forces 
		calculateAttractiveForces(thegraph);
		// limit the maximum displacement to the temperature t 
		// and then prevent from being displaced outside frame
		for(int vind=0; vind<thegraph->getNumNodes(); vind++){ 
			GraphNode * v = thegraph->getGraphNode(vind);
			vec3d dis = v->getDisp();
			double dismag = vec3d::mag(dis);
			vec3d::normalize(dis);
			vec3d scaled = dis * min ( dismag, temparature );
			vec3d newpos = v->getPos() + scaled;
			
			double dms = thegrid->getdim();
			newpos.x = min(dms, newpos.x);
			newpos.y = min(dms, newpos.y);
			//newpos.z = min(dms, newpos.z);
			
			newpos.x = max(0.0, newpos.x);
			newpos.y = max(0.0, newpos.y);
			//newpos.z = max(0.0, newpos.z);
			
			v->setPos(newpos);
		}
		thegrid->cleargrid();
		thegrid->addGraph(thegraph);
		// reduce the temperature as the layout approaches a better configuration 
		temparature = temparature * 0.9;
	
	}//iterations end
	
}

void FR_Layout :: step(bool threed, double temp, Graph * thegraph, Grid * thegrid){
	
	
	calculateRepulsiveForces(thegraph, thegrid);
	//calculateRepulsiveForcesWithoutGrid(thegraph);
	
	// calculate attractive forces 
	calculateAttractiveForces(thegraph);
	
	// limit the maximum displacement to the temperature t 
	// and then prevent from being displaced outside frame
	for(int vind=0; vind<thegraph->getNumNodes(); vind++){ 
		GraphNode * v = thegraph->getGraphNode(vind);
		vec3d dis = v->getDisp();
		double dismag = vec3d::mag(dis);
		vec3d::normalize(dis);
		vec3d scaled = dis * min ( dismag, temp );
		vec3d newpos = v->getPos() + scaled;
		
		double dms = thegrid->getdim();
		newpos.x = min(dms, newpos.x);
		newpos.y = min(dms, newpos.y);
		
		
		newpos.x = max(0.0, newpos.x);
		newpos.y = max(0.0, newpos.y);
		
		if(threed){
			newpos.z = min(dms, newpos.z);
			newpos.z = max(0.0, newpos.z);
		}
		else {
			newpos.z = 0.0;
		}
	
		
		
		v->setPos(newpos);
	}
	thegrid->cleargrid();
	thegrid->addGraph(thegraph);
}


void FR_Layout :: calculateRepulsiveForces(Graph * thegraph, Grid * thegrid){
	
	for(int gni=0; gni<thegraph->getNumNodes(); gni++){ 
		// each vertex has two vectors: .pos and .disp 
		GraphNode * v = thegraph->getGraphNode(gni);
		v->resetDisp();
		
		
		int i, j, k;
		bool foundgridindex = thegrid->getgridindex(v->getPos(), i, j, k);
		
		if (foundgridindex) {
			//find neighboring grid nodes
			int bx = i; int by = j; int bz = k;
			int ex = i; int ey = j; int ez = k;
			
			if (i>0) bx -= 1; 
			if (j>0) by -= 1;
			if (k>0) bz -= 1;
			
			int last = thegrid->getgridsize() - 1;
			
			if (i < last) ex += 1; 
			if (j < last) ey += 1; 
			if (k < last) ez += 1; 
			
			//need to do the search in all adjacent grid nodes
			
			for (int xind=bx; xind<=ex; xind++) {
				for (int yind=by; yind<=ey; yind++) {
					for (int zind=bz; zind<=ez; zind++) {
						
						GridNode * gnod = thegrid->getgridnode(xind, yind, zind);
						
						for (int s=0; s < (int)gnod->graph_nodes.size(); s++) {
							GraphNode * u = gnod->graph_nodes.at(s);
							if (v != u) {
								// D is short hand for the difference
								// vector between the positions of the two vertices 
								vec3d dist = v->getPos() - u->getPos();
								
								float distmag = vec3d::mag(dist);
								vec3d::normalize(dist);
								if (distmag == 0.0) {
									distmag = 0.0001;
								}
								vec3d repforce = dist * fr(distmag);
								v->accumDisp(repforce);
								
							}
						}
					
					}
				}
			}
		}
		
	}
	
}

void FR_Layout :: calculateRepulsiveForcesWithoutGrid(Graph * thegraph){
	
	for(int gni=0; gni<thegraph->getNumNodes(); gni++){ 
		// each vertex has two vectors: .pos and .disp 
		GraphNode * v = thegraph->getGraphNode(gni);
		v->resetDisp();
		
		for(int cmpnd=0; cmpnd<thegraph->getNumNodes(); cmpnd++){
			GraphNode * u = thegraph->getGraphNode(cmpnd);
			if (v != u) {
				// D is short hand for the difference
				// vector between the positions of the two vertices 
				vec3d dist = v->getPos() - u->getPos();
				
				float distmag = vec3d::mag(dist);
				vec3d::normalize(dist);
				vec3d repforce = dist * fr(distmag);
				v->accumDisp(repforce);
				
			}
		}
	}
}
		

void FR_Layout :: calculateAttractiveForces(Graph * thegraph){
	for(int eind=0; eind<thegraph->getNumEdges(); eind++){
		// each edge is an ordered pair of vertices .v and .u 
		GraphEdge * e = thegraph->getGraphEdge(eind);
		GraphNode * vv = e->get_from();
		GraphNode * uu = e->get_to();
		vec3d D = vv->getPos() - uu->getPos();
		double dismag = vec3d::mag(D);
		vec3d::normalize(D);
		vec3d scaled = D * fa(dismag);
		vec3d invscaled = scaled * -1.0;
		vv->accumDisp(invscaled);
		uu->accumDisp(scaled);
	}
}
