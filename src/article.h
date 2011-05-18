/*
 *  article.h
 *  topicNet
 *
 *  Created by basak alper on 5/16/11.
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
	Article(string idd);
	~Article();
	
	string getId() { return article_id; }
	
	void setTitle(string tit) {title = tit; }
	string getTitle(){ return title; }
	
	void setVenue(string ven) {venue = ven; }
	string getVenue(){ return venue; }
	
	int numAuthors() { return num_authors; }
	vector<string>  authorsList(){return authors;}
	
	void addAuthor (string a);
	string getAuthor (int t);  
	
	
private:
	vector<string> authors; 	
	string article_id;
	string title;
	string venue;
	int num_authors;
	
	
	
};

#endif //ARTICLE_H