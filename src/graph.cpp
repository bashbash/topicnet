/*
 *  graph.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/30/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#include "graph.h"


typedef space::Vec3d vec3d;



Graph :: Graph()
{
	linethick = 2.0;
	pointsz = 10.0;
}

Graph :: ~Graph()
{
	
}

void Graph :: addGraphNode(GraphNode * gn){
	adjlist.push_back( gn );
}

void Graph :: addGraphEdge(GraphEdge * ge){
	edgelist.push_back( ge );
}

int Graph:: getSize(){ 
	return adjlist.size();
}

void Graph:: clear(){
	adjlist.clear();
	edgelist.clear();
}


GraphEdge* Graph :: getGraphEdge(int index){
	GraphEdge* edg;
	try {
		edg = edgelist.at(index);
		if( !edg ) throw "Graph:getGraphEdge edge index empty !";
	}
	catch( char * str ) {
		printf("Graph:getGraphEdge Exception raised: %s \n", str);
	}
	return edg;
	
}
GraphEdge* Graph ::getNextGraphEdge(){
	GraphEdge* edg;
	try {
		edg = edgelist.back();
		if( !edg ) throw "Graph:getNextGraphEdge edge index empty !";
	}
	catch( char * str ) {
		printf("Graph:getNextGraphEdge Exception raised: %s \n", str);
	}
	return edg;
}
GraphNode* Graph ::getGraphNode(int index){
	GraphNode* nd;
	try {
		nd = adjlist.at(index);
		if( !nd ) throw "Graph:getGraphNode node index empty !";
	}
	catch( char * str ) {
		printf("Graph:getGraphNode Exception raised: %s \n", str);
	}
	return nd;
	
}


GraphNode* Graph ::getNextGraphNode(){
	GraphNode* nd;
	try {
		nd = adjlist.back();
		if( !nd ) throw "Graph:getNextGraphNode node index empty !";
	}
	catch( char * str ) {
		printf("Graph:getNextGraphNode Exception raised: %s \n", str);
	}
	return nd;
	
}

void Graph::move(vec3d amount){
	if (selectednodes.size() > 0) {
		int selectednodeindex = selectednodes.back();
		GraphNode * selected = adjlist.at(selectednodeindex);
		selected->visited(true);
		vector<GraphNode * > level0  = selected-> nodesvec();
	
		 vector < vector< GraphNode* > > visitednodes;
		 visitednodes.push_back(level0);
		 
		 traverse(visitednodes);
		 
		 //printf("size of visitednodes: %d \n", visitednodes.size());
		 //do the actual move
		
		selected -> move(amount);
		for (int v=0; v<visitednodes.size(); v++) {
			amount = amount * 0.4;
			vector<GraphNode * > lv = visitednodes.at(v);
			for (int n=0; n<lv.size(); n++) {
				GraphNode * g = lv.at(n);
				g->move(amount);
			}
		}
		 
		 //unmark all nodes
		for (int a=0; a<adjlist.size(); a++) {
			adjlist.at(a)->visited(false);
		}
		 
	}
	else printf("Graph:move no valid selected node \n");
}

void Graph :: visitnodes(GraphNode * g){
//void visitNodes(GraphNode * g){
	if (g->isVisited()) {
		return;
	}
	else{
		g->visited(true);
		vector<GraphNode *> children = g->nodesvec();
	    //printf("visited node: %s, children %d \n", g->getLabel().c_str(), (int)children.size());
		
		for (int c=0; c<children.size(); c++) {
			visitnodes(children.at(c));
		}
		//for_each (children.begin(), children.end(), Graph :: visitnodes);
	}
}


void Graph::connectedcomponent(string strid){
	
	vector<GraphNode *> newnodes;
	vector<GraphEdge *> newedges;
	
	//make sure all the nodes are unmarked
	for (int a=0; a<adjlist.size(); a++) {
		adjlist.at(a)->visited(false);
	}
	
	
	//find connected nodes to a specified node
	//find the specified node
	GraphNode * thenode;
	for (int a=0; a<adjlist.size(); a++) {
		if(strid == adjlist.at(a)->getstrid()){
			thenode = adjlist.at(a);
			break;
		}
	}
	if(!thenode){
		printf("Graph::connectedcomponent, ERROR FINDING NODE \n");
	}
	else{
		
		//mark all connected nodes as visited
		visitnodes(thenode);
		
		
		
		for (int a=0; a<adjlist.size(); a++) {
			if(adjlist.at(a)->isVisited()){
				adjlist.at(a)->setClr(space::Vec3f(1.0, 1.0, 0.0));
				newnodes.push_back(adjlist.at(a));
			}
		}
		
		adjlist = newnodes;
		
		for (int a=0; a<adjlist.size(); a++) {
			vector<GraphEdge* > adeges = adjlist.at(a)->edgesvec();
			
			for(int d=0; d<adeges.size(); d++)
			{
				//check if the edge has already been deleted
				GraphEdge * edg = adeges.at(d);
				int pos = std::find(newedges.begin(), newedges.end(), edg) - newedges.begin();
				if( pos < newedges.size() ){
					//printf("pos: %d \n", pos);
				}
				else {
					newedges.push_back(edg);
				}

			}
			
		}
		
		edgelist = newedges;
		
		//make sure all the nodes are unmarked
		//reset index number as the pos in the adjacency vector
		for (int a=0; a<adjlist.size(); a++) {
			adjlist.at(a)->visited(false);
			adjlist.at(a)->setnodeid(a);
		}
	}
}


void Graph::traverse(vector < vector <GraphNode* > > & bftr){
	//recursive implementation
	vector<GraphNode *> level = bftr.at(bftr.size()-1);
	vector<GraphNode *> newlevel; 
	for (int l=0; l<level.size(); l++) {
		vector<GraphNode *> nodes = level.at(l) -> nodesvec();
		
		for (int n=0; n<nodes.size(); n++) {
			GraphNode * g = nodes.at(n);
			if (! ( g->isVisited() ) ) { //unvisited sibling
				newlevel.push_back(g);
				g->visited(true);
			}
		}
		
	}
	if (newlevel.size() > 0 ) {
		//printf("next level size: %d \n", newlevel.size());
		bftr.push_back(newlevel);
		traverse(bftr);
	}
	
}

void Graph :: ramdomizePositions(bool td){
	
	for (int n=0; n< adjlist.size(); n++) {
		vec3d rnd;
		rnd.x = (double)(rand()%1000) * 0.001 * AREA;
		rnd.y = (double)(rand()%1000) * 0.001 * AREA;
		if(td){
			rnd.z = (double)(rand()%1000) * 0.002;
		}
		else {
			rnd.z = 0.0;
		}

		
		
		adjlist.at(n)->setPos(rnd);
		
	}
	
	
}

void Graph :: preprocess(){
	//we want all the edges to have pointer to the nodes its connecting
	//we also want all nodes to know about its adjacency nodes
	//we will do so by traversing all the edges
	for (int e=0; e< edgelist.size(); e++) {
		GraphEdge * thedg = edgelist.at(e);
		int frid = thedg->from;
		int toid = thedg->to;
		
		bool foundfrom = false;
		bool foundto = false;
		GraphNode * fromend;
		GraphNode * toend;
		//find these nodes in the adjlist
		for (int a=0; a<adjlist.size(); a++) {
			GraphNode * nd = adjlist.at(a);
			if (!foundfrom && nd->getnodeid() == frid) {
				fromend = nd;
				thedg->setFrom(fromend);
				fromend->addAdjacentEdge(thedg);
				foundfrom = true;
			}
			if (!foundto && nd->getnodeid() == toid) {
				toend = nd;
				thedg->setTo(toend);
				toend->addAdjacentEdge(thedg);
				foundto = true;
			}
			if(foundto && foundfrom){
				fromend -> addAdjacentNode(toend);
				toend->addAdjacentNode(fromend);
				
				break;
			}
			
		}
	}
}


void Graph :: preprocessauthorgraph(){
	//we want all the edges to have pointer to the nodes its connecting
	//we also want all nodes to know about its adjacency nodes
	//we will do so by traversing all the edges
	
	//for this particular data we have to work with string id's
	
	for (int e=0; e< edgelist.size(); e++) {
		GraphEdge * thedg = edgelist.at(e);
		
		string frst = thedg->strfrom;
		string tostr = thedg->strto;
		
		bool foundfrom = false;
		bool foundto = false;
		
		GraphNode * fromend;
		GraphNode * toend;
		
		//find these nodes in the adjlist
		for (int a=0; a<adjlist.size(); a++) {
			GraphNode * nd = adjlist.at(a);
			if (!foundfrom && nd->getstrid() == frst) {
				fromend = nd;
				fromend->addAdjacentEdge(thedg);
				thedg->from = fromend -> getnodeid();
				thedg->setFrom(fromend);
				foundfrom = true;
			}
			if (!foundto && nd->getstrid() == tostr) {
				toend = nd;
				thedg->setTo(toend);
				toend->addAdjacentEdge(thedg);
				thedg->to = toend -> getnodeid();
				foundto = true;
			}
			if(foundto && foundfrom){
				fromend -> addAdjacentNode(toend);
				toend->addAdjacentNode(fromend);
				break;
			}
		}
	}
	
	//change labels to be the first letters
	
	for (int a=0; a<adjlist.size(); a++) {
		string lab = adjlist.at(a)->getLabel(); 
		istringstream iss(lab);
		
		vector<string> names;
		
		do
		{
			string sub;
			iss >> sub;
			names.push_back(sub);
			//cout << "Substring: " << sub << endl;
		} while (iss);
		
		//form the new string
		
		string newlabel;
		newlabel += names[0].substr(0,1);
		newlabel += names[1].substr(0,1);
		/*
		for(int i=0; i<names.size(); i++){
			newlabel += names[i].substr(0, 1);
		}
		*/
		adjlist.at(a)->setShortLabel(newlabel);
		
		//printf("old label: %s, new label: %s \n", lab.c_str(), newlabel.c_str());
		
	}
		
	ramdomizePositions(false); //since author graph has no initial positions
							   // we have to assign positions
	
}



void Graph :: printNode(GraphNode * g){
	//string thenodeid = trim(g->getNodeid(), "\t");
	xmloutfile << "\t\t\t<DNVNODE IntId=\""<< g->getnodeid() << "\" Id=\"" << g->getstrid() << "\" Label=\"" << g->getLabel() << "\"";
	xmloutfile <<" />" << endl;	
}

void Graph :: printEdge(GraphEdge * edg){
	
	xmloutfile << "\t\t\t<DNVEDGE Id=\""<< edg->getedgeid() << "\" To=\"" << edg->strto << "\" From=\"" << edg->strfrom << "\"";
	xmloutfile <<" />" << endl;	
}

void Graph :: outputGraphXML(string filepath){
	//ofstream xmloutfile;
	xmloutfile.open (filepath.c_str());
	
	if (!xmloutfile) {
		printf("ERROR OPENING OUTPUT XML FILE \n");
	}
	else{
		
		int numnodes = adjlist.size();
		int numedges = edgelist.size();
		
		xmloutfile << "<?xml version=\"1.0\" standalone=\"no\" ?>" << endl;
		xmloutfile << "\t<DNVGRAPH>" << endl;
        xmloutfile << "\t\t <Level value=\"0\" numberOfNodes=\" " << numnodes <<"\" numberOfEdges=\"" << numedges <<"\">" << endl;
		
		//output nodes
		for(int n=0; n<adjlist.size(); n++)
			printNode(adjlist.at(n));
		
	    //output edges
		for(int e=0; e< edgelist.size(); e++)
			printEdge(edgelist.at(e));
		
		
		//for_each(adjlist.begin(), adjlist.end(), printNode);
	    //for_each(edgelist.begin(), edgelist.end(), printEdge);
		
		
	}
	xmloutfile.close();
}

void Graph :: normalizeinitpos(){
	//we want to normalize graph node positions between 0.0 and 1.0
	
	double minx=0.0;
	double maxx = 1.0;
	double miny=0.0;
	double maxy = 1.0;

	for (int a=0; a<adjlist.size(); a++) {
		GraphNode * nd = adjlist.at(a);
		vec3d place = nd->getPos();
		
		minx = min(place.x, minx); 
		maxx = max(place.x, maxx); 
		
		miny = min(place.y, miny); 
		maxy = max(place.y, maxy); 
		
	}
	
	//printf("min max %f, %f, %f, %f \n", minx, maxx, miny, maxy);
	
	double yrange = maxy - miny;
	double xrange = maxx - minx;
	
	for (int a=0; a<adjlist.size(); a++) {
		GraphNode * nd = adjlist.at(a);
		vec3d place = nd->getPos();
		place.x = (place.x - minx) / xrange;
		place.y = (place.y - miny) / yrange;
		
		nd -> setPos(place);
		//printf("place of node %f, %f \n", place.x, place.y);
	}
}


void Graph :: drawsphere(double lats, double lons){
	for (int i=0; i<lats; i++){
  		double lat0 = PI * (-0.5 + i/lats);
        double z0 = sin(lat0);
        double zr0 = cos(lat0);
		
        double lat1 = PI * (-0.5 + (i+1)/lats);
        double z1 = sin(lat1);
        double zr1 = cos(lat1);
        
        glBegin(GL_TRIANGLE_STRIP);
		for (int j=0; j<lons+1; j++){ 
			double lng = 2 * PI * (j / lons);
			double x = cos(lng);
			double y = sin(lng);
			
			glNormal3f(x * zr0, y * zr0, z0);
			glVertex3f(x * zr0, y * zr0, z0);
			glNormal3f(x * zr1, y * zr1, z1);
			glVertex3f(x * zr1, y * zr1, z1);
		}
			
	    glEnd();
	}
}





vector<GraphNode * > Graph :: secondNghbrs(int nodeind){
	vector<GraphNode *> allnodes;
	if (nodeind > -1.0 && nodeind < adjlist.size()) {
		GraphNode * gn = adjlist.at(nodeind);
		allnodes = gn-> nodesvec();
		
		/*
		vec3d selnodepos = selected->pos();
		int theplane = selected->getPlane();
		for (int nv=0; nv<allnodes.size(); nv++) {
			vector<GraphNode * > thenodes = allnodes.at(nv) -> nodesvec();
			
			for (int nd=0; nd<thenodes.size(); nd++) {
				vec3d point = thenodes.at(nd)->pos();
				point.z = selnodepos.z;
				thenodes.at(nd)->setPos(point);
				thenodes.at(nd)->setPlane(theplane);
			}
		}
		 */
	}	
	
	return allnodes;
}


vector<GraphNode * > Graph :: firstNghbrs(int nodeind){
	vector<GraphNode * > thenodes;
	if (nodeind > -1.0 && nodeind < adjlist.size()) {
		GraphNode * gn = adjlist.at(nodeind);
		thenodes = gn -> nodesvec();
	}
	
	return thenodes;
}


void Graph :: drawneighbornodes(int ndid, double sz){
	//assume threedee
	vector<GraphNode *> fn = firstNghbrs(ndid);
	
	for (int n=0; n<fn.size(); n++) {
		GraphNode * gn = fn.at(n);
		vec3d point = gn->getPos();
		
		glPushMatrix();
		glTranslatef(point.x, point.y, point.z);
		glScalef(sz, sz, sz);
		drawsphere (10, 10);
		glPopMatrix();
		
	}
	
}


void Graph :: drawnodes(bool treedee, double sz){
	if (treedee) {
		for (int n=0; n< adjlist.size(); n++) {
			
			GraphNode * gn = adjlist.at(n);
			
			vec3d point = gn->getPos();
				
			glPushMatrix();
			glTranslatef(point.x, point.y, point.z);
			glScalef(sz, sz, sz);
			drawsphere (10, 10);
			glPopMatrix();
			
		}
	}
	else 
	{
		
		glPointSize(sz);
		glBegin(GL_POINTS);
		for (int n=0; n< adjlist.size(); n++) 
		{
			GraphNode * gn = adjlist.at(n);
			vec3d point = gn->getPos();
			glVertex3d(point.x, point.y, point.z);
			
		}
		glEnd();
		
		pointsz = sz;
		
	}

}


void Graph :: drawneighboredges(int ndid, bool forshade, double thick){
	double RADIUS = 0.01;
	double HALOSIZE = 1.1;
	
	GraphNode * gn = getGraphNode(ndid);
	vector<GraphEdge *> edgelist = gn -> edgesvec();
	
	for (int e=0; e<edgelist.size(); e++) {
		
		if (forshade) {
			glBegin(GL_QUADS);
			vec3d point1 = edgelist.at(e)->get_from()->getPos();
			vec3d point2 = edgelist.at(e)->get_to()->getPos();
			
			vec3d tang = point2 - point1;
			
			glNormal3f(tang.x, tang.y, tang.z);
			
			glTexCoord4f(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
			//glTexCoord3f(-1.0, alpha, thick); 
			glVertex3f(point1.x, point1.y, point1.z);
			
			glTexCoord4f(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
			//glTexCoord3f(1.0, alpha, thick); 
			glVertex3f(point1.x, point1.y, point1.z);
			
			glNormal3f(tang.x, tang.y, tang.z);
			
			glTexCoord4f(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
			//glTexCoord3f(1.0, alpha, thick); 
			glVertex3f(point2.x, point2.y, point2.z);
			
			glTexCoord4f(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
			//glTexCoord3f(-1.0, alpha, thick); 
			glVertex3f(point2.x, point2.y, point2.z);
			
			glEnd();
		}
		else {
			
			glLineWidth(thick);
			glBegin(GL_LINES);
			
			vec3d point1 = edgelist.at(e)->get_from()->getPos();
			vec3d point2 = edgelist.at(e)->get_to()->getPos();
			glVertex3d(point1.x, point1.y, point1.z);
			glVertex3d(point2.x, point2.y, point2.z);
				
			glEnd();
			
		}
		
		
	
	}

	
	

	
}

void Graph :: drawedges(bool forshade, double thick){
	
	double RADIUS = 0.008;
	double HALOSIZE = 1.2;
	
	
	if (forshade) {
		
	
		for (int e=0; e< edgelist.size(); e++) {
			
			//if (! edgelist.at(e)->getHighlight()) {
				
			
				glBegin(GL_QUADS);
				vec3d point1 = edgelist.at(e)->get_from()->getPos();
				vec3d point2 = edgelist.at(e)->get_to()->getPos();
				
				vec3d tang = point2 - point1;
				
							
				glNormal3f(tang.x, tang.y, tang.z);
				
				glTexCoord4f(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
				//glTexCoord3f(-1.0, alpha, thick); 
				glVertex3f(point1.x, point1.y, point1.z);
				
				glTexCoord4f(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
				//glTexCoord3f(1.0, alpha, thick); 
				glVertex3f(point1.x, point1.y, point1.z);
				
				glNormal3f(tang.x, tang.y, tang.z);
				
				glTexCoord4f(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
				//glTexCoord3f(1.0, alpha, thick); 
				glVertex3f(point2.x, point2.y, point2.z);
				
				glTexCoord4f(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0);
				//glTexCoord3f(-1.0, alpha, thick); 
				glVertex3f(point2.x, point2.y, point2.z);
				
				glEnd();
				
			//}
			
		}	
		
	}
	
	else {
		
		
		glLineWidth(thick);
		glBegin(GL_LINES);
		for (int e=0; e< edgelist.size(); e++) {
			
			//if (! edgelist.at(e)->getHighlight()) {
				vec3d point1 = edgelist.at(e)->get_from()->getPos();
				vec3d point2 = edgelist.at(e)->get_to()->getPos();
				glVertex3d(point1.x, point1.y, point1.z);
				glVertex3d(point2.x, point2.y, point2.z);
			//}
			
		}
		glEnd();
		
		linethick = thick;
		//redraw_n1_edges(thick);
		//redraw_n2_edges(thick);
	}

}

void Graph :: draw(){
	
	 glPointSize(5.0);
	 glColor3f(1.0, 0.8, 0.1);
	 glBegin(GL_POINTS);
	 
	 for (int n=0; n< adjlist.size(); n++) {
         space::Vec3f clr  = adjlist.at(n)->getClr();
		 glColor3f(clr.x, clr.y, clr.z);
		 vec3d point = adjlist.at(n)->getPos();
	     glVertex3d(point.x, point.y, point.z);
	 
	 }
	 glEnd();
	 
	
	 
	 glColor3f(0.9, 0.5, 0.5);
	 glBegin(GL_LINES);
	 for (int e=0; e< edgelist.size(); e++) {
		 vec3d point1 = edgelist.at(e)->get_from()->getPos();
		 vec3d point2 = edgelist.at(e)->get_to()->getPos();
		 glVertex3d(point1.x, point1.y, point1.z);
		 glVertex3d(point2.x, point2.y, point2.z);
	 
	 }
	  
	 glEnd();
	
	
}
