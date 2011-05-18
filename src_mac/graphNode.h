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
#include "vec/vec3.h"


using namespace std;
typedef space::Vec3d vec3d;


class GraphEdge;
class GraphNode {
	
public:
	
	GraphNode();
	GraphNode(int idd, int lev, vec3d p, string lab, space::Vec3f clr);
	GraphNode(int idd, string stid, string lab);
	~GraphNode();
	
	void printname(); //always a cube
	void addAdjacentNode(GraphNode * n);
	void addAdjacentEdge(GraphEdge * e);
	void printAdjacentNodes();
	
	int getnodeid(){return nodeid;}
	void setnodeid(int iddd){ nodeid = iddd; }
	string getstrid() {return strid; }
	
	vec3d getPos(){ return position;}
	void setPos(vec3d ps){position.set(ps);}
	void setPosZ(double z){ position.z = z; }
	
	void move(vec3d amnt); 
	
	space::Vec3f getClr(){ return color;}
	void setClr(space::Vec3f col){ color = col;}
	
	void resetDisp(){displacement.set(0.0, 0.0, 0.0);}
	void setDisp(vec3d ds){displacement.set(ds);}
	void accumDisp(vec3d ds);
	vec3d getDisp(){return displacement; }
	
	string getLabel(){ return label; }
	
	void setShortLabel(string sl){ shortlabel = sl; }
	string getShortLabel(){ return shortlabel; }
	
	void setPlane(int p) {plane = p; }
	int getPlane() { return plane; }
	
	//enum GNodeType { USER, FRIEND, MUSIC, NOTSET};
	//static std::map<std::string, GNodeType> s_map_nodetype;
	
	int getType() { return type;}
	void setType(int t) { type = t; }
	
	bool getHighlight() { return highlight; }
	void setHighlight(bool h) { highlight = h ;}
	
	bool getLabelVis(){ return labelvisible;}
	void setLabelVis(bool v) { labelvisible = v; }
	
	vector<GraphEdge *> edgesvec() { return adjedges;}
	vector<GraphNode *> nodesvec() { return adjacents;}
	
	bool isVisited() {return visit;}
	void visited(bool v) {visit = v;}
	
private:
	
	vec3d position;
	vec3d displacement;
	space::Vec3f color;
	string label;
	string strid;
	int level;
	bool fixed;
	bool visit;
	int nodeid;
	
	string shortlabel;
	
	int plane; 
	
	bool labelvisible;
	int type;
	
	bool highlight;
	
	vector<GraphNode *> adjacents;
	vector<GraphEdge *>adjedges;
		
};

#endif //GRAPHNODE_H