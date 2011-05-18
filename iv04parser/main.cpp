#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <map>
#include "graph.h"
#include "article.h"
#include "Author.h"
using namespace std;

typedef map <string, string> DuplicatesMap;
DuplicatesMap duplicates;


typedef map <string, string> NamesMap;
NamesMap author_id_name;

Graph * g;
vector<Article * > articles;
vector<Author * > authors;

typedef map <string, Article*> ArticlesMap;
ArticlesMap article_id_art;


typedef map <string, Author*> AuthorsMap;
AuthorsMap author_by_id;


typedef map <string, GraphNode*> GraphNodeMap;
GraphNodeMap gnode_by_id;

vector<GraphEdge *> edges;
vector<GraphNode *> nodes;

typedef map <string, GraphEdge*> EdgeMap;
EdgeMap edges_by_ids;

inline std::string trim_right(const std::string &source , const std::string& t = " ")
{
	std::string str = source;
	return str.erase( str.find_last_not_of(t) + 1);
}

inline std::string trim_left( const std::string& source, const std::string& t = " ")
{
	std::string str = source;
	return str.erase(0 , source.find_first_not_of(t) );
}

inline std::string trim(const std::string& source, const std::string& t = " ")
{
	std::string str = source;
	return trim_left( trim_right( str , t) , t );
} 

void loadDuplicatesFile() {
	ifstream myfile;
	myfile.open ("../../iv04/additional/duplicate_author_map.txt");
	string duplicate, original, name;
	
	if (!myfile){
		printf("Error in openening names file \n");
	}
	else {
		string firstline;
		getline(myfile, firstline); //discard first line
		
		while (!myfile.eof( )){ 
			myfile >> duplicate >> original;
			getline(myfile, name);
			duplicates[duplicate] = original;
			author_id_name [original] = name;
			//printf("name: %s, dup: %s, orig: %s \n", name.c_str(), duplicate.c_str(), original.c_str());
		}
	}
	myfile.close();
	
}


void loadArticlesByAuthor() {
	
	ofstream outfile;
	outfile.open ("../../iv04/additional/tableform_data/articles_by_author_dupcorrect.txt");
	
	
	ifstream myfile;
	myfile.open ("../../iv04/additional/tableform_data/articles_by_author.txt");
	string article_id, author_id, num_author, author;
	
	if (!myfile || !outfile){
		printf("Error in openening names file \n");
	}
	else {
		string firstline;
		getline(myfile, firstline); //discard first line
		
		while (!myfile.eof( )){ 
			myfile >> article_id >> num_author >> author_id;
			getline(myfile, author);
			
			if ( duplicates.count(author_id)>0 ) { 
				//this author has a duplicate
				
				author_id = duplicates[author_id];
				
				//printf("duplicate replaced %s by %s \n", author.c_str(), author_id_name[author_id].c_str() );
				
				author = author_id_name[author_id];
			}
			else{
				//get rid of white space in front of author and end of line at the end if it has one
				author = trim(author);
				author_id_name[author_id] = author;
			}
			
			
			
			
			
			
			string corrected = article_id+" "+num_author+" "+author_id+" "+author;
			//printf("%s \n", corrected.c_str());
			outfile << article_id <<" "<< num_author <<" "<< author_id <<" "<< author << endl;
		}
	}
	myfile.close();
	outfile.close();
	
}

void testdupcorrectfile(){
	ifstream myfile;
	myfile.open ("../../iv04/additional/tableform_data/articles_by_author_dupcorrect.txt");
	string article_id, num_author, author_id, author;
	
	if (!myfile){
		printf("Error in openening names file \n");
	}
	else {
		while (!myfile.eof( )){ 
			myfile >> article_id >> num_author >> author_id;
			getline(myfile, author);
			string corrected = article_id+" "+num_author+" "+author_id+" "+author;
			printf("%s \n", corrected.c_str());
		}
	}
	myfile.close();
	
}

void createDataStructures(){
	ifstream myfile;
	myfile.open ("../../iv04/additional/tableform_data/articles_by_author_dupcorrect.txt");
	string article_id, author_id, authorname;
	int num_author;
	
	if (!myfile){
		printf("createDataStructures:: Error in openening file \n");
	}
	else {
		while (!myfile.eof( )){ 
			myfile >> article_id >> num_author >> author_id;
			getline(myfile, authorname);
			
			if ( author_id_name.count(author_id)>0 ) { 
			}
			else{
				author_id_name[author_id] = authorname;
				author_by_id[author_id] = new Author(author_id);
				authors.push_back(author_by_id[author_id]);
			}
			
			/*
			
			if( article_id_art.count(article_id) > 0) {
			}
			else {
				article_id_art[article_id] = new Article(article_id, num_author);
				articles.push_back(article_id_art[article_id]);
			}
			
			*/
			//Article * a = article_id_art[article_id];
			//Author * auth = author_by_id[author_id]; 
			
			//a-> addAuthor(author_id);
			//auth -> addPub(article_id);
		}
	}
	myfile.close();
	
}

void testDataStructures(){
	printf("number of unique authors: %d \n", (int)author_id_name.size());
	printf("number of unique articles: %d \n", (int)article_id_art.size());
	
	printf("created authors: %d \n", (int) authors.size());
	
	Article * lastarticle = articles.back();
	vector<string> lastauthors = lastarticle->authorsList();
	
	for (int s=0; s < lastauthors.size(); s++) {
		printf("author %d is: %s \n", s+1, lastauthors.at(s).c_str());
	}
	
	Author * lastauthor = authors.back();
	vector<string> lastauthpubs = lastauthor->pubsList();
	
	for (int p=0; p < lastauthpubs.size(); p++) {
		printf("pubs %d is: %s \n", p+1, lastauthpubs.at(p).c_str());
	}
	
}

void createGraphDataStructures(){
	//create graph nodes
	map<string, string>::iterator auth;
	
	for(auth = author_id_name.begin(); auth != author_id_name.end(); auth++) {
		string idd = auth->first;
		string authorname = auth->second;
		int idpos = nodes.size();
		GraphNode * anewnode = new GraphNode (idpos, idd, authorname);
		gnode_by_id[idd] = anewnode;
		nodes.push_back(anewnode);
	}
	
	//now create edges
	map<string, Article*>::iterator art;
	for(art = article_id_art.begin(); art != article_id_art.end(); art++) {
		string articleid = art->first;
		Article* thearticle = art->second;
		
		vector<string> auths = thearticle->authorsList();
		//for each author in an article, create an edge connecting that to the rest
		
		for (int s= 0; s<auths.size(); s++) {
			string auth1 = auths.at(s);
			
			for (int rest=s+1; rest<auths.size(); rest++) {
				string auth2 = auths.at(rest);
				
				if (auth1 == auth2) {
					printf("ERROR: author duplicate %s \n", auth1.c_str());
				}
				
				
				//create an edge between aut1 and aut2
				//but...
				//need to prevent duplicates
				
				string edgekey1 = auth1+auth2;
				string edgekey2 = auth2+auth1;  //whichever encountered before, we don't know
				
				
				if (edges_by_ids.count(edgekey1) > 0 || edges_by_ids.count(edgekey2) > 0 ) {
					//this edge exists
				}
				else{
					int posid = edges.size();
					GraphEdge * anewedge = new GraphEdge(posid, auth1, auth2);
					edges.push_back(anewedge);
					
					edges_by_ids[edgekey1] = anewedge;
					edges_by_ids[edgekey2] = anewedge;
					
				}
				
				
			}
			
		}
	}
	
	//now print all edges
	//printf("all number of edges created % d \n ", (int)edges.size());
	
	//edges sanity check
	/*
	for (int e=0; e<edges.size(); e++) {
		GraphEdge * edg = edges.at(e);
		string efrom =  edg->from;
		string eto =  edg->to;
		for (int c=0; c<edges.size(); c++) {
			GraphEdge * compare = edges.at(c);
			if (compare->from == efrom && compare->to == eto) {
				if (e != c) {
					printf("duplicate at: %d, %d \n", e, c);
				}
				
			}
		}
		
		//printf("edge id: %d, from: %s, to: %s \n", edg->getEdgeid(), edg->from.c_str(), edg->to.c_str());
	}
	 */
	
}


ofstream xmloutfile;
ofstream xmlpuboutfile;

void printNode(GraphNode * g){
	string thenodeid = trim(g->getNodeid(), "\t");
	xmloutfile << "\t\t\t<DNVNODE IntId=\""<< g->getIntid() << "\" Id=\"" << g->getNodeid() << "\" Label=\"" << g->getLabel() << "\"";
	xmloutfile <<" />" << endl;	
}

void printEdge(GraphEdge * edg){
	
	xmloutfile << "\t\t\t<DNVEDGE Id=\""<< edg->getEdgeid() << "\" To=\"" << edg->to << "\" From=\"" << edg->from << "\"";
	xmloutfile <<" />" << endl;	
}

void outputGraphXML(){
	//ofstream xmloutfile;
	xmloutfile.open ("../../iv04/additional/xmlform_data/co_author_graph.xml");
	
	if (!xmloutfile) {
		printf("ERROR OPENING OUTPUT XML FILE \n");
	}
	else{
		
		int numnodes = nodes.size();
		int numedges = edges.size();
		
		xmloutfile << "<?xml version=\"1.0\" standalone=\"no\" ?>" << endl;
		xmloutfile << "\t<DNVGRAPH>" << endl;
        xmloutfile << "\t\t <Level value=\"0\" numberOfNodes=\" " << numnodes <<"\" numberOfEdges=\"" << numedges <<"\">" << endl;
		
		//output nodes
		for_each(nodes.begin(), nodes.end(), printNode);
		
		
		//output edges
		for_each(edges.begin(), edges.end(), printEdge);
				
		
	}
	xmloutfile.close();
}



void printPubs(Author * theat){
	vector<string> pubs = theat->pubsList();
	
	string auid = theat -> getId();
	
	//xmlpuboutfile << auid << "\t" << pubs.size() << "\t";
	
	for(int ps=0; ps<pubs.size(); ps++){
		xmlpuboutfile << auid << "\t" << pubs.size() << "\t" << pubs.at(ps) << endl;
	}
	
	//xmlpuboutfile << endl; 
	
}

void outputArticlesXML(){
	//ofstream xmloutfile;
	xmlpuboutfile.open ("../../iv04/additional/xmlform_data/articles.xml");
	
	if (!xmloutfile) {
		printf("ERROR OPENING OUTPUT XML FILE \n");
	}
	else{
		
		int numauth = authors.size();
		xmlpuboutfile << "author_id \t num_pubs \t pubs " << endl;
		for_each(authors.begin(), authors.end(), printPubs);
		
	}
	xmlpuboutfile.close();
}


int main (int argc, char * const argv[]) {
	
	
	//loadDuplicatesFile();
	//loadArticlesByAuthor();
	//testdupcorrectfile();
	
	createDataStructures();
	testDataStructures();
	createGraphDataStructures();
	
	outputArticlesXML();
	
	//outputGraphXML();
	
	return 0;
}
