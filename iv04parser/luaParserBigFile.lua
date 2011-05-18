
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


local pubs = {}
local lineNum = 0

local
function loadBigData()
    local path = script.path .. "/iv04/additional/tableform_data/"
    print("path  ", path)
    
    local fileN = "Big_data.txt"
    
	local fname = LuaAV.findfileinpath(path, fileN, true)
	local f = io.open(fname, "r")
	
	print("fio: ?? ", f)
	
	
	if f then
		print("file open")
		for line in f:lines() do 
	    	lineNum = lineNum + 1
	    	local parts = line:split( "[^,\t]+" )
	    	pubs[lineNum] = {parts[1], parts[2], parts[3], parts[4]}
	    	
	    	--print(parts[3], parts[4])
	    	
	    end
	end
	
	f:close()
end

loadBigData()


local
function saveArticles()
    local path = script.path .. "/iv04/additional/tableform_data/"
    
    local fileN = "articlesInfo.txt"
	local fname = LuaAV.findfileinpath(path, fileN, true)
	local f = io.open(fname, "w")
	print("fio write: ", f)
	
	for l=1, lineNum do
		local p = pubs[l]
        f:write(l,"\t", p[1],"\t", p[2],"\t",  p[3],"\t",  p[4],"\n")
	end
	f:close()
end

saveArticles()
