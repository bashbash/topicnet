local gl = require("opengl")
local GL = gl
-------------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")
local sketch = require("opengl.sketch")

local Camera = require("glutils.navcam")

-------------------------------------------------

require("topicnet")
local TopNet = topicnet.Topicnet

------------------Parse Data---------------------
local tpd = TopNet()
--local file = "/data/smallworld_1000_2000.xml"
--local file = "/data/facebook_Brynjar Gretarsson_2.dnv"
--local file = "/data/facebook_Donovan_music.xml"
local file = "/data/4test.xml"
local sourcepath = script.path .. file
--print("path ", sourcepath)
tpd:loadData(sourcepath)

local sz = tpd:graphsize()
print("graphsize ", sz)

------------------Save Data----------------------
local
function saveGraph(fileN)
    local path = script.path .. "/data"
    --print("path  ", path)
	local fname = LuaAV.findfileinpath(path, fileN, true)
	--print("filename", fname)
	local f = io.open(fname, "w")
	--print(f)
	
	for s=1, sz do
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


local
function loadGraph(fileN)
    local path = script.path .. "/data"
    --print("path  ", path)
	local fname = LuaAV.findfileinpath(path, fileN, true)
	--print("filename", fname)
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
-------------------------------------------------
local context = "3d net test"
win = Window{
	title = context, 
	origin = {0, 0}, 
	dim = {600, 480},
	mousemove = true,
}

win.sync = true
win.stereo = false

------------------global variables---------------

local boolstereo = false
local layout3d = false
local draw3d = true

local activePlane = -1

local mouseinteractmode = 0

local lastx
local lasty

local cvec1 = {0.0, 0.0, 0.0}
local cvec2 ={0.0, 0.0, 0.0}

local ray = {0.0, 0.0, 0.0}
local selectednodeindex = -1

local boolmousepress = false
local nodedragged = false

local n1high = false
local n2high = false


local AREA = 4.0
local MAXSTEP = 550
local TEMP = 0.5

local st = 0

---------------------colors----------------------
local red2 = {247/255, 59/255, 81/255}

local green2 = {84/255, 157/255, 138/255}

local yellow2 = {251/255, 252/255, 89/255}

local blue1 = {98/255, 102/255, 215/255}
local blue2 = {78/255, 82/255, 215/255}
-------------------------------------------------
local Gui = require("gui.Context")
local Rect = require("gui.Rect")
local Slider = require("gui.Slider")
local Button = require("gui.Button")
local GuiLabel = require("gui.Label")

local Label = require("Label")
-------------------------------------------------

local guilabels = Label{
	ctx = context,
	size = 12,
}

local graphlabels = Label{
	ctx = context,
	size = 20,
}

-- create the gui
local gui = Gui{
	ctx = context,
	dim = win.dim,
}

-- create some widgets
local mv_nd_btn = Button{
	rect = Rect(10, 12, 15, 15),
	value = false,
}

local nd_btn = Button{
	rect = Rect(10, 30, 15, 15),
	value = false,
}

local pl_btn = Button{
	rect = Rect(10, 50, 15, 15),
	value = false,
}

local clr_g_channel = Slider{
	rect = Rect(10, 110, 100, 10),
	value = 0,
	range = {0, 1},
}

local linethick = Slider{
	rect = Rect(10, 170, 100, 10),
	value = 0,
	range = {0, 5},
}

local pointsz = Slider{
	rect = Rect(10, 210, 100, 10),
	value = 5,
	range = {5, 20},
}

-- add them to the gui
gui:add_view(mv_nd_btn)
gui:add_view(nd_btn)
gui:add_view(pl_btn)

gui:add_view(clr_g_channel)
gui:add_view(linethick)
gui:add_view(pointsz)



-- register for notifications

mv_nd_btn:register("value", function(w)
	local val = w.value 
	print(val)
	if val then 
		mouseinteractmode = 0 
		pl_btn.value = false
		nd_btn.value = false
	end
end)

nd_btn:register("value", function(w)
	local val = w.value 
	print(val)
	if val then 
		mouseinteractmode = 1 
		pl_btn.value = false
		mv_nd_btn.value = false
	end
end)

pl_btn:register("value", function(w)
	local val = w.value 
	print(val)
	if val then 
		mouseinteractmode = 2 
		nd_btn.value = false
		mv_nd_btn.value = false
	end
end)

clr_g_channel:register("value", function(w)
	blue1[2] = w.value 
end)

-------------------------------------------------

local cam = Camera()

cam:movex(-2.0);
cam:movey(2.0);
cam:movez(-2.0)

cam.stereo = false

local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	coolexp = COOLING
	maxstep = MAXSTP
	
end

-------------------------------------------------

local 
function addNodeToPlane()
	--find the plane that selectednode z closest to
	-- if there are planes added 
	local currentpos = tpd:selectedNodePos()
	local diff = 100.0
	local plane = -1
	for p=0, tpd:planeCount()-1 do 
		local dist = math.abs(currentpos[3] - tpd:planeDepth(p))
		if(diff > dist) then
			diff = dist
			plane = p
		end
	end
	--print("selectedplane", plane)
	if(plane ~= 0 ) then
		tpd:addNodeToPlane(plane, selectednodeindex) 
	else
		currentpos[3] = 0.0
		tpd:selectedNodePos(currentpos)
	end	
end

-------------------------------------------------

-------------------------------------------------

function win:key(event, key)
     --print(key)
	 if(event == "down") then
		if(key == 27) then
			self.fullscreen = not self.fullscreen
		elseif(key == 101) then --E
			self.stereo = not self.stereo
			cam.stereo = self.stereo
		elseif(key == 105 or key == 73) then --i
			tpd:initGraphLayout()
			tpd:testGrid()
			st = 0
			coolexp = 0.2
		elseif(key == 115) then --S
			saveGraph("graphpos.txt")
		elseif(key == 108) then --L
		    loadGraph("graphpos.txt")
		    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		elseif(key == 121) then --3
			layout3d = not layout3d
			redrawgraph()
		elseif(key == 116) then --T
			draw3d = not draw3d
			--redrawgraph()
		
		elseif(key == 110) then --N
			tpd:bringN1(selectednodeindex)
	    elseif(key == 109) then --M
			tpd:bringN2(selectednodeindex)
			
		elseif(key == 103) then --G
			mouseinteractmode = 1
		elseif(key == 102) then --F
			mouseinteractmode = 2
		elseif(key == 104) then --H
			n1high = not n1high

		elseif(key == 112) then --P
		  local crrp = tpd:planeCount()
		  crrp = crrp+1
		  tpd:addPlane((crrp * 0.5) - 0.5)
		  activePlane = tpd:planeCount()-1
		  
		elseif(key == 114) then --R
		  tpd:removePlane()
		  activePlane = tpd:planeCount() -1 
		  if(tpd:planeCount() == 1) then activePlane = -1 end
		     
		elseif(key == 106) then --J
		   activePlane = activePlane + 1
		   activePlane = activePlane % tpd:planeCount() 
		   if(tpd:planeCount() == 1) then activePlane = -1 end
		   if(activePlane == 0) then activePlane = 1 end
		end
	end
	
	cam:key(self, event, key)
	gui:key(event, key)
	
end

function win:mouse(event, btn, x, y, nclk)
	gui:mouse(event, btn, x, y, nclk)
	
	if(event == "down") then
		boolmousepress = true
	elseif(event == "up") then
	    boolmousepress = false
	    if(nodedragged) then
	    	nodedragged = false
	    	addNodeToPlane()
	    end
	    
	elseif(event == "drag") then
	    local xdiff = (lastx - x) * 0.01
	    local ydiff = (lasty - y) * 0.01
	    if(mouseinteractmode == 2) then
	      	tpd:movePlane(activePlane, xdiff)
	    elseif(mouseinteractmode == 1) then
			if(selectednodeindex > -1.0 ) then 
				--print("drag selected node: ", selectednodeindex, "by : ", xdiff)
				local currentpos = tpd:selectedNodePos()
				currentpos[3] = currentpos[3] + xdiff
				tpd:selectedNodePos(currentpos)	
				nodedragged = true
			end
		elseif(mouseinteractmode == 0) then
			if(selectednodeindex > -1.0 ) then 
				local amnt = {-xdiff, ydiff, 0.0}
		        tpd:moveGraph(amnt)
			end
		end
	end
	
	lastx, lasty = x, y
end

function win:resize()
    cam:resize(self)
	gui:resize(self.dim)
end

function win:modifiers()
	gui:modifiers(self)
end

-------------------------------------------------


local 
function drawSphere (r, lats, longs)
   for i=1, lats do
  		local lat0 = math.pi * (-0.5 + (i-1)/lats)
        local z0 = math.sin(lat0)
        local zr0 = math.cos(lat0)
         
        local lat1 = math.pi * (-0.5 + i/lats)
        local z1 = math.sin(lat1)
        local zr1 = math.cos(lat1)
        
        gl.Begin(GL.TRIANGLE_STRIP)
        	for j=1, longs+1 do
        		local lng = 2 * math.pi * (j - 1) / longs
        		local x = math.cos(lng)
        		local y = math.sin(lng)
        		
        		gl.Normal(x * zr0, y * zr0, z0)
                gl.Vertex(x * zr0, y * zr0, z0)
                gl.Normal(x * zr1, y * zr1, z1)
                gl.Vertex(x * zr1, y * zr1, z1)
        	end
        
        gl.End()
	end
end

-------------------------------------------------

local 
function drawPlane()
   
    
    for p=0, tpd:planeCount()-1 do
        gl.Color(1.0, 1.0, 1.0, 0.3)
		gl.Enable(GL.BLEND)
		gl.Disable(GL.DEPTH_TEST)
		gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
		
		local depth = tpd:planeDepth(p)
		
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, AREA, depth)
			gl.Vertex(0.0, 0.0, depth)
			gl.Vertex(AREA, 0.0, depth)
			gl.Vertex(AREA, AREA, depth)	
	   gl.End()
	   
	   gl.Enable(GL.DEPTH_TEST)
	   gl.Disable(GL.BLEND)
	   
	   if( p == activePlane) then gl.Color(1.0, 0.4, 0.1, 0.3) 
	   else  gl.Color(1.0, 1.0, 1.0, 0.3) end
	   gl.LineWidth(0.7)
	   gl.Begin(GL.LINE_STRIP)
			gl.Vertex(0.0, AREA, depth)
			gl.Vertex(0.0, 0.0, depth)
			gl.Vertex(AREA, 0.0, depth)
			gl.Vertex(AREA, AREA, depth)	
			gl.Vertex(0.0, AREA, depth)
	   gl.End()
    end
end
-------------------------------------------------

local 
function drawAxes()
    gl.Color(1.0, 0.0, 0.0)
	gl.Begin(GL.LINES)
   		gl.Vertex(0, 0, 0)
   		gl.Vertex(1, 0, 0)
   	gl.End()
   	
   	gl.Color(0.0, 1.0, 0.0)
	gl.Begin(GL.LINES)
   		gl.Vertex(0, 0, 0)
   		gl.Vertex(0, 1, 0)
   	gl.End()
   	
   	gl.Color(0.0, 0.0, 1.0)
	gl.Begin(GL.LINES)
   		gl.Vertex(0, 0, 0)
   		gl.Vertex(0, 0, 1)
   	gl.End()
end

---------------------------------------------------

tpd:initGraphLayout()
tpd:randomizeGraph(layout3d)

local coolingschedule = {}

---------------------------------------------------


local shader = Shader{
	ctx = context,
	file = LuaAV.findfile("mat.phong.shl"),
	param = {
		La = {0.2, 0.2, 0.2},
	}
}

local SPshade = Shader{
	ctx = context,
	file = LuaAV.findfile("stylized_primitive.shl")
}


SPshade:param("radyus", 0.005) 
SPshade:param ("Kd", {0.4, 0.7, 0.55})


shader:param ("Ka", {0.3, 0.5, 0.3})
shader:param ("Kd", {0.7, 0.4, 0.4})
shader:param ("Ks", {0.4, 0.4, 0.4})

gl.Enable(GL.LIGHT0)
gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)



-------------------------------------------------
local 
function drawCooling()
	local dim = win.dim
	local aspect = dim[1]/dim[2]
	sketch.enter_ortho(-aspect, -1, 2*aspect, 2)
	
	gl.PointSize(1.0)
	gl.Color(1.0, 0.0, 0.0)
	gl.Begin(GL.POINTS)
	
	for k,v in pairs(coolingschedule) do 
		--print(k,v) 
		gl.Vertex(k*0.002-0.9, v*0.1-0.7, 0.0)
	end
	gl.End()
	
	sketch.leave_ortho()
end

-------------------------------------------------
---------calculate ray intersection--------------

local function rayintersect(raypoint, raydir, spherepoint, sphereradius)

    local a = vec3.dot(raydir, raydir)
    local zz = vec3.sub(raypoint, spherepoint)
    local b = 2 * vec3.dot(raydir, zz)
    local c = vec3.dot(zz, zz) - sphereradius* sphereradius
  
    local discriminant = b*b - 4*a*c
    local intersects = false
    
    if( discriminant < 0.0) then 
		intersectres = false
	else
		intersectres = true
	end
    
	return intersectres
end



local 
function selectNode()
		
	    local p1, p2 = cam:picktheray(lastx, lasty)
		cvec1 = p1[1]
		cvec2 = p2[1]
		
		ray = vec3.sub(cvec2, cvec1)
		local rayscale = vec3.scale (ray, 0.01)
		
		
		for l=1, tpd:graphsize() do
			local ind = l-1
			local p = tpd:graphnodepos(ind)
			
			local intersects = rayintersect(cvec1, ray, p, 0.02)
			--print(ind, " intersects=", intersects)
			if(intersects) then
				selectednodeindex = ind
				break
			else
				selectednodeindex = -1
			end
	    end
	    
	    tpd:selectedNode(selectednodeindex)
end

-------------------------------------------------


function win:draw(eye)
	
	
	cam:step()
	cam:enter((eye == "left") and 1 or 0)
	
	
	gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)
	
	gl.LineWidth(2.0)
	drawAxes()
	
	if(boolmousepress) then
	    boolmousepress = false
		selectNode()
	end
	
	
	
	local linescale = linethick.value + 0.1
	local pointscale = pointsz.value
	
	drawPlane()
			
	if(draw3d) then
	        
	        shader:param ("Ka", {0.3, 0.3, 0.3})
			shader:param ("Kd", {red2[1], red2[2], red2[3]})
			shader:bind()
				tpd:drawGraphNodes(true, 0.002*pointscale)
			shader:unbind()
			
			if(selectednodeindex > -1) then
			    
			    local p = tpd:graphnodepos(selectednodeindex)
			    gl.Color(1.0, 1.0, 0.0)
				graphlabels:draw_3d(win.dim, {p[1], p[2]+0.01, p[3]+0.01}, tpd:getnodelabel(selectednodeindex))
				
				shader:param ("Kd", {yellow2[1], yellow2[2], yellow2[3]})
				shader:bind()
			        
			       
					gl.PushMatrix()
						gl.Translate(p)
						gl.Color(0.3, 0.9, 0.6, 0.9)
						gl.Scale(0.0025*pointscale, 0.0025*pointscale, 0.0025*pointscale)
						drawSphere (1.0, 10, 10)
					gl.PopMatrix()
			    shader:unbind()
			end
		    --[[
			SPshade:param("viewpoint", cam.eye)
			SPshade:param("radyus", linescale*0.05) 
			SPshade:bind()
			tpd:drawGraphEdges(true, 2.0)
			SPshade:unbind()
			--]]
			gl.Color(blue1[1], blue1[2], blue1[3])
			tpd:drawGraphEdges(false, linescale)
			
	else
	    gl.Color(red2[1], red2[2], red2[3])
		tpd:drawGraphNodes(false, pointscale)
		
		if(selectednodeindex > -1) then
		    gl.Color(yellow2[1], yellow2[2], yellow2[3])
			local p = tpd:graphnodepos(selectednodeindex)
			gl.Begin(GL.POINTS)
				gl.Vertex(p[1], p[2], p[3])
			gl.End()
		end
		
	    --gl.Color(green2[1], green2[2], green2[3])
	    gl.Color(blue1[1], blue1[2], blue1[3])
		tpd:drawGraphEdges(false, linescale)

	end


    if( n1high) then 
         gl.PointSize(pointscale*2.7)
		 gl.LineWidth(linescale*2.0)
		 gl.Color(yellow2[1], yellow2[2], yellow2[3])
    	 tpd:highlightN1() 
    	 local neighbors = tpd:get1stNgh(selectednodeindex)
    	 for i,v in ipairs(neighbors) do 
    	 	
    	 	local np = tpd:graphnodepos(v)
			--print("in lua neighbors: ", i, v, tpd:getnodelabel(v))
			
			gl.Color(green2[1], green2[2], green2[3])
			graphlabels:draw_3d(win.dim, {np[1], np[2]-0.02, np[3]+0.01}, tpd:getnodelabel(v))
			----[[	
			shader:param ("Kd", {green2[1], green2[2], green2[3]})
			shader:bind()
			
			gl.PushMatrix()
			gl.Translate(np)
				gl.Color(0.3, 0.9, 0.6, 0.9)
				gl.Scale(0.0025*pointscale, 0.0025*pointscale, 0.0025*pointscale)
				drawSphere (1.0, 10, 10)
			gl.PopMatrix()
			shader:unbind()
			--]]
    	 end
    end
	if(st < MAXSTEP and TEMP > 0.0001) then
	    coolingschedule[st] = TEMP
		--print("step", st, " @ coolexp", coolexp) 
		tpd:stepLayout(layout3d, TEMP)
	 	TEMP = TEMP * 0.98
	 	--TEMP = TEMP * math.exp(-0.0001*st)
	 	st = st+1 	
	end

	--drawCooling()
	
    cam:leave()
    gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    sketch.enter_ortho(self.dim)
    guilabels:draw({65, 30, 0}, "Move Node")
	guilabels:draw({65, 50, 0}, "Drag Node")
	guilabels:draw({67, 70, 0}, "Drag Plane")
	
	guilabels:draw({90, 110, 0}, "Edge Color Blue Channel")
	guilabels:draw({59, 170, 0}, "Line Thickness")
	guilabels:draw({45, 210, 0}, "Point Size")
	sketch.leave_ortho()
	
	gui:draw()
end