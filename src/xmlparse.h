/*
 *  xmlparse.h
 *  topicNet
 *
 *  Created by basak alper on 5/30/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef XMLPARSE_H
#define XMLPARSE_H 1

#include <map>
#include "tinyxml.h"

const unsigned int NUM_INDENTS_PER_SPACE=2;

const char * getIndent( unsigned int numIndents )
{
	static const char * pINDENT="                                      + ";
	static const unsigned int LENGTH=strlen( pINDENT );
	unsigned int n=numIndents*NUM_INDENTS_PER_SPACE;
	if ( n > LENGTH ) n = LENGTH;
	
	return &pINDENT[ LENGTH-n ];
}

// same as getIndent but no "+" at the end
const char * getIndentAlt( unsigned int numIndents )
{
	static const char * pINDENT="                                        ";
	static const unsigned int LENGTH=strlen( pINDENT );
	unsigned int n=numIndents*NUM_INDENTS_PER_SPACE;
	if ( n > LENGTH ) n = LENGTH;
	
	return &pINDENT[ LENGTH-n ];
}


enum Elements { DNVGRAPH, DNVNODE, DNVEDGE, NODEPROPERTY};
static std::map<std::string, Elements> s_mapElements;


void initializeEnums()
{
	s_mapElements["DNVGRAPH"] = DNVGRAPH;
	s_mapElements["DNVNODE"] = DNVNODE;
	s_mapElements["DNVEDGE"] = DNVEDGE;
	s_mapElements["NODEPROPERTY"] = NODEPROPERTY;
}

enum Attributes {Id, IntId, Level, Position, Color, Size, Active, Icon, Label, Mass, Fixed, Type, BBid,
				 ForceLabel, Alpha, LabelColor, LabelOutlineColor, OutlineColor, LabelSize, Expandable, Visible,
					
				 HideLabelBackground, CurvedLabel,
				
				 EdgeId, EdgeLevel, Length, Rigid, From, To, K, Directional, HasSetColor, Thickness //these are only edge attributes
};

static std::map<std::string, Attributes> s_map_attributes;

void initializeAttributeEnums()
{
	s_map_attributes["Id"] = Id;
	s_map_attributes["Level"] = Level;
	s_map_attributes["Position"] = Position;
	s_map_attributes["Color"] = Color;
	s_map_attributes["Size"] = Size;
    s_map_attributes["Active"] = Active;
	s_map_attributes["Icon"] = Icon;
    s_map_attributes["Label"] = Label;
	s_map_attributes["Mass"] = Mass;
	s_map_attributes["Fixed"] = Fixed;
	s_map_attributes["Type"] = Type;
	s_map_attributes["BBid"] = BBid;
	s_map_attributes["IntId"] = IntId;
	
	s_map_attributes["ForceLabel"] = ForceLabel;
	s_map_attributes["Alpha"] = Alpha;
	s_map_attributes["LabelColor"] = LabelColor;
	s_map_attributes["LabelOutlineColor"] = LabelOutlineColor;
	s_map_attributes["OutlineColor"] = OutlineColor;
	s_map_attributes["LabelSize"] = LabelSize;
	s_map_attributes["Expandable"] = Expandable;
	s_map_attributes["Visible"] = Visible;
	
	
	s_map_attributes["EdgeId"] = EdgeId;
	s_map_attributes["EdgeLevel"] = EdgeLevel;
	s_map_attributes["Length"] = Length;
	s_map_attributes["rigid"] = Rigid;
	s_map_attributes["From"] = From;
	s_map_attributes["To"] = To;
	s_map_attributes["K"] = K;
	s_map_attributes["Directional"] = Directional;
	s_map_attributes["HasSetColor"] = HasSetColor;
	s_map_attributes["Thickness"] = Thickness;
	
	s_map_attributes["HideLabelBackground"] = HideLabelBackground;
	s_map_attributes["CurvedLabel"] = CurvedLabel;

}

/*
enum nodeAttr { Id, Level, Position, Color, Size, Active, Icon, Label, Mass, Fixed, Type, BBid,
				ForceLabel, Alpha, LabelColor, LabelOutlineColor, OutlineColor, LabelSize, Expandable, Visible};
static std::map<std::string, nodeAttr> s_map_nodeAttr;


void initializeNodeEnums()
{
	s_map_nodeAttr["Id"] = Id;
	s_map_nodeAttr["Level"] = Level;
	s_map_nodeAttr["Position"] = Position;
	s_map_nodeAttr["Color"] = Color;
	s_map_nodeAttr["Size"] = Size;
    s_map_nodeAttr["Active"] = Active;
	s_map_nodeAttr["Icon"] = Icon;
    s_map_nodeAttr["Label"] = Label;
	s_map_nodeAttr["Mass"] = Mass;
	s_map_nodeAttr["Fixed"] = Fixed;
	s_map_nodeAttr["Type"] = Type;
	s_map_nodeAttr["BBid"] = BBid;
	
	s_map_nodeAttr["ForceLabel"] = ForceLabel;
	s_map_nodeAttr["Alpha"] = Alpha;
	s_map_nodeAttr["LabelColor"] = LabelColor;
	s_map_nodeAttr["LabelOutlineColor"] = LabelOutlineColor;
	s_map_nodeAttr["OutlineColor"] = OutlineColor;
	s_map_nodeAttr["LabelSize"] = LabelSize;
	s_map_nodeAttr["Expandable"] = Expandable;
	s_map_nodeAttr["Visible"] = Visible;
}

enum edgAttr { EdgeId, EdgeLevel, Length, Rigid, From, To, K, Label, Directional, BBid, Color,
			   HasSetColor, Alpha, LabelColor, LabelOutlineColor, LabelSize, Thickness, Visible};
static std::map<std::string, edgAttr> s_map_edgeAttr;


void initializeEdgeEnums()
{
	s_map_edgeAttr["Id"] = EdgeId;
	s_map_edgeAttr["Level"] = EdgeLevel;
	s_map_edgeAttr["Length"] = Length;
	s_map_edgeAttr["rigid"] = Rigid;
	s_map_edgeAttr["From"] = From;
	s_map_edgeAttr["To"] = To;
	s_map_edgeAttr["K"] = K;
	s_map_edgeAttr["Label"] = Label;
	s_map_edgeAttr["Directional"] = Directional;
	s_map_edgeAttr["BBid"] = BBid;
	s_map_edgeAttr["Color"] = Color;
	
	s_map_edgeAttr["HasSetColor"] = HasSetColor;
	s_map_edgeAttr["Alpha"] = Alpha;
	s_map_edgeAttr["LabelColor"] = LabelColor;
	s_map_edgeAttr["LabelOutlineColor"] = LabelOutlineColor;
	s_map_edgeAttr["LabelSize"] = LabelSize;
	s_map_edgeAttr["Thickness"] = Thickness;
	s_map_edgeAttr["Visible"] = Visible;


}

*/

typedef vector<string> StringVector;

StringVector stringsFrom( string s )
{
	replace( s.begin(), s.end(), ',', ' ' );
	istringstream stream(s);
	StringVector result;
	
	for( ;; )
	{
		string word;
		if( !( stream >> word ) ) { break; }
		result.push_back( word );
	}
	return result;
}




/*
int dump_attribs_to_stdout(TiXmlElement* pElement, unsigned int indent)
{
	if ( !pElement ) return 0;
	
	TiXmlAttribute* pAttrib=pElement->FirstAttribute();
	int i=0;
	int ival;
	double dval;
	const char* pIndent=getIndent(indent);
	printf("\n");
	while (pAttrib)
	{
		printf( "%s%s: value=[%s]", pIndent, pAttrib->Name(), pAttrib->Value());
		
		if (pAttrib->QueryIntValue(&ival)==TIXML_SUCCESS)    printf( " int=%d", ival);
		if (pAttrib->QueryDoubleValue(&dval)==TIXML_SUCCESS) printf( " d=%1.1f", dval);
		printf( "\n" );
		i++;
		pAttrib=pAttrib->Next();
	}
	return i;	
}

void dump_to_stdout( TiXmlNode* pParent, unsigned int indent = 0 )
{
	if ( !pParent ) return;
	
	TiXmlNode* pChild;
	TiXmlText* pText;
	int t = pParent->Type();
	printf( "%s", getIndent(indent));
	int num;
	
	switch ( t )
	{
		case TiXmlNode::TINYXML_DOCUMENT:
			printf( "Document" );
			break;
			
		case TiXmlNode::TINYXML_ELEMENT:
			printf( "Element [%s]", pParent->Value() );
			num=dump_attribs_to_stdout(pParent->ToElement(), indent+1);
			switch(num)
		{
			case 0:  printf( " (No attributes)"); break;
			case 1:  printf( "%s1 attribute", getIndentAlt(indent)); break;
			default: printf( "%s%d attributes", getIndentAlt(indent), num); break;
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
	printf( "\n" );
	for ( pChild = pParent->FirstChild(); pChild != 0; pChild = pChild->NextSibling()) 
	{
		dump_to_stdout( pChild, indent+1 );
	}
}

// load the named file and dump its structure to STDOUT
void dump_to_stdout(const char* pFilename)
{
	TiXmlDocument doc(pFilename);
	bool loadOkay = doc.LoadFile();
	if (loadOkay)
	{
		printf("\n%s:\n", pFilename);
		dump_to_stdout( &doc ); // defined later in the tutorial
	}
	else
	{
		printf("Failed to load file \"%s\"\n", pFilename);
	}
}
*/
#endif //XMLPARSE_H
