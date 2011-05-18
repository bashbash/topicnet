/*
 *  Author.cpp
 *  iv04parser
 *
 *  Created by basak alper on 5/13/11.
 *  Copyright 2011 ucsb. All rights reserved.
 *
 */

#include "Author.h"


Author :: Author()
:	author_id(""), num_pubs(0.0)
{
}

Author :: Author(string aid) 
:	author_id(aid)
{
	pubs.clear();
}


void Author :: addPub (string a){
	pubs.push_back(a);
}
string Author :: getPub (int t){
	return pubs.at(t);
}
