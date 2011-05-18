/*
 *  FR_Layout_2D.cpp
 *  topicNet
 *
 *  Created by basak alper on 12/15/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "FR_Layout_2D.h"
#include "vec2.h"
typedef space::Vec3d vec3d;

FR_Layout_2D :: FR_Layout_2D()
{
}

FR_Layout_2D ::FR_Layout_2D(int itr, double mdel, double ar, double cool, bool w)
:numiter(itr), maxdelta(mdel), area(ar), coolexp(cool), weighted(w)
{
}

FR_Layout_2D :: ~FR_Layout_2D()
{
	
}


void FR_Layout_2D :: calculateK(Graph * gr){
	k = sqrt(area*area/gr->getNumNodes());
	ksqr = k*k;
}



void FR_Layout_2D :: layout(Graph * thegraph, Grid * thegrid){
	//area := W * L; { W and L are the width and length of the frame }
	//G := (V, E); { the vertices are assigned random initial positions }
	
	calculateK(thegraph);
	
	for(int it=0; it<numiter; it++){
		// calculate repulsive forces
		calculateRepulsiveForces(thegraph, thegrid, ksqr);
		// calculate attractive forces 
		calculateAttractiveForces(thegraph, k);
		// limit the maximum displacement to the temperature t 
		// and then prevent from being displaced outside frame
		for(int vind=0; vind<thegraph->getNumNodes(); vind++){ 
			GraphNode * v = thegraph->getGraphNode(vind);
			vec3d dis = v->getDisp();
			vec2d dis2d = vec2d(dis.x, dis.y);
			double dismag = vec3d::mag(dis);
			vec3d::normalize(dis);
			vec3d scaled = dis * min ( dismag, coolexp );
			vec3d newpos = v->pos() + scaled;
			
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
		coolexp = coolexp * 0.9;
		
	}//iterations end
	
}

void FR_Layout_2D :: step(bool threed, double coolfact, Graph * thegraph, Grid * thegrid){
	calculateRepulsiveForces(thegraph, thegrid, ksqr);
	// calculate attractive forces 
	calculateAttractiveForces(thegraph, k);
	// limit the maximum displacement to the temperature t 
	// and then prevent from being displaced outside frame
	for(int vind=0; vind<thegraph->getNumNodes(); vind++){ 
		GraphNode * v = thegraph->getGraphNode(vind);
		vec3d dis = v->getDisp();
		double dismag = vec3d::mag(dis);
		vec3d::normalize(dis);
		vec3d scaled = dis * min ( dismag, coolfact );
		vec3d newpos = v->pos() + scaled;
		
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


void FR_Layout_2D :: calculateRepulsiveForces(Graph * thegraph, Grid * thegrid, double ksq){
	
	for(int gni=0; gni<thegraph->getNumNodes(); gni++){ 
		// each vertex has two vectors: .pos and .disp 
		GraphNode * v = thegraph->getGraphNode(gni);
		v->resetDisp();
		
		
		int i, j, k;
		bool foundgridindex = thegrid->getgridindex(v->pos(), i, j, k);
		
		if (foundgridindex) {
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
								vec3d D = v->pos() - u->pos();
								
								float dismag = vec3d::mag(D);
								vec3d::normalize(D);
								if (dismag == 0.0) {
									dismag = 0.0001;
								}
								vec3d scaled = D * fr(ksq, dismag);
								v->accumDisp(scaled);
								
							}
						}
						
						
						
					}
				}
			}
		}
		
		
		/*
		 bool foundgrid = false;
		 GridNode * gnod;
		 foundgrid= thegrid->findgridnode(gnod, v->pos());
		 if (foundgrid) {
		 for (int s=0; s < gnod->graph_nodes.size(); s++) {
		 GraphNode * u = gnod->graph_nodes.at(s);
		 if (v != u) {
		 // D is short hand for the difference
		 // vector between the positions of the two vertices 
		 vec3d D = v->pos() - u->pos();
		 
		 float dismag = vec3d::mag(D);
		 vec3d::normalize(D);
		 if (dismag == 0.0) {
		 dismag = 0.0001;
		 }
		 vec3d scaled = D * fr(ksq, dismag);
		 v->accumDisp(scaled);
		 
		 }
		 }
		 }
		 */
	}
	
}


void FR_Layout_2D :: calculateAttractiveForces(Graph * thegraph, double k){
	for(int eind=0; eind<thegraph->getNumEdges(); eind++){
		// each edge is an ordered pair of vertices .v and .u 
		GraphEdge * e = thegraph->getGraphEdge(eind);
		GraphNode * vv = e->get_from();
		GraphNode * uu = e->get_to();
		vec3d D = vv->pos() - uu->pos();
		double dismag = vec3d::mag(D);
		vec3d::normalize(D);
		vec3d scaled = D * fa(k, dismag);
		vec3d invscaled = scaled * -1.0;
		vv->accumDisp(invscaled);
		uu->accumDisp(scaled);
	}
}
