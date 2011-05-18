/*
 *  article.h
 *  iv04parser
 *
 *  Created by basak alper on 2/10/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#ifndef ARTICLE_H
#define ARTICLE_H 1

#include <vector>
#include <string>

using namespace std;


class Article {
	
public:
	
	Article();
	Article(string idd, int num_auth);
	~Article();
	
	string getId() { return article_id; }
	int numAuthors() { return num_authors; }
	vector<string>  authorsList(){return authors;}
	
	void addAuthor (string a);
	string getAuthor (int t);  
	
		
private:
	vector<string> authors; 	
	string article_id;
	int num_authors;
	
	
	
};

#endif //ARTICLE_H

