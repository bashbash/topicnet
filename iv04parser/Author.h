/*
 *  Author.h
 *  iv04parser
 *
 *  Created by basak alper on 5/13/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */


#ifndef AUTHOR_H
#define AUTHOR_H 1

#include <vector>
#include <string>

using namespace std;


class Author {
	
public:
	
	Author();
	Author(string idd);
	~Author();
	
	string getId() { return author_id; }
	int numPubs() { return num_pubs; }
	vector<string>  pubsList(){return pubs;}
	
	void addPub (string p);
	string getPub (int t);  
	
	
private:
	vector<string> pubs; 	
	string author_id;
	int num_pubs;
	
	
	
};

#endif //AUTHOR_H

