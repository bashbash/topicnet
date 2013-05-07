/*
 *  graph.h
 *  topicNet
 *
 *  Created by basak alper on 5/30/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef GRAPH_H
#define GRAPH_H 1



#include "graphNode.h"
#include "graphEdge.h"
#include <vector>
#include <algorithm>
#include <stdlib.h>
#include <sstream>

//NOW ALREADY INCLUDED THROUGH graphNode.h THROUGH topic_gl.h
//#include <OpenGL/gl.h>		// Header File For The OpenGL32 Library
//#include <OpenGL/glu.h>		// Header File For The GLu32 Library



using namespace std;

const double AREA = 5.0;
const double PI = 3.1415926;

class Graph{
	
public:
	
	Graph();
	~Graph();
	
	int getNumNodes(){return adjlist.size();}
	int getNumEdges(){return edgelist.size();}
	void addGraphNode(GraphNode * gn); 
	void addGraphEdge(GraphEdge * ge);
	GraphEdge* getGraphEdge(int index);
	GraphEdge* getNextGraphEdge();
	GraphNode* getGraphNode(int index);
	GraphNode* getNextGraphNode();
	int getSize();
	int getEdgeSize();
	
	void preprocess();
	void preprocessauthorgraph();
	void preprocessgraphml();
	
	void normalizeinitpos();
	void draw();
	void drawedges(bool forshade, double thick);
	void drawnodes(bool treedee, double sz);
	
	void drawneighboredges(int ndid, bool forshade, double thick);
	void drawneighbornodes(int ndid, double sz);
	
	void ramdomizePositions(bool td);
	
	void move(int nd, vec3d amount);
	
	void clear();
	
	void traverse(vector < vector <GraphNode* > > & bftr);
	void connectedcomponent(string strid);
	void visitnodes(GraphNode * g);
	
	void deletenode(GraphNode * g);
	
	void drawsphere(double lats, double lons) ;
    
	
	void addSelectedNode(int ind) { selectednodes.push_back(ind); }
	void clearSelectedNode() { selectednodes.clear(); }
	vector<int> getSelectedNodes() { return selectednodes; }
	
	void printNode(GraphNode * g);
	void printEdge(GraphEdge * edg);
	void outputGraphXML(string filepath);

	vector<GraphNode *> firstNghbrs(int nodeind);
	vector<GraphNode *> secondNghbrs(int nodeind);
	
		
private:
	ofstream xmloutfile;

	vector<GraphNode *> adjlist; //each node holds all adjacent nodes, therefore this is an adjacency list
	vector<GraphEdge *> edgelist; // each edge holds a pointer to, from and to graphnodes
	
	double linethick;
	double pointsz;
	
	vector<int> selectednodes;

	
};

#endif //GRAPH_H
