/*
 *  article.cpp
 *  iv04parser
 *
 *  Created by basak alper on 2/10/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#include "article.h"

Article :: Article()
:	article_id(""), num_authors(0.0)
{
}

Article :: Article(string artid, int num) 
:	article_id(artid), num_authors(num)
{
	authors.clear();
}


void Article :: addAuthor (string a){
	authors.push_back(a);
}
string Article :: getAuthor (int t){
	return authors.at(t);
}
