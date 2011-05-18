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
function preprocessresultsfile(user, res)
    Results[user] = {}
   
    
    --tasks
    for t=1, 5 do 
        
        Results[user][t] = {}
        
        --conditions
    	for c=1, 4 do
    		
    		Results[user][t][c] = {}
    		
    		--datasets
    		for d=1, 3 do
    		
    			Results[user][t][c][d] = {}  -- will hold time and accuracy
    		
    		end
    	end
    end
    
    local condisyon = conditions[user]
    
    local path = script.path .. "/results"
    local filename = "p" .. user .. "_res.txt"
    
    local outfname = "p" .. user .. "_resExt.txt"
    --print(filename)
    
    local fname = LuaAV.findfileinpath(path, filename, true)
	--print(fname)
	
	local f = io.open(fname, "r")
	local fout = io.open(outfname, "w")
	
	fout:write("quest \t dataset \t task \t cond \t anskey \t answer \t truefalse \t time \n")
	
	
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
	    		
	    		--local dataset = math.floor((qnum-1) /4) + 1
                --dataset = dataset - (3*(task-1))
                
                local dataset = qnum -( 3 * math.floor(qnum / 3) )
                if(dataset == 0 ) then dataset = 3 end
                
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
                
                Results[user][task][condnum][dataset] = {time, truefalse}
                local line = quest.."\t".. dataset.."\t"..task.."\t"..condnum.."\t"..anskeys[qnum].."\t"..answer.."\t" ..truefalse.."\t"..time
                fout:write(line, "\n")
	    		
	    		--Results[user][qnum] = {user, cond, quest, task, truefalse, time, exists}
	    		--Results[user][qnum] = user.."\t"..quest.."\t".. exists.."\t".. dataset.."\t"..condnum.."\t"..task.."\t"..truefalse.."\t"..time
	    		
	    	end
	    end
	end
	
	f:close()
	fout:close()
	
end
-------------------------------------------------




local
function readresultsfile(user, ftype)
    
    
    Results[user] = {}
    
    if(ftype == "row") then
		--tasks
		for t=1, 5 do 
			Results[user][t] = {}
			--conditions
			for c=1, 4 do
				Results[user][t][c] = {}
				--datasets
				for d=1, 3 do
					Results[user][t][c][d] = {}  -- will hold time and accuracy
				end
			end
		end
    
    end
    
    local path = script.path .. "/results"
    local filename = "p" .. user .. "_resExt.txt"
    local fname = LuaAV.findfileinpath(path, filename, true)
	--print(fname)
	
	local f = io.open(fname, "r")
	
	local lineNum = 0
	if f then
		for line in f:lines() do 
	    	lineNum = lineNum + 1
	    	if(lineNum > 1) then 
	    		local parts = line:split( "[^,%s]+" )
	    		
	    		local quest = tonumber(parts[1])
	    		local dataset = tonumber(parts[2])
	    		local task = tonumber(parts[3])
	    		local cond = tonumber(parts[4])
	    		local acc = tonumber(parts[7])
	    		local time = tonumber(parts[8])
	    		
	    		if(ftype == "row") then 
                	Results[user][task][cond][dataset] = {time, acc}
                	--print(user, task, cond, dataset, " : ", time, acc)
                elseif(ftype == "col") then 
                	Results[user][quest] = user.."\t"..quest.."\t".. dataset.."\t"..task.."\t"..cond.."\t"..acc.."\t"..time
                	--print(user, task, cond, dataset, " : ", time, acc)
                end
                
	    		--Results[user][qnum] = {user, cond, quest, task, truefalse, time, exists}
	    		--Results[user][qnum] = user.."\t"..quest.."\t".. dataset.."\t"..task.."\t"..cond.."\t"..acc.."\t"..time
	    		
	    	end
	    end
	end
	
	f:close()
	
	
end
-------------------------------------------------




local
function saveRowOrderedCVSfile()
	local filename = "allResRowAcc.txt"
	local path = script.path .. "/results"
    local fname = LuaAV.findfileinpath(path, filename, true)
    
    local labels = "user \t" 
    
    
	local f = io.open(fname, "w")
	
	if f then
	    
	     --tasks
		for t=1, 5 do 
			--conditions
			for c=1, 4 do
				--datasets
				for d=1, 3 do
					labels = labels .."tsk:"..t..", c:"..c..", d:"..d.."\t"
				end
			end
		end
    
        f:write(labels, "\n")
	    
		for p=1, USERNUM do 
			local userline = "p"..p.."\t"
			--tasks
			for t=1, 5 do 
				--conditions
				for c=1, 4 do
					--datasets
					for d=1, 3 do
						local acc = Results[p][t][c][d][2]
						print(p, t, c, d, ": ", acc)
						userline = userline..acc.."\t"
					end
				end
			end
			
			f:write(userline, "\n")
		end
	end
	
	f:close()
	
end


local
function saveColOrderedCVSfile()
	local filename = "allResColTime.txt"
	local path = script.path .. "/results"
    local fname = LuaAV.findfileinpath(path, filename, true)
	
	local f = io.open(fname, "w")
	
	if f then
	    
	    f:write("user \t quest  \t dataset \t task \t cond \t answer \t time \n")
	    
		for p=1, USERNUM do 
			for q=1, 60 do
			f:write(Results[p][q], "\n")
			end
		end
	end
	
	f:close()
	
end



for i=1, USERNUM do 
	--preprocessresultsfile(i)
	readresultsfile(i, "row")
end



saveRowOrderedCVSfile()
--saveColOrderedCVSfile()


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






