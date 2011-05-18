Project{
	name = "topicnet",
	type = "module",
	path = Path{modulesfolder, "topicnet"},
	
	cflags = table.combine({
			"-DOSC_HOST_LITTLE_ENDIAN",
-- TODO: I wasn't sure how to make this dependent on 64 bit:
		--	"-Dx86_64",
		},
		platform.cflags
	),	
	
	ldflags = table.combine(
		platform.so_ldflags,
		platform.ldflags
	),
	

	include_search_paths = table.combine({
			Path{"src", relative = true},
			Path{"src/Module", relative = true},
			--Path{modulesfolder.."/Muro/src/glo/GLEW/GL"},
			--Path{modulesfolder.."/Muro"},
            
		}, 

		({
			OSX = {},
			LINUX = {
				Path{"/usr/include/lua5.1"},
			},
			WIN32 = {},
		})[OS],

		platform.include_search_paths
	),
	
	linker_search_paths = {},
	
	dependencies = {
		Dependency{
			name = "muro",
			path = "/usr/local/lib",
			type = "shared",
		},
	},
	
	src = {
	    Path{"src/FR_Layout.cpp", relative = true},
	    Path{"src/graph.cpp", relative = true},
	    Path{"src/graphEdge.cpp", relative = true},
	    Path{"src/graphNode.cpp", relative = true},
		Path{"src/grid.cpp", relative = true},
        Path{"src/gridNode.cpp", relative = true},
        Path{"src/plane.cpp", relative = true},
		
		Path{"src/tinystr.cpp", relative = true},
		Path{"src/tinyxml.cpp", relative = true},
		Path{"src/tinyxmlerror.cpp", relative = true},
		Path{"src/tinyxmlparser.cpp", relative = true},
		Path{"src/untitled.cpp", relative = true},
        
        Path{"src/lua_topnet.cpp", relative = true},
		Path{"src/topnet_udata.cpp", relative = true},
		Path{"src/topnet.cpp", relative = true}
		
},
	
	Debug = Config{
		cflags = platform.Debug.cflags,
		install_path = Path{reporoot, "sysbuild/Debug/modules"},
	},
	
	Release = Config{
		cflags = platform.Release.cflags,
		install_path = Path{reporoot, "sysbuild/Release/modules"},
	},
}