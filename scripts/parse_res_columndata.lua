local gl = require("opengl")
local GL = gl
local glu = require("opengl.glu")
-------------------------------------------------


local sketch = require("opengl.sketch")
local osc = require("osc")
-------------------------------------------------

local context = "parse results"
win = Window{
	title = context, 
	origin = {0, 0}, 
	dim = {600, 480},
	mousemove = true,
}

win.sync = true

win.clearcolor = {0.8, 0.8, 0.8}

---------------------------------------------------

local USERNUM = 16


local Label = require("Label")

local labels = Label{
	ctx = context,
	--fontfile = LuaAV.findfile("Universe55.ttf"),
	--alignment = "LEFT",
	size = 22,
	--bg = true
}
-------------------------------------------------
local
anskeys = { 1, 2, 2, 1, 1, 1, 2, 1, 2, 2, 1, 2,
			3, 2, 3, 1, 2, 3, 2, 1, 1, 2, 3, 3,
			1, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1,
			2, 1, 1, 2, 2, 2, 1, 2, 1, 1, 2, 2,
			2, 3, 2, 1, 1, 1, 3, 2, 1, 2, 2, 1
		}

	
local conditions = {}
conditions[1] = {"2D", "3D", "2.5D", "2.5DH"}
conditions[2] = {"3D", "2D", "2.5DH", "2.5D"}
conditions[3] = {"2D", "3D", "2.5DH", "2.5D"}
conditions[4] = {"3D", "2D", "2.5D", "2.5DH"}

conditions[5] = {"2.5D", "2.5DH", "2D", "3D"}
conditions[6] = {"2.5D", "2.5DH", "3D", "2D"}
conditions[7] = {"2.5DH", "2.5D", "3D", "2D"}
conditions[8] = {"2.5DH", "2.5D", "2D", "3D"}

conditions[9] =  {"2D", "2.5DH", "2.5D", "3D"}
conditions[10] = {"2D", "2.5D", "2.5DH", "3D"}
conditions[11] = {"3D", "2.5D", "2.5DH", "2D"}
conditions[12] = {"3D", "2.5DH", "2.5D", "2D"}

conditions[13] = {"2.5DH", "2D", "3D", "2.5D"}
conditions[14] = {"2.5DH", "3D", "2D", "2.5D"}
conditions[15] = {"2.5D", "2D", "3D", "2.5DH"}
conditions[16] = {"2.5D", "3D", "2D", "2.5DH"}

local viscond = {}
    viscond["2.5D"] = 1
    viscond["2.5DH"] = 2
	viscond["2D"] = 3
	viscond["3D"] = 4
local Results = {}

-------------------------------------------------

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


local
function readresultsfile(user, res)
    Results[user] = {}
    
    local condisyon = conditions[user]
    
    local path = script.path .. "/results"
    local filename = "p" .. user .. "_res.txt"
    --print(filename)
    
    local fname = LuaAV.findfileinpath(path, filename, true)
	--print(fname)
	
	local f = io.open(fname, "r")
	
	local lineNum = 0
	if f then
		for line in f:lines() do 
	    	lineNum = lineNum + 1
	    	if(lineNum > 3) then 
	    		local parts = line:split( "[^,%s]+" )
	    		local pos = {parts[1], parts[2], parts[3]}
	    		--print(lineNum, parts[1], parts[2], parts[3])
	    		local quest = parts[1]
	    		local ind = ((quest-1) % 4) + 1
	    		local cond = condisyon[ind]
	    		local condnum = viscond[cond]
	    		local time = parts[3]
	    		local truefalse
	    		local answer = tonumber(parts[2])
	    		local qnum = lineNum - 3
	    		
	    		print(user, qnum, cond, condnum)
	    		
    
	    		if(anskeys[qnum] == answer) then 
	    			truefalse = "0"
	    			
	    		elseif(anskeys[qnum] ~= answer) then 
	    			truefalse = "-1"
	    			--print(qnum, cond, anskeys[qnum], parts[2])
	    		end
	    		
	    		
	    		
	    		local task = math.floor((qnum-1) / 12) + 1
	    		
	    		local exists = 1
	    		if(task == 1 or task == 3 or task == 4) then 
	    			if(anskeys[qnum] == 2) then exists = 0 end 
	    		end
	    		
	    		
    
	    		local dataset = qnum -( 3 * math.floor(qnum / 3) )
                if(dataset == 0 ) then dataset = 3 end
                
                --print(dataset)
                
                if(task == 4) then 
                	if(condnum == 3) then 
                		condnum = 2
                	elseif (condnum == 2) then 
                		condnum = 3
                	end
                end
                
                if(task == 4) then 
                	if(condnum == 3) then 
                		time = time + 3
                	elseif (condnum == 4) then 
                	   time = time + 2
                	end
                end
                
                --print(user, task, condnum, dataset)
                --Results[user][task][condnum][dataset] = {time, truefalse}
                
	    		
	    		--Results[user][qnum] = {user, cond, quest, task, truefalse, time, exists}
	    		Results[user][qnum] = user.."\t"..quest.."\t".. exists.."\t".. dataset.."\t"..task.."\t"..condnum.."\t"..truefalse.."\t"..time
	    		
	    	end
	    end
	end
	
	f:close()
	
end
-------------------------------------------------

for i=1, USERNUM do 
	readresultsfile(i)
end


local
function saveRowOrderedCVSfile()
	local filename = "allResultsColumn.txt"
	local path = script.path .. "/results"
    local fname = LuaAV.findfileinpath(path, filename, true)
    
    
    
    
	local f = io.open(fname, "w")
	
	if f then    
		f:write("user \t quest \t exists \t dataset \t task \t condnum \t truefalse \t time \n")
		
		for p=1, USERNUM do 
			for q=1, 60 do 
				f:write(Results[p][q], "\n")
			end	
		end
	end
	
	f:close()
	
end


saveRowOrderedCVSfile()


local
function saveCVSfile()
	local filename = "allResultsRow.txt"
	local path = script.path .. "/results"
    local fname = LuaAV.findfileinpath(path, filename, true)
	
	local f = io.open(fname, "w")
	
	if f then
	    
	    f:write("user \t quest \t exists \t dataset \t cond \t task \t answer \t time \n")
	    
		for p=1, USERNUM do 
			for q=1, 60 do
			--print ( unpack(Results[p][q]))
			f:write(Results[p][q], "\n")
			end
		end
	end
	
	f:close()
	
end

--saveCVSfile()

function win:draw()
    
		sketch.enter_ortho(self.dim)
		
		
		
		sketch.leave_ortho()
		
	
end


-------------------------------------------------

function win:key(event, key)
     --print(key)
	 if(event == "down") then
		if(key == 27) then
		    self.fullscreen = not self.fullscreen
		    --oscout:send("/fullscr", 1)
		    print("/fullscr")
		elseif (key == 115) then --S save emergency
			--saveresultsfile()
		end
	end
end

-------------------------------------------------

function win:mouse(event, btn, x, y, nclk)
	lastx, lasty = x, y
end

-------------------------------------------------

function win:resize()
	
end

-------------------------------------------------

function win:modifiers()
	
end

-------------------------------------------------






