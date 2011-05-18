/*
 *  lua_topicnet.h
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */


#ifdef __cplusplus
extern "C" {
#endif
	
#include "lua.h"
#include "lauxlib.h"
#include "stdlib.h"
	
	
	extern int luaopen_topicnet(lua_State *L);
	
	
	
	
#ifdef WIN32
	
#include <windows.h>
	
#pragma comment( lib, "winmm.lib")
#pragma comment( lib, "opengl32.lib" )
#pragma comment( lib, "glu32.lib" )
	
#endif
	
#ifdef __cplusplus
}
#endif