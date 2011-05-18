/*
 *  GraphNode.h
 *  topicNet
 *
 *  Created by basak alper on 5/28/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef GRAPHNODE_H
#define GRAPHNODE_H 1

#include <fstream>
#include <vector>
#include "article.h"
using namespace std;

class GraphEdge;
class GraphNode {
	
public:
	
	GraphNode();
	GraphNode(int iid, string idd, string lab);
	~GraphNode();
	
	void printname(); //always a cube
	void addAdjacentNode(GraphNode * n);
	void addAdjacentEdge(GraphEdge * e);
	void printAdjacentNodes();
	string getNodeid(){return nodeid;}
	string getLabel(){ return label; }
	
	int getIntid() {return intid; }
	
	void setType(int t) { type = t; }
	int getType() { return type;}
	
	vector<GraphEdge *> edgesvec() { return adjedges;}
	vector<GraphNode *> nodesvec() { return adjacents;}
	vector<Article *> pubsvec() {return pubs; }
	
	private:
	
	string label;
	int level;
	string nodeid;
	int type;
	int intid;
	
	vector<GraphNode *> adjacents;
	vector<GraphEdge *>adjedges;
	vector<Article *> pubs;
		
};

#endif //GRAPHNODE_H