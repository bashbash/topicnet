/*
 *  topnetData.h
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */


#ifndef TOPICNET_H
#define TOPICNET_H 1


#include "lua_topnet.h"
#include "graph.h"
#include "grid.h"
#include "tinyxml.h"
#include "plane.h"
#include "FR_Layout.h"
#include "article.h"
#include <map>

class Topicnet {
	
public:
	
	Topicnet();
	~Topicnet();
	
	void loadAuthorData(const char * filePath); //now loads xml
	void loadFaceData(const char * filePath); //now loads xml
	
	
	void dump_to_graph( TiXmlNode* pParent, unsigned int indent = 0 );
	void dump_to_graph2( TiXmlNode* pParent, unsigned int indent = 0 );
	
	void loadArticlesData(string filepath);
	
	void initgraphlayout();
	void drawgraph();
	
	void steplayout(bool td, double cool);
	void dolayout();
	
	void setgraphnodepos(int ind, vec3d p);
	vec3d getgraphnodepos(int ind);
	string graphnodelabel(int ind);
	
	Graph* getGraph() { return  graph; }
	
	void addPlane(double depth);
	void removePlane();
	void setPlaneDepth(int planeid, double depth);
	double getPlaneDepth (int planeid);
	
	void bringN1(int nodeid);
	
	void split(const string& s, char c, vector<string>& v);
	
	void addNodeToPlane(int planeid, int nodeind);
	void movePlane(int planeid, double amount);
	
	void getgraphnodegridindex(int gind, int &i, int &j, int &k);
	
	int planeCount() { return planes.size(); }
		
private:
	Grid* grid;
	Graph* graph;
	
	vector<Plane *> planes; //holds all the planes for the graph
	
	typedef map <string, GraphNode*> AuthorMap;
	AuthorMap author_by_id;
	
	typedef map <string, Article*> ArticlesMap;
	ArticlesMap article_by_id;
	
	FR_Layout layoutScheme;
	string*  dummynames;
};

#endif //TOPICNET__H
