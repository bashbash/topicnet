/*
 *  lua_topnet.cpp
 *  topicNet
 *
 *  Created by basak alper on 5/21/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */


#include "lua_topnet.h"

#ifdef __cplusplus
extern "C" {
#endif
	
#include "lua.h"
#include "lauxlib.h"
	
#ifdef __cplusplus
}
#endif

#include "lua_topnet_udata.h"
#include "topnet_udata.h" 

void topicnet_opentable(lua_State *L) {
	
	Topicnet_udata::init_udata(L);
}

#ifdef __cplusplus
extern "C" {
#endif
	
	int luaopen_topicnet(lua_State *L) {
		lua_getfield(L, LUA_REGISTRYINDEX, "L");
		if (!lua_isthread(L, -1)) {
			lua_pushthread(L);
			lua_setfield(L, LUA_REGISTRYINDEX, "L");
		}
		lua_pop(L, 1);
		
		
		lua_newtable(L);
		lua_setglobal(L, TOPICNET_MODULE_NAME);
		topicnet_opentable(L);
		
		lua_getglobal(L, TOPICNET_MODULE_NAME);
		
		luaL_newmetatable(L, TOPICNET_UDATA_LIB_META);
		
		//init instance counting field used in __gc for tracking
		//multiple instances of the same variable
		lua_pushstring(L, TOPICNET_UDATA_INSTANCES_METAFIELD);
		lua_newtable(L);
		
		if(luaL_newmetatable(L, TOPICNET_UDATA_INSTANCES_META)) {
			//make the instances table a weak table
			//(should make instances table its own meta instead)
			lua_pushstring(L, "__mode");
			lua_pushstring(L, "v");
			lua_settable(L, -3);
		}
		
		lua_setmetatable(L, -2);
		lua_settable(L, -3);
		lua_setmetatable(L, -2);
		
		return 1;
	}
	
#ifdef __cplusplus
}
#endif
