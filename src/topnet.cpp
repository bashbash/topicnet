/*
 *  topnetData.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */



#include <fstream>
#include <iostream>
#include <sstream>


#include "topnet.h"
#include "xmlparse.h"

using namespace std;
	
Topicnet :: Topicnet()
{
	dummynames = new string[200];
	grid = new Grid(10, AREA);
	graph = new Graph();
    layoutScheme = FR_Layout(550, AREA, 3.0); //numiter, area, temparature
	Plane * base = new Plane(0, 0.0); //id of the first plane is 0 
	planes.push_back(base);
}

Topicnet :: ~Topicnet()
{
	//delete dynamic arrays
}


void Topicnet :: loadAuthorData(const char * filePath){
	
	graph->clear();
	
	string path = (string) filePath; 
	size_t found = path.find_last_of("/");
	path = path.substr(0,found);
	//printf("path of file : %s \n", path.c_str());

	
	
	TiXmlDocument doc(filePath);
	bool loadOkay = doc.LoadFile();
	if (loadOkay)
	{
		printf("\n%s:\n", filePath);
		srand(5);
		dump_to_graph2( &doc ); 
	}
	else
	{
		printf("Failed to load file \"%s\"\n", filePath);
	}
	
	printf("loaded graph with %d nodes and %d edges \n", graph->getNumNodes(), graph->getNumEdges());
	
		
	graph -> preprocessauthorgraph();
	
	loadArticlesData(path);
	
	
	//graph -> connectedcomponent("P335624"); //train data
	//graph -> connectedcomponent("P268230");
    //graph -> connectedcomponent("P643612");
	//graph -> outputGraphXML("/Users/basakalper/luaav4/trunk/modules/topicnet/scripts/data/coauthor_test.xml");
	//printf("%s : current working directory \n", getcwd(NULL, 0));
	//printf("subgraph %d nodes and %d edges \n", graph->getNumNodes(), graph->getNumEdges());
	
	grid -> addGraph(graph);
	
	
}


void Topicnet :: loadFaceData(const char * filePath){
	
	graph->clear();
	
	//load dummy names to replace
	 /**/
	string path = (string) filePath; 
	size_t found = path.find_last_of("/");
	path = path.substr(0,found);
	string nmfile = path + "/names.txt";
	printf("path of file : %s \n", path.c_str());
	
	ifstream myfile;
	myfile.open (nmfile.c_str());
	string ad, soyad;
	
	if (!myfile){
		printf("Error in openening names file \n");
	}
	
	int nm= 0; 
	while (!myfile.eof( ) && nm<200){ 
		myfile >> ad >> soyad;
		dummynames[nm] = ad;
		//printf("name: %s at: %d \n", ad.c_str(), nm);
		nm++;
	}
	myfile.close();
	/**/
	
	TiXmlDocument doc(filePath);
	bool loadOkay = doc.LoadFile();
	if (loadOkay)
	{
		printf("\n%s:\n", filePath);
		srand(5);
		dump_to_graph( &doc ); 
	}
	else
	{
		printf("Failed to load file \"%s\"\n", filePath);
	}
	
	printf("loaded graph with %d nodes and %d edges \n", graph->getNumNodes(), graph->getNumEdges());
	
	graph -> preprocess();
	 
	graph -> normalizeinitpos();
	 
}

void Topicnet :: dump_to_graph( TiXmlNode* pParent, unsigned int indent){
	
	if ( !pParent ) return;
	
	TiXmlNode* pChild;
	TiXmlText* pText;
	int t = pParent->Type();
	//printf( "%s", getIndent(indent)); //prints a +
	initializeEnums();
	initializeAttributeEnums();
	
	//initializeNodeEnums();
	//initializeEdgeEnums();
	
	
	
	switch ( t )
	{
		case TiXmlNode::TINYXML_DOCUMENT:
			printf( "Document \n" );
			break;
			
		case TiXmlNode::TINYXML_ELEMENT:
			switch(s_mapElements[pParent->Value()])
		{
			case DNVGRAPH:
				printf("graph \n");
				break;
			case NODEPROPERTY:
				//printf("NODEPROPERTY skipped \n");
				break;
			case DNVNODE:{
				//printf("node \n");
				
				TiXmlElement* pElement = pParent->ToElement();
				TiXmlAttribute* pAttrib=pElement->FirstAttribute();
				int idd, lev, nmind;
				string lab;
				string type;
				vec3d pos;
				space::Vec3f clr;
				
				while (pAttrib)
				{
					//printf("pAttrib->Name:  %s \n", pAttrib->Name());
					switch(s_map_attributes[pAttrib->Name()])
					{
						case Id:
							idd = atoi(pAttrib->Value());
							//printf("node id %i \n", idd);
							break;
							
						case Level:
							lev = atoi(pAttrib->Value());
							break;
						case Color:{
							StringVector clrstr = stringsFrom(pAttrib->Value());
							clrstr[0].erase (0,1);
							clr.set(atof(clrstr[0].c_str()), atof(clrstr[1].c_str()), atof(clrstr[2].c_str()));
							//printf("color %f, %f, %f \n", clr[0], clr[1], clr[2]);
							break;
						}
						case Position:{
							
							StringVector posstr = stringsFrom(pAttrib->Value());
							posstr[0].erase (0,1);
							
							double xpos = atof(posstr[0].c_str());
							double ypos = atof(posstr[1].c_str());
							double zpos = 0.0;
							
							
							pos.set(xpos, ypos, zpos);
							//pos.set(xpos, ypos, zpos);
							//printf("position %f, %f \n", pos[0], pos[1]);
							break;
						}
						
						case Label:
							lab = pAttrib->Value();
							
							//instead pick something from dummy names
							nmind = (int)(rand()%200);
							lab = dummynames[nmind];
							
							break;
						case Type:
							type =  pAttrib->Value();
							break;

						case Size:
						case Active:
						case Icon:
						case Mass:
						case Fixed:
						case BBid:
						case ForceLabel:
						case Alpha:
						case LabelColor:
						case LabelOutlineColor:
						case OutlineColor:
						case LabelSize:
						case Expandable:
						case Visible:
						case CurvedLabel:
						case HideLabelBackground:
							//nothing for now
							break;
						default:
							break;
							
					}
					
					
					//printf( "attributes: %s: value=%s \n", pAttrib->Name(), pAttrib->Value());
					pAttrib=pAttrib->Next();
				}
				
				GraphNode * nd = new GraphNode(idd, lev, pos, lab, clr);
				
				if (type == "user") 
					nd->setType(0);
				else if(type =="friend")
					nd->setType(1);
				else if(type =="music")
					nd->setType(2);
				else //"notset"
					nd->setType(3);
				
				
				graph->addGraphNode(nd);
				break;
			}
			case DNVEDGE:{
				//printf("edge \n");
				TiXmlElement* pElement = pParent->ToElement();
				TiXmlAttribute* pAttrib=pElement->FirstAttribute();
				int idd, lev, from, to;
				double leng, rig;
				
				while (pAttrib)
				{
					switch(s_map_attributes[pAttrib->Name()])
					{
						case Id:
							idd = atoi(pAttrib->Value());
							break;
						case Level:
							lev = atoi(pAttrib->Value());
							break;
						case Length:
							leng = atof(pAttrib->Value());
							break;
						case Rigid:
							rig = atof(pAttrib->Value());
							break;
						case From:
							from = atoi(pAttrib->Value());
							//printf("from %i \n", from);
							break;
						case To:
							to = atoi(pAttrib->Value());
							//printf("to %i \n", to);
							break;
						case Label:
						case Directional:
						case BBid:
						case Color:
						case Type:
						case HasSetColor:
						case Alpha:
						case LabelColor:
						case LabelOutlineColor:
						case LabelSize:
						case Thickness:
						case Visible:
							//nothing for now							
							break;
						default:
							break;
							
					}
					pAttrib=pAttrib->Next();
					
					
				}
				
				GraphEdge * eg = new GraphEdge(idd, leng, from, to);
				graph->addGraphEdge(eg);
				break;
				
			}
			default:
				printf("ERROR: unknown type element \n");
				break;
		}
			
			break;
			
		case TiXmlNode::TINYXML_COMMENT:
			printf( "Comment: [%s]", pParent->Value());
			break;
			
		case TiXmlNode::TINYXML_UNKNOWN:
			printf( "Unknown" );
			break;
			
		case TiXmlNode::TINYXML_TEXT:
			pText = pParent->ToText();
			printf( "Text: [%s]", pText->Value() );
			break;
			
		case TiXmlNode::TINYXML_DECLARATION:
			printf( "Declaration" );
			break;
		default:
			break;
	}
	
	for ( pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling()) 
	{
		dump_to_graph( pChild, indent+1 );
	}
	
	
}


void Topicnet :: dump_to_graph2( TiXmlNode* pParent, unsigned int indent){
	
	if ( !pParent ) return;
	
	TiXmlNode* pChild;
	TiXmlText* pText;
	int t = pParent->Type();
	
	initializeEnums();
	initializeAttributeEnums();
	
	switch ( t )
	{
		case TiXmlNode::TINYXML_DOCUMENT:
			printf( "Document \n" );
			break;
			
		case TiXmlNode::TINYXML_ELEMENT:
			switch(s_mapElements[pParent->Value()])
		{
			case DNVGRAPH:
				printf("graph \n");
				break;
			case NODEPROPERTY:
				//printf("NODEPROPERTY skipped \n");
				break;
			case DNVNODE:{
				//printf("node \n");
				
				TiXmlElement* pElement = pParent->ToElement();
				TiXmlAttribute* pAttrib=pElement->FirstAttribute();
				int intid;
				string strid, label;
				
				
				while (pAttrib)
				{
					//printf("pAttrib->Name:  %s \n", pAttrib->Name());
					switch(s_map_attributes[pAttrib->Name()])
					{
						case IntId:
							intid = atoi(pAttrib->Value());
							//printf("node id %i \n", idd);
							break;
						case Id:
							strid = pAttrib->Value();
							break;
						case Label:
							label = pAttrib->Value();
							break;
						default:
							break;
							
					}
					
					
					
					pAttrib=pAttrib->Next();
				}
				
				//printf( "strid: %s, label: %s, id: %d \n", strid.c_str(), label.c_str(), intid);
				
				
				GraphNode * nd = new GraphNode(intid, strid, label);
				graph->addGraphNode(nd);
				
				
				//store it in a map for easy access
				author_by_id[strid] = nd;
				//printf("stored author id= %s \n", strid.c_str());
				
				break;
			}
			case DNVEDGE:{
				//printf("edge \n");
				TiXmlElement* pElement = pParent->ToElement();
				TiXmlAttribute* pAttrib=pElement->FirstAttribute();
				int intid;
				string to, from;
				
				while (pAttrib)
				{
					switch(s_map_attributes[pAttrib->Name()])
					{
						case Id:
							intid = atoi(pAttrib->Value());
							break;
						case To:
							to = pAttrib->Value();
							break;
						case From:
							from = pAttrib->Value();
							break;
						default:
							break;
							
					}
					pAttrib=pAttrib->Next();
					
					
				}
				
				GraphEdge * eg = new GraphEdge(intid, from, to);
				graph->addGraphEdge(eg);
				break;
				
			}
			default:
				printf("ERROR: unknown type element \n");
				break;
		}
			
			break;
			
		case TiXmlNode::TINYXML_COMMENT:
			printf( "Comment: [%s]", pParent->Value());
			break;
			
		case TiXmlNode::TINYXML_UNKNOWN:
			printf( "Unknown" );
			break;
			
		case TiXmlNode::TINYXML_TEXT:
			pText = pParent->ToText();
			printf( "Text: [%s]", pText->Value() );
			break;
			
		case TiXmlNode::TINYXML_DECLARATION:
			printf( "Declaration" );
			break;
		default:
			break;
	}
	
	for ( pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling()) 
	{
		dump_to_graph2( pChild, indent+1 );
	}
	
	
}

void Topicnet :: split(const string& s, char c, vector<string>& v) {
	string::size_type i = 0;
	string::size_type j = s.find(c);
	while (j != string::npos) {
		v.push_back(s.substr(i, j-i));
		i = ++j;
		j = s.find(c, j);
		if (j == string::npos)
			v.push_back(s.substr(i, s.length( )));
	}
}


void Topicnet :: loadArticlesData(string filepath){
	ifstream myfile;
	string filename = filepath +  "/articles_of_author.txt";
	myfile.open (filename.c_str());
	string author_id, pub_id, num_aut;
	
	
	if (!myfile){
		printf("Error in openening articles of authors file \n");
		
		printf("filepath: %s \n", filename.c_str());
	}
	else {
		while (!myfile.eof( )){ 
			myfile >> author_id >> num_aut >> pub_id;
			//string corrected = author_id+" "+num_aut+" "+pub_id;
			//printf("%s \n", corrected.c_str());
			
			
			Article * np;
			if(article_by_id.count(pub_id) > 0 ){
				np = article_by_id[pub_id];
			}
			else {
				np = new Article(pub_id, 0);
				article_by_id[pub_id] = np;
			}
			
			np -> addAuthor(author_id);
			
			if(author_by_id.count(author_id) > 0 ){
				author_by_id[author_id] -> addPub(np);
				//printf("loadArticlesData :: author: %s, pub: %s \n", author_id.c_str(), pub_id.c_str());
			}
			else {
				//printf("%s loadArticlesData :: ooops! not existing author encountered!  \n", author_id.c_str());
			}
			
			
		}
	}
	myfile.close();
	
	//after you create article objects with specific id's, now load the articles info file
	
	filename = filepath +  "/articles_Info.txt";
	myfile.open (filename.c_str());
	
	
	if (!myfile){
		printf("Error in openening articles Info file \n");
		
		printf("filepath: %s \n", filename.c_str());
	}
	else {
		
		string firstline, line;
		getline(myfile, firstline); //discard first line
		int pbs = 0;
		while (!myfile.eof( )){ 
			pbs++;
			getline(myfile, line);
			vector<string> sv; 
			split(line, '\t', sv);
				
			if (sv.size() > 0 ) {
				//printf(" %i: %s \n", pbs, sv.at(1).c_str());
			
			
				string article_id = sv.at(1);
				string title = sv.at(2);
				string venue = sv.at(4);
				
				if (article_by_id.count(article_id) > 0) {
					Article * a = article_by_id[article_id];
					a -> setTitle(title);
					a -> setVenue(venue);
				}
				
			}
			
			

		}
	}
	
}


vec3d Topicnet :: getgraphnodepos(int ind){
	if (ind>-1 && ind < graph->getSize()) {
		GraphNode * gn = graph->getGraphNode(ind);
		vec3d p = gn->getPos();
		return p;
	}
	else{
		return vec3d(0., 0., 0.);
	}
	
}

void Topicnet :: addPlane(double depth){
	Plane * newplane = new Plane(planes.size(), depth);
	planes.push_back(newplane);
}

void Topicnet :: removePlane(){
	//also need to push down all nodes on this plane
	if (planes.size() > 1) { //should not remove the first plane
		Plane * removeplane = planes.at(planes.size() - 1);
		vector<GraphNode *> putback = removeplane->nodesonplane;
		for (int p=0; p<putback.size(); p++) {
			GraphNode * pbn = putback.at(p);
			pbn -> setPosZ(0.0);
			pbn -> setPlane(0);
		}
		planes.pop_back();
	}
}




void Topicnet :: setPlaneDepth(int planeid, double depth){
	Plane * theplane = planes.at(planeid);
	if (theplane) {
		theplane -> setdepth(depth);
	}
}

double Topicnet::getPlaneDepth (int planeid){
	double depth;
	Plane * theplane = planes.at(planeid);
	if (theplane) {
		depth = theplane -> getdepth();
	}
	return depth;
}

void Topicnet :: addNodeToPlane(int planeid, int nodeid){
	
	if (planeid < 0 || planeid > planes.size()-1) {
	   printf("Topicnet :: addNodeToPlane planeid out of bounds \n");
	}
	
    GraphNode * gn = graph->getGraphNode(nodeid);
    	
	int oldplaneid = gn->getPlane();
	
	if (oldplaneid > 0) {
		//have to remove from the old plane
		//printf("oldplaneid %d \n", oldplaneid);
		Plane * oldplane = planes.at(oldplaneid);
		oldplane -> removeGraphNode(gn);
	}
	
	gn->setPlane(planeid);
	
	Plane * theplane = planes.at(planeid);
    theplane->addGraphNode(gn);
	gn->setPosZ(theplane->getdepth());
}

void Topicnet :: movePlane(int planeid, double amount){
	Plane * theplane = planes.at(planeid);
	double depth = theplane -> getdepth();
	depth += amount;
	theplane -> setdepth(depth);
	
	//move all the nodes on the plane with it 
	for (int n=0; n<theplane->nodesonplane.size(); n++) {
		GraphNode * gn = theplane->nodesonplane.at(n);
		gn->setPosZ(depth);
	}

}


void Topicnet :: bringN1(int nodeid){
	GraphNode * gn = graph->getGraphNode(nodeid);
	int nodesplane = gn->getPlane();
	Plane * pln = planes.at(nodesplane);
	
	
	vector<GraphNode * > nghnodes = graph -> firstNghbrs(nodeid);
	vector<GraphNode * > interimnodes; 
	
	bool interim = false;
	
	double oldplanedepth;
	
	for (int n=0; n<nghnodes.size(); n++) {
		
		vec3d point = nghnodes.at(n)->getPos();
		
		
		//check if the node is already sitting on a plane
		int crrplane = nghnodes.at(n)->getPlane();
		
		if (crrplane > 0) {
			//then has to create and intermediary
			interim = true;
			interimnodes.push_back(nghnodes.at(n));
			oldplanedepth = planes.at(crrplane) -> getdepth();
		}
		
		point.z = pln->getdepth();
		nghnodes.at(n)->setPos(point);
		
		nghnodes.at(n)->setPlane(pln->getplaneid());
		pln -> addGraphNode(nghnodes.at(n));
	}
	
	if (interim) {
		//move interim nodes to a middle plane
		//for now I assume the depth of middle plane to be 2.0
		
		double middepth = (oldplanedepth + pln->getdepth()) * 0.5;
		//printf("mid depth = %f \n", middepth);
		addPlane(middepth);
		Plane * interp = planes.back();
		
		for (int it=0; it<interimnodes.size(); it++) {
			GraphNode * ign = interimnodes.at(it);
			
			int oldplaneid = ign->getPlane();
			
			if (oldplaneid > 0) {
				Plane * oldplane = planes.at(oldplaneid);
				oldplane -> removeGraphNode(gn);
			}
			
			ign->setPlane(interp->getplaneid());
			interp->addGraphNode(ign);
			ign->setPosZ(interp->getdepth());
		}
		
	}
}


void Topicnet :: setgraphnodepos(int ind, vec3d p){
	if (ind>-1 && ind < graph->getSize()) {
		GraphNode * gn = graph->getGraphNode(ind);
		gn -> setPos(p);
	}
}

string Topicnet :: graphnodelabel(int ind){
	if (ind>-1 && ind < graph->getSize()) {
		GraphNode * gn = graph->getGraphNode(ind);
		string lab = gn->getLabel();
		return lab;
	}
	else{
		string l = "na";
		return l;
	}
	
}

void Topicnet :: initgraphlayout(){
	layoutScheme.calculateK(graph);
}

void Topicnet :: steplayout(bool threed, double cool){
	layoutScheme.step(threed, cool, graph, grid);
}

void Topicnet :: dolayout(){
	layoutScheme.layout(graph, grid);
}

void Topicnet :: getgraphnodegridindex(int gind, int &i, int &j, int &k){
	GraphNode * gn = graph->getGraphNode(gind);
	grid->getgridindex(gn->getPos(), i, j, k);
}


void Topicnet :: drawgraph(){
	
	//grid->drawGrid();
	graph -> draw();
}
