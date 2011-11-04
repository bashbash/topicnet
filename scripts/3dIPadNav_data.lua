require("topicnet")
local TopNet = topicnet.Topicnet


tpd = TopNet()

local data1 = "/data/coauthor_small.xml"
local data2 = "/data/coauthor_mid.xml"
local data3 = "/data/coauthor_large.xml"

local activedata = 3



local sourcepath1 = script.path .. data1
local sourcepath2 = script.path .. data2
local sourcepath3 = script.path .. data3
local sources = {sourcepath1, sourcepath2, sourcepath3}

tpd:loadData(sources[activedata], "author")

------------------Save Data----------------------
function saveGraph()
    local path = script.path .. "/data"
    
    local fileN = "graph".. activedata .."_pos.txt"
    if(layout3d) then fileN = "graph" .. activedata .."_3Dpos.txt" end
    
   
    --print("path  ", path)
	local fname = LuaAV.findfileinpath(path, fileN, true)
	--print("savegraph", fname)
	local f = io.open(fname, "w")
	--print(f)
	
	for s=1, tpd:graphsize() do
		local ind = s-1
	    local p = tpd:graphnodepos(ind)
        f:write(ind," ", p[1]," ", p[2]," ",  p[3], "\n")
	end
	f:close()
end


string.split = function(str, pattern)
  pattern = pattern or "[^%s]+"
  if pattern:len() == 0 then pattern = "[^%s]+" end
  local parts = {__index = table.insert}
  setmetatable(parts, parts)
  str:gsub(pattern, parts)
  setmetatable(parts, nil)
  parts.__index = nil
  return parts
end


function loadGraph()
    local path = script.path .. "/data"
    --print("path  ", path)
    
    local fileN = "graph" .. activedata .. "_pos.txt"
    if(layout3d) then fileN = "graph" .. activedata .. "_3Dpos.txt" end
    
    
	local fname = LuaAV.findfileinpath(path, fileN, true)
	--print("loadgraph", fname)
	local f = io.open(fname, "r")
	--print(f)
	
	local lineNum = 0
	if f then
		--print("file open")
		for line in f:lines() do 
	    	lineNum = lineNum + 1
	    	local parts = line:split( "[^,%s]+" )
	    	local pos = {parts[2], parts[3], parts[4]}
	    	--print(parts[1], parts[2], parts[3], parts[4])
	    	tpd:graphnodepos(parts[1], pos)
	    end
	end
	
	f:close()
end