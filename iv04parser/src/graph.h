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
#include <stdlib.h>

using namespace std;


class Graph{
	
public:
	
	Graph();
	~Graph();
	
	int getNumNodes(){return adjlist.size();}
	int getNumEdges(){return edgelist.size();}
	
	void addGraphNode(GraphNode * gn); 
	void addGraphEdge(GraphEdge * ge);
	
	GraphEdge* getGraphEdge(int index);
	GraphNode* getGraphNode(int index);
	
	int getSize();
	void preprocess();

	vector<GraphNode *> firstNghbrs(int nodeind);
	
	
private:
	
	vector<GraphNode *> adjlist; //each node holds all adjacent nodes, therefore this is an adjacency list
	vector<GraphEdge *> edgelist; // each edge holds a pointer to, from and to graphnodes
	
};

#endif //GRAPH_H
