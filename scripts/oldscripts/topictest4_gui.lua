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
--local file = "/data/smallworld_10_20.xml"
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


------------------global variables---------------

local boolstereo = false
local layout3d = false
local draw3d = true

local planeCount = 1
local planesZpos = {}
planesZpos[1] = 0.0

local activePlane = -1

local nodesonplanes = {}


local mouseinteractmode = 1 

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

local MAXSTP = 550
local COOLING = 2.0

local st = 0
local coolexp = COOLING
local maxstep = MAXSTP

-------------------------------------------------
local Gui = require("gui.context")
local Rect = require("gui.rect")
local Slider = require("gui.slider")
local Button = require("gui.button")
local Label = require("gui.label")
-------------------------------------------------

-- create the gui
local gui = Gui{
	ctx = context,
	dim = win.dim,
}

-- create some widgets
local cam_btn = Button{
	rect = Rect(10, 10, 15, 15),
	value = false,
}
local cam_lbl = Label{
	rect = Rect(65, 15, 85, 20),
	label = "Camera",
}
local nd_btn = Button{
	rect = Rect(10, 30, 15, 15),
	value = false,
}
local nd_lbl = Label{
	rect = Rect(65, 35, 85, 20),
	label = "Node",
}
local pl_btn = Button{
	rect = Rect(10, 50, 15, 15),
	value = false,
}
local pl_lbl = Label{
	rect = Rect(65, 55, 85, 20),
	label = "Plane",
}
-- add them to the gui
gui:add_view(cam_btn)
gui:add_view(cam_lbl)
gui:add_view(nd_btn)
gui:add_view(nd_lbl)
gui:add_view(pl_btn)
gui:add_view(pl_lbl)

cam_lbl:set_size(14.0)
nd_lbl:set_size(14.0)
pl_lbl:set_size(14.0)

-- register for notifications
cam_btn:register("value", function(w)
	local val = w.value and 1 or 0
end)

nd_btn:register("value", function(w)
	local val = w.value and 1 or 0	
end)

pl_btn:register("value", function(w)
	local val = w.value and 1 or 0
end)

-------------------------------------------------

local cam = Camera()

cam:movex(-2.0);
cam:movey(2.0);
cam:movez(-2.0)



local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	coolexp = COOLING
	maxstep = MAXSTP
	
end

-------------------------------------------------
--I'm doing the remove in a stupid way... for now
local
function removeNodeFromPlane(nodeind, plane)
	local allnodes = nodesonplanes[plane]
	for i,ind in ipairs(allnodes) do 
		if(ind == nodeind) then
			table.remove(allnodes, i)
			break
		end	
	end
	
	--for i,v in ipairs(allnodes) do print(i,v[1], v[2], v[3]) end
end

local 
function addNodeToPlane()
	--find the plane that selectednode z closest to
	-- if there are planes added 
	local currentpos = tpd:selectedNodePos()
	local diff = 100.0
	local plane = 0
	for p=1, planeCount do 
		local dist = math.abs(currentpos[3] - planesZpos[p])
		if(diff > dist) then
			diff = dist
			plane = p
		end
	end
	--print("selectedplane", plane, "pos", planesZpos[plane])
	if(plane ~= 1 ) then
	    --if(not nodesonplanes[plane]) then nodesonplanes[plane] = {} end
		table.insert(nodesonplanes[plane], selectednodeindex)
	end
    currentpos[3] = planesZpos[plane]
	tpd:selectedNodePos(currentpos)
	local oldplane = tpd:graphnodeplane(selectednodeindex)
	if( oldplane ~= 1) then 
	     --print("old plane : ", oldplane)
	     removeNodeFromPlane(selectednodeindex, oldplane)
	end
	tpd:graphnodeplane(selectednodeindex, plane)
end



-------------------------------------------------
local 
function moveNode(key)
	if(selectednodeindex > -1.0 and selectednodeindex < sz) then
	    local currentpos = tpd:selectedNodePos()
		if(key == 63232) then --up arrow
			currentpos[2] = currentpos[2] + 0.01
			tpd:selectedNodePos(currentpos)
		elseif(key == 63233) then -- down arrow
			currentpos[2] = currentpos[2] - 0.01
			tpd:selectedNodePos(currentpos)
		elseif(key == 63234) then -- left arrow
			currentpos[1] = currentpos[1] - 0.01
			tpd:selectedNodePos(currentpos)
		elseif(key == 63235) then -- right arrow
			currentpos[1] = currentpos[1] + 0.01
			tpd:selectedNodePos(currentpos)
		elseif(key == 91) then -- upshift
			currentpos[3] = currentpos[3] + 0.01
			tpd:selectedNodePos(currentpos)
		elseif(key == 47) then --downshift
			currentpos[3] = currentpos[3] - 0.01
			tpd:selectedNodePos(currentpos)
		end
		
	end
end


local 
function moveActivePlane(xdiff)
    local newZ = planesZpos[activePlane] + xdiff
    planesZpos[activePlane] = newZ
	
	local allnodes = nodesonplanes[activePlane]
	
	for i,nodeind in ipairs(allnodes) do 
		local oldpos = tpd:graphnodepos(nodeind)
		oldpos[3] = newZ
		tpd:graphnodepos(nodeind, oldpos)
	end
	
end
-------------------------------------------------

function win:key(event, key)
     --print(key)
	 if(event == "down") then
		if(key == 27) then
			self.fullscreen = not self.fullscreen
		elseif(key == 105 or key == 73) then --i
			tpd:initGraphLayout()
			tpd:testGrid()
			st = 0
			coolexp = 0.2
		elseif(key == 115) then --S
			saveGraph("graphpos.txt")
		elseif(key == 108) then --L
		    loadGraph("graphpos.txt")
		    st = MAXSTP -- TO STOP GRAPH LAYOUT CALC
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
		elseif(key == 104) then --H
			mouseinteractmode = 2

		elseif(key == 112) then --P
		      planeCount = planeCount + 1
		      nodesonplanes[planeCount] = {}
		      planesZpos [planeCount] = (planeCount * 0.5) - 0.5
		      
		      activePlane = planeCount
		      
		      --print("added plane ", planeCount, "at pos", planesZpos [planeCount] )
		elseif(key == 114) then --R
		      planesZpos [planeCount] = 0.0
		      planeCount = planeCount - 1
		      if( planeCount < 1 ) then planeCount = 1 end
		      
		      activePlane = planeCount
		      if(planeCount == 1) then activePlane = -1 end
		     
		elseif(key == 106) then --J
		   activePlane = activePlane + 1
		   activePlane = activePlane % planeCount 
		   
		   if(activePlane == 1) then 
				if(planeCount > 1) then activePlane = 2 else activePlane = -1 end
		   end
		   
		   if(activePlane == 0) then activePlane = planeCount end
		  
		  --[[ test
		  for p=2, planeCount do 
		    print("at plane : ", p)
		    local allnodes = nodesonplanes[p]
		    for i,v in ipairs(allnodes) do print(i,v[1], v[2], v[3]) end
		  end
		  --]]
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
	    local xdiff = (lastx - x) * 0.03
	    if(mouseinteractmode == 2) then
	      	moveActivePlane(xdiff)
	    elseif(mouseinteractmode == 1) then
			if(selectednodeindex > -1.0 ) then 
				--print("drag selected node: ", selectednodeindex, "by : ", xdiff)
				local currentpos = tpd:selectedNodePos()
				currentpos[3] = currentpos[3] + xdiff
				tpd:selectedNodePos(currentpos)	
				nodedragged = true
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
   
    
    for p=1, planeCount do
        gl.Color(1.0, 1.0, 1.0, 0.3)
		gl.Enable(GL.BLEND)
		gl.Disable(GL.DEPTH_TEST)
		gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
			
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, 4.0, planesZpos[p])
			gl.Vertex(0.0, 0.0, planesZpos[p])
			gl.Vertex(4.0, 0.0, planesZpos[p])
			gl.Vertex(4.0, 4.0, planesZpos[p])	
	   gl.End()
	   
	   gl.Enable(GL.DEPTH_TEST)
	   gl.Disable(GL.BLEND)
	   
	   if( p == activePlane) then gl.Color(1.0, 0.4, 0.1, 0.3) 
	   else  gl.Color(1.0, 1.0, 1.0, 0.3) end
	   gl.LineWidth(0.7)
	   gl.Begin(GL.LINE_STRIP)
			gl.Vertex(0.0, 4.0, planesZpos[p])
			gl.Vertex(0.0, 0.0, planesZpos[p])
			gl.Vertex(4.0, 0.0, planesZpos[p])
			gl.Vertex(4.0, 4.0, planesZpos[p])	
			gl.Vertex(0.0, 4.0, planesZpos[p])
	   gl.End()
    end
   --planeCount = planeCount + 1
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

function win:draw()
	
	cam:step()
	cam:enter()
	
	
	gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)
	
	gl.LineWidth(2.0)
	drawAxes()
	
	if(boolmousepress) then
	    boolmousepress = false
		selectNode()
	end
	
	local center = {2.0, 2.0, 0.0}
	local camdist = vec3.mag(vec3.sub(cam.eye, center))
	camdist = math.max(1.0, camdist)
    local pointscale =  (4.0 / camdist) * 4.0 + 4.0
	local linescale = 4.0 / camdist
	
	drawPlane()
			
	if(draw3d) then
	      
	        shader:param ("Ka", {0.3, 0.3, 0.3})
			shader:param ("Kd", {0.7, 0.4, 0.4})
			shader:bind()
				tpd:drawGraphNodes(true, 5.0)
			shader:unbind()
			
			if(selectednodeindex > -1) then
			
				shader:param ("Ka", {0.9, 0.8, 0.7})
				shader:param ("Kd", {0.9, 0.8, 0.4})
				shader:bind()
			        local p = tpd:graphnodepos(selectednodeindex)
					gl.PushMatrix()
						gl.Translate(p)
						gl.Color(0.3, 0.9, 0.6, 0.9)
						gl.Scale(0.05, 0.05, 0.05)
						drawSphere (1.0, 10, 10)
					gl.PopMatrix()
			    shader:unbind()
			end
		
			local ay = cam.eye
			local lk = cam.look
			
			local view = vec3.add(ay, lk)
			view = vec3.normalize(view)
			
			SPshade:param("view", view)
			SPshade:param("radyus", linescale*0.005) 
			SPshade:bind()
			tpd:drawGraphEdges(true, 2.0)
			SPshade:unbind()
			
	else
		tpd:drawGraphEdges(false, linescale)
		tpd:drawGraphNodes(false, pointscale)
		
		if(n1high) then 
			tpd:highlightN1() 
			
		end
		
		if(n2high) then 
			tpd:highlightN2()
			
		end
			
			
	end

	if(st < maxstep and coolexp > 0.0001) then
	    coolingschedule[st] = coolexp
		--print("step", st, " @ coolexp", coolexp) 
		tpd:stepLayout(layout3d, coolexp)
	 	coolexp = coolexp * 0.98
	 	--coolexp = coolexp * math.exp(-0.0001*st)
	 	st = st+1 	
	end

	--drawCooling()
    cam:leave()
	gui:draw()
end