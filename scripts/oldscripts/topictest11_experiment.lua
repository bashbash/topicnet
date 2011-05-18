local gl = require("opengl")
local GL = gl
local glu = require("opengl.glu")
-------------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")
local sketch = require("opengl.sketch")

local Texture = require("opengl.Texture")
local Array = require("Array")
local Image = require("Image")
local Camera = require("glutils.navcam")


local osc = require("osc")
-------------------------------------------------

require("topicnet")
local TopNet = topicnet.Topicnet

local activedata = 1

------------------Parse Data---------------------
local tpd = TopNet()
--local file = "/data/smallworld_1000_2000.xml"
--local file = "/data/4test.xml"
--local file = "/data/facebook_Donovan_music.xml"
--local file = "/data/UCI_venezuela.xml"
--local file = "/data/facebook_Brynjar Gretarsson_2.dnv"


local data1 = "/data/coauthor_all.xml"
local data2 = "/data/coauthor_mid.xml"
local data3 = "/data/coauthor_large.xml"



local sources = {}
local sourcepath1 = script.path .. data1
local sourcepath2 = script.path .. data2
local sourcepath3 = script.path .. data3

local sources = {sourcepath1, sourcepath2, sourcepath3}

tpd:loadData(sources[activedata], "author")



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
--win.cursor = false
------------------global variables---------------

local RADIUS = 0.05
local HALOSIZE = 1.1


local boolstereo = false
local layout3d = false
local draw3d = true

local activePlane = -1

local mouseinteractmode = 0
local boolrotate = false
local lastx = 0.0
local lasty = 0.0

local cvec1 = {0.0, 0.0, 0.0}
local cvec2 ={0.0, 0.0, 0.0}

local ray = {0.0, 0.0, 0.0}


local selnodes = {}
selnodes[1] = -1
selnodes[2] = -1

local boolmousepress = false
local nodedragged = false

local blockview = false

local boollabelall = false

local n1high = false
local n1labels = false

local addMode = false

local AREA = 5.0
local MAXSTEP = 550
local TEMP = 0.5

local st = 0


local send_address = '127.0.0.1'	-- or another IP address, or hostname such as 'localhost'
local send_port = 16447
local receive_port = 16448

local oscout = osc.Send(send_address, send_port) 
local oscin  = osc.Recv(receive_port)   


-------------------------------------------------
------------------Save Data----------------------
local
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


local
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
---------------------colors----------------------
local winbgcolor = {0.9, 0.9, 0.9}
local red = {247/255, 59/255, 81/255}
local pink = {241/255, 93/255, 111/255}
local green = {104/255, 197/255, 38/255}
local yellow = {251/255, 252/255, 89/255}
local blue = {98/255, 202/255, 215/255}
local highcol = {}
highcol[1] = {96/255, 176/255, 71/255}
highcol[2] = {255/255, 171/255, 52/255}

-------------------------------------------------

local shapeTexture = Texture(context)

local 
function initTexture()

    local res = 256
    local float1 = Array(4, Array.Float32, {res, res})
	
	for i=0, float1.dim[1]-1 do
	for j=0, float1.dim[2]-1 do
	
		--textures for normal coefficient lookup. x is across profile, y is rotation index.
		--all profile lookups are stored as if they were in an orthogonal projection, making things easier.
		--red coefficient is stored packed, meaning 0 to 1 really maps to -1 to 1
		
		local x = ((j/res) * 2.0) - 1.0
		local y = i/res

		--r channel contains side vector coefficient
		--g channel contains up vector coefficient
		--b channel contains depth correction factor

		local r, g, b
		
		local angle = y * math.pi
		local center = -math.cos(angle)

		if (x < center) then 
			r = - math.cos(angle*0.5) * 0.5 + 0.5
			g = math.sin(angle*0.5)
		else
			r = math.sin(angle*0.5) * 0.5 + 0.5
			g = math.cos(angle*0.5)
		end
		
			b = math.sqrt(1.0 - x*x)

		float1:setcell(i, j, {r, g, b, 1.0})
	end
	end

	shapeTexture:fromarray(float1)
	
end
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
	alignment = "LEFT",
	size = 12,
	color = {1.0, 0.3, 0.5}
}

local graphlabels = Label{
	ctx = context,
	fontfile = LuaAV.findfile("VeraMoBd.ttf"),
	--alignment = "LEFT",
	size = 14,
	bg = true
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
	value = 0.79,
	range = {0, 1},
}

local linethick = Slider{
	rect = Rect(10, 100, 100, 10),
	value = 1,
	range = {0, 3},
}

local pointsz = Slider{
	rect = Rect(10, 150, 100, 10),
	value = 12,
	range = {5, 20},
}


-- add them to the gui
gui:add_view(mv_nd_btn)
gui:add_view(nd_btn)
gui:add_view(pl_btn)

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



-------------------------------------------------

local cam = Camera()

--cam:movex(-2.5);
cam:movey(2.5);
cam:movez(-2.0)

cam.stereo = false

local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	TEMP = 0.5
	maxstep = MAXSTP
	
end

-------------------------------------------------
local 
function drawCircle(radius)
   gl.Begin(GL.QUAD_STRIP)
   local DEG2RAD = 3.14159/180
   local halfrad = radius * 0.5
   for i=0,360, 36 do  
   		local degInRad = i*DEG2RAD
        gl.Vertex(math.cos(degInRad)*radius, math.sin(degInRad)*radius, 0.0)
        gl.Vertex(math.cos(degInRad)*halfrad, math.sin(degInRad)*halfrad, 0.0)
   end
   gl.End()
end


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
    
	gl.Enable(GL.BLEND)
	gl.Disable(GL.DEPTH_TEST)
	gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
		
    
    for p=0, tpd:planeCount()-1 do
        
		gl.Color(1.0, 1.0, 1.0, 0.08)
		local depth = tpd:planeDepth(p)
		
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, AREA, depth)
			gl.Vertex(0.0, 0.0, depth)
			gl.Vertex(AREA, 0.0, depth)
			gl.Vertex(AREA, AREA, depth)	
	   gl.End()
	   
	   
	   
	   if( p == activePlane) then gl.Color(1.0, 0.4, 0.1, 1.0) 
	   else  gl.Color(1.0, 1.0, 1.0, 0.2) end
	   gl.LineWidth(0.5)
	   --[[
	   gl.Begin(GL.LINE_STRIP)
			gl.Vertex(0.0, AREA, depth)
			gl.Vertex(0.0, 0.0, depth)
			gl.Vertex(AREA, 0.0, depth)
			gl.Vertex(AREA, AREA, depth)	
			gl.Vertex(0.0, AREA, depth)
	   gl.End()
	   --]]
	   
	   gl.Begin(GL.LINES)
	   		for div=0, AREA, 0.5 do
	   		  gl.Vertex(div, AREA, depth)
	   		  gl.Vertex(div, 0.0, depth)
	   		  
	   		  gl.Vertex(AREA, div, depth)
	   		  gl.Vertex(0.0, div, depth)
	   		end
	   gl.End()
    end
    
    gl.Enable(GL.DEPTH_TEST)
	gl.Disable(GL.BLEND)
end


local 
function drawlabelbg(p, len)
		gl.PushMatrix()
		gl.Translate(p)
		gl.Color(0.0, 0.0, 0.0)
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, 0.1, 0.0)
			gl.Vertex(0.0, 0.0, 0.0)
			gl.Vertex(len, 0.0, 0.0)
			gl.Vertex(len, 0.1, 0.0)	
	   gl.End()
	   gl.PopMatrix()

end
-------------------------------------------------

local 
function drawMyCursor()
	
	local dim = win.dim
	local pos = glu.UnProject(lastx, lasty, 0.01)
	local sc = 0.0015

    gl.Color(0.7, 0.7, 0.7)
	gl.Begin(GL.LINES)
	    
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1]+sc*2, pos[2]-sc*2, pos[3]);
	    
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1], pos[2]-sc, pos[3]);
		
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1]+sc, pos[2], pos[3]);
	
	gl.End()
end


local 
function drawAxes()
	
	local dim = win.dim
	local pos = glu.UnProject(50.0, dim[2] - 50.0, 0.5)
	local sc = 0.02

	gl.Begin(GL.LINES)
	    gl.Color(1.0, 0.0, 0.0)
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1]+sc, pos[2], pos[3]);
	
	
	    gl.Color(0.0, 1.0, 0.0)
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1], pos[2]+sc, pos[3]);
	
	    gl.Color(0.0, 0.0, 1.0)
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1], pos[2], pos[3]+sc);
			
	gl.End()
end

-------------------------------------------------

local coolingschedule = {}


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

---------------------------------------------------


local shader = Shader{
	ctx = context,
	file = LuaAV.findfile("mat.phong.shl"),
	param = {
		La = {0.2, 0.2, 0.2},
		Ka = {0.3, 0.3, 0.3},
		Ks = {0.4, 0.4, 0.4},
		Kd = {0.8, 0.5, 0.4},
	}
}

local primshader = Shader{
	ctx = context,
	file = LuaAV.findfile("stylized_line.shl"),
	param = {
		haloColor = {0.4, 0.4, 0.4, 1.0},
	}
}

local SPshade = Shader{
	ctx = context,
	file = LuaAV.findfile("stylized_primitive.shl"),
	param = {
		radyus = 0.005,
		Kd = {0.4, 0.7, 0.55},
	}
}

---------------------------------------------------
--------------billboard shader---------------------

local img = Image(LuaAV.findfile("circle.png"))
local tex = Texture(context)
tex:fromarray(img:array())

local billshader = Shader{
	ctx = context,
	file = LuaAV.findfile("vd.billboard.shl")
}

local offset = billshader:attr("offset")


local
function drawBillboardCircle(sc)
	
    
    gl.Disable(GL.BLEND)
	gl.Enable(GL.DEPTH_TEST)
    gl.Enable(GL.ALPHA_TEST)
    gl.AlphaFunc(GL.GREATER,0.9)
  
    gl.PushMatrix()
    local scale = sc*0.05 + 0.22
    gl.Scale(scale, scale, scale)
   
	billshader:bind()
	tex:bind()
		gl.Begin(GL.QUADS)
			offset:submit(-1, 1)
			gl.TexCoord(0, 0)
			gl.Vertex(0, 0, 0)
			
			offset:submit(1, 1)
			gl.TexCoord(1, 0)
			gl.Vertex(0, 0, 0)
			
			offset:submit(1, -1)
			gl.TexCoord(1, 1)
			gl.Vertex(0, 0, 0)
			
			offset:submit(-1, -1)
			gl.TexCoord(0, 1)
			gl.Vertex(0, 0, 0)
		gl.End()
	tex:unbind()
	billshader:unbind()
	
	gl.PopMatrix()
    gl.Disable(GL.ALPHA_TEST)
end


---------------------------------------------------
---------------------------------------------------

local 
function addNodeToPlane(thenode)
	--find the plane that selectednode z closest to
	-- if there are planes added 
	local currentpos = tpd:graphnodepos(thenode)
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
		tpd:addNodeToPlane(plane, thenode) 
	else
		currentpos[3] = 0.0
		tpd:graphnodepos(thenode, currentpos)
	end	
end

---------------------------------------------------
---------calculate ray intersection----------------

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
function hoverNode()
	local p1, p2 = cam:picktheray(lastx, lasty)
	cvec1 = p1[1]
	cvec2 = p2[1]
		
	ray = vec3.sub(cvec2, cvec1)
	local rayscale = vec3.scale (ray, 0.01)
	
	for l=1, tpd:graphsize() do
		local ind = l-1
		local p = tpd:graphnodepos(ind)
			
		local intersects = rayintersect(cvec1, ray, p, 0.02)
		if(intersects) then
			if( ind ~= selnodes[1] and ind ~=selnodes[2]) then 
				local labelstr = tpd:getnodelabel(ind)
				local p = tpd:graphnodepos(ind)
				graphlabels:draw_3d(win.dim, {p[1], p[2], p[3]}, labelstr)
			end
			break
		end
	    end
	    
end


local 
function selectNode()
		
	    local p1, p2 = cam:picktheray(lastx, lasty)
		cvec1 = p1[1]
		cvec2 = p2[1]
		
		ray = vec3.sub(cvec2, cvec1)
		local rayscale = vec3.scale (ray, 0.01)
		local selectednodeindex
		
		for l=1, tpd:graphsize() do
			local ind = l-1
			local p = tpd:graphnodepos(ind)
			
			local intersects = rayintersect(cvec1, ray, p, 0.02)
			--print(ind, " intersects=", intersects)
			if(intersects) then
				selectednodeindex = ind
				print(tpd:getnodeid(ind))
				break
			else
				n1high = false
			    tpd:highlightN1(selnodes[1], n1high)

				selectednodeindex = -1
				
			end
	    end
	    print(selectednodeindex)
	    tpd:selectedNode(selectednodeindex, addMode)
	    selnodes = tpd:selectedNode()
end

-------------------------------------------------

local ambientLight = { 0.3, 0.3, 0.3, 1.0 }
local diffuseLight = { 0.9, 0.9, 0.9, 1.0 }
local specularLight = { 0.5, 0.8, 0.9, 1.0 }
local position = { 0.0, 2.0, 2.0, 1.0 }

---------------------------------------------------
function win:init()
	gl.Enable(GL.DEPTH_TEST)
	gl.Enable(GL.LIGHTING)
	gl.Enable(GL.LIGHT0)
	
	gl.Light(GL.LIGHT0, GL.AMBIENT, ambientLight)
	gl.Light(GL.LIGHT0, GL.DIFFUSE, diffuseLight)
	gl.Light(GL.LIGHT0, GL.SPECULAR, specularLight)
	gl.Light(GL.LIGHT0, GL.POSITION, position)
	
	gl.Material(GL.FRONT, GL.SHININESS, 100.0)
	
	
end

tpd:initGraphLayout()
tpd:randomizeGraph(layout3d)


local 
function clearAll()
	tpd:selectedNode(-1, false)
	n1high = false
	while (tpd:planeCount() > 1) do 
		tpd:removePlane()
	end
	activePlane = -1 	  
end




local 
function question1(node, actdat, case)
  
  
    activedata = actdat
    tpd:loadData(sources[activedata], "author")
    
	clearAll()
	tpd:selectedNode(node, false)
	selnodes = tpd:selectedNode()
	
	if(case == "2D") then
	    draw3d = false
	    layout3d = false
		loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    n1high = true 
	    n1labels = false
	elseif(case == "3D") then
	    draw3d = true
	    layout3d = true
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		n1high = true
		n1labels = false
		
	elseif(case == "2.5D") then
	    draw3d = true
	    layout3d = false
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    n1high = false 
	    n1labels = true
	    
	    tpd:addPlane(1.0)
	    tpd:addNodeToPlane(1, node) 
	    tpd:bringN1(node)	
	
	elseif(case == "2.5DH") then
	    draw3d = true
	    layout3d = false
	    
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    
	    tpd:addPlane(1.0)
	    tpd:addNodeToPlane(1, node) 
	    tpd:bringN1(node)
	    
	    n1high = true 
	    n1labels = false
	end
	
end 


local 
function question2(node1, node2, actdat, case)
    
    activedata = actdat
    tpd:loadData(sources[activedata], "author")
  
    clearAll()
	tpd:selectedNode(node1, false)
    tpd:selectedNode(node2, true)
	
	selnodes = tpd:selectedNode()
	
	if(case == "2D") then
	    draw3d = false
	    layout3d = false
		loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    n1high = true 
	    n1labels = false
	elseif(case == "3D") then
	    layout3d = true
	    draw3d = true
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		n1high = true
		n1labels = false
		
	elseif(case == "2.5D") then
	    draw3d = true
	    layout3d = false
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    n1high = false 
	    n1labels = true
	    
	    tpd:addPlane(1.0)
	    tpd:addPlane(2.5)
	    
	    tpd:addNodeToPlane(1, node1) 
	    tpd:addNodeToPlane(2, node2) 
	    
	    tpd:bringN1(node1)
	    tpd:bringN1(node2)
	elseif(case == "2.5DH") then
	    draw3d = true
	    layout3d = false
	    loadGraph()
	    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
	    
	    
	    tpd:addPlane(1.0)
	    tpd:addPlane(2.5)
	    
	    tpd:addNodeToPlane(1, node1) 
	    tpd:addNodeToPlane(2, node2) 
	    
	    tpd:bringN1(node1)
	    tpd:bringN1(node2)
	    
	    n1high = true 
	    n1labels = false
	    
	end
	
end


local 
function getOSC() 
	for msg in oscin:recv() do	
	    if(msg.addr == "/quest1") then 
	        local dt, tsk, cond, nd = unpack (msg)
	        question1(nd, dt, cond)
		
		elseif(msg.addr == "/quest2") then 	
		    local dt, tsk, cond, n1, n2 = unpack (msg)
		    if(tsk == 5) then boollabelall = true else boollabelall = false  end
		    question2(n1, n2, dt, cond)
		elseif(msg.addr == "/blockview") then 	
		    local boolv = unpack (msg)
		    if(boolv == 1) then blockview = true else blockview = false end
		    
		elseif(msg.addr == "/rotate") then 	
			local boolr = unpack (msg)
			boolrotate = boolr
		elseif(msg.addr == "/cameye") then 
			local cx, cy, cz =  unpack (msg)
			print("cameye", cy)
			cam.eye = {cx, cy, cz}
		end
		
		--[[
		elseif(msg.addr == "/fullscr") then
			win.fullscreen = not win.fullscreen
		elseif(msg.addr == "/stereo") then
            print("received stereo toggle")
			win.stereo = not win.stereo
			cam.stereo = win.stereo
		elseif(msg.addr == "/save") then
		    print("save")
		    saveGraph()
		elseif(msg.addr == "/load") then
		    print("load")
		    loadGraph()
		    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		elseif(msg.addr == "/layout") then
			layout3d = not layout3d
			redrawgraph()
		elseif(msg.addr == "/render3d") then
			draw3d = not draw3d
		elseif(msg.addr == "/bringn") then
			tpd:bringN1(selnodes[1])
		elseif(msg.addr == "/addmode") then
			addMode = not addMode	
		elseif(msg.addr == "/mouseinteractmode") then
			mouseinteractmode = msg
		elseif(msg.addr == "/n1high") then
			n1high = not n1high
			tpd:highlightN1(selnodes[1], n1high) 
		elseif(msg.addr == "/rotate") then
			 boolrotate = not boolrotate
		elseif(msg.addr == "/addplane") then
			local crrp = tpd:planeCount()
		  	tpd:addPlane(crrp)
		  	crrp = crrp+1
		  	activePlane = tpd:planeCount()-1
		elseif(msg.addr == "/removeplane") then
			tpd:removePlane()
		  	activePlane = tpd:planeCount() -1 
		  	if(tpd:planeCount() == 1) then activePlane = -1 end
		elseif(msg.addr == "/toggleplane") then
			activePlane = activePlane + 1
		   	activePlane = activePlane % tpd:planeCount() 
		   	if(tpd:planeCount() == 1) then activePlane = -1 end
		   	if(activePlane == 0) then activePlane = 1 end
		elseif(msg.addr == "/toggleplane") then
			addmode = msg
		end
		--]]
		
	end
end



function win:draw(eye)
    
    getOSC() 
    
    
	cam:step()
	cam:enter((eye == "left") and 1 or 0)
	
	--self.clearcolor = winbgcolor
	    
	if(boolrotate) then
	 	gl.PushMatrix()
	 	gl.Rotate(now()*10, 0, 1, 0)
	end
	--gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)
	
	gl.Translate(-2.5, 0, 0)
	
	gl.LineWidth(2.0)
	drawAxes()
	--drawMyCursor()
	
	
	
	local linescale = linethick.value + 0.1
	local pointscale = pointsz.value
	
	drawPlane()
	
	if(boolmousepress) then
	    boolmousepress = false
		selectNode()
	end

	--hoverNode()
	
	if(not blockview) then
		gl.Color(blue[1], blue[2], blue[3])
		if(draw3d) then 
			shapeTexture:bind(0)
			primshader:bind()
				tpd:drawGraphEdges(true, 0.2)
			primshader:unbind()
			shapeTexture:unbind(0)
			
			
			shader:param ("Kd", {red[1], red[2], red[3]})
			shader:bind()
				tpd:drawGraphNodes(true, 0.002*pointscale)
			shader:unbind()
			
			gl.Disable(GL.LIGHTING)
		
		else
			gl.Disable(GL.LIGHTING)
			gl.PushMatrix()
			gl.Translate(0, 0, -0.005)
			tpd:drawGraphEdges(false, linescale)
			gl.PopMatrix()
			
			gl.Color(pink)
			--tpd:drawGraphNodes(false, 10)
			
			for l=1, tpd:graphsize() do
				local ind = l-1
				if(ind ~= selnodes[1] and ind ~= selnodes[2]) then 
					local p = tpd:graphnodepos(ind)
					gl.PushMatrix()
					gl.Translate(p)
					drawBillboardCircle(0)
					gl.PopMatrix()
				end
				
			end
			
		end
		
		--draw all labels
		if(boollabelall) then
				for l=1, tpd:graphsize() do
					local ind = l-1
					local p = tpd:graphnodepos(ind)
					local labelstr = tpd:getnodelabel(ind)
					p[2] = p[2]+0.01
					gl.Color(1.0, 1.0, 1.0)
					graphlabels:draw_3d(win.dim, {p[1], p[2], p[3]}, labelstr)
						
				end
		end
		
		for i=1,2 do 
			local selectednode = selnodes[i]
			if(selectednode~=nil and selectednode > -1) then
				local p = tpd:graphnodepos(selectednode)
				
				if(draw3d) then 
					shader:param ("Kd", {yellow[1], yellow[2], yellow[3]})
					shader:bind()
						
					gl.PushMatrix()
						gl.Translate(p)  
						gl.Scale(0.0025*pointscale, 0.0025*pointscale, 0.0025*pointscale)
						drawSphere (1.0, 10, 10)
					gl.PopMatrix()
					shader:unbind()
				else
				
					gl.PushMatrix()
					gl.Translate(p)
					gl.Color(yellow)
					drawBillboardCircle(0)
					gl.PopMatrix()
					
					--[[
					gl.PushMatrix()
					gl.Translate(0, 0, 0.005)
					gl.PointSize(12)
					gl.Color(yellow)
					gl.Begin(GL.POINTS)	
						gl.Vertex(p[1], p[2], p[3])
					gl.End()
					gl.PopMatrix()
					--]]
				end
				
				if( not boollabelall) then 
					local labelstr = tpd:getnodelabel(selectednode)
					p[2] = p[2]+0.01
					gl.Color(1.0, 1.0, 1.0)
					graphlabels:draw_3d(win.dim, {p[1], p[2], p[3]}, labelstr)
				end
				
				if(n1high) then
				
					gl.PushMatrix()
					gl.Translate(p)
					gl.Color(highcol[i])
					drawBillboardCircle(i)
					gl.PopMatrix()
						
					--neighbors are highligted
					local neighbors = tpd:neighNodes(selectednode)
					
					for k,v in pairs(neighbors) do 
						
						local np = tpd:graphnodepos(v)
						
						gl.PushMatrix()
							gl.Translate(np)
							gl.Color(highcol[i])
							drawBillboardCircle(i)
						gl.PopMatrix()
					
						if( not boollabelall) then 
							if(v ~= selnodes[1] and v ~= selnodes[2] ) then 
								local neighlabelstr = tpd:getnodelabel(v)
								np[2] = np[2]+0.01
								gl.Color(1.0, 1.0, 1.0)
								graphlabels:draw_3d(win.dim, {np[1], np[2], np[3]}, neighlabelstr)
							end
						end
					end
				
				   --[[
				   shader:param ("Kd", {green[1], green[2], green[3]})
				   shader:bind()
				   tpd:drawNeighNodes(selectednode, 0.002*pointscale)
				   shader:unbind()
				   
				   gl.Color(red[1], red[2], red[3])
				   tpd:drawNeighEdges(selectednode, false, linescale)
				   --]]
				end
				
				if( not boollabelall) then 
					if(n1labels) then
						local neighbors = tpd:neighNodes(selectednode)
						for k,v in pairs(neighbors) do 
							local neighlabelstr = tpd:getnodelabel(v)
							local np = tpd:graphnodepos(v)
							np[2] = np[2]+0.01
							gl.Color(1.0, 1.0, 1.0)
							graphlabels:draw_3d(win.dim, {np[1], np[2], np[3]}, neighlabelstr)
						end
					end
				end
				
				
			end
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

    if(boolrotate) then
	 gl.PopMatrix()
	end
	
    cam:leave()
    
    gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    sketch.enter_ortho(self.dim)
    guilabels:draw({35, 30, 0}, "Move Node")
	guilabels:draw({35, 50, 0}, "Drag Node")
	guilabels:draw({35, 70, 0}, "Drag Plane")
	
	guilabels:draw({10, 100, 0}, "Line Thickness")
	guilabels:draw({10, 150, 0}, "Point Size")
	
	
	sketch.leave_ortho()
	
	gui:draw()
end

-------------------------------------------------
-------------------------------------------------

function win:key(event, key)
     --print(key)
	 if(event == "down") then 
	    
		if(key == 27) then
			self.fullscreen = not self.fullscreen
		elseif(key == 101 or key == 69) then --E
            
			self.stereo = not self.stereo
			cam.stereo = self.stereo

			print("stereo ", self.stereo)
		elseif(key == 105 or key == 73) then --i
			tpd:initGraphLayout()
			tpd:testGrid()
			st = 0
			TEMP = 0.5
		elseif(key == 115 or key == 83) then --S
		    --disabled for now, pressing accidentally
		    --saveGraph()
		elseif(key == 108 or key == 76) then --L
		    loadGraph()
		    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		elseif(key == 121 or key == 89) then --Y
			layout3d = not layout3d
			redrawgraph()
		elseif(key == 116 or key == 84) then --T
			draw3d = not draw3d
		elseif(key == 110 or key == 78) then --N
			tpd:bringN1(selnodes[1])
		elseif(key == 109 or key == 77) then --M
			addMode = not addMode	
		elseif(key == 103 or key == 71) then --G
			mouseinteractmode = 1
		elseif(key == 102 or key == 70) then --F
			mouseinteractmode = 2
		elseif(key == 104 or key == 72) then --H
			n1high = not n1high
			tpd:highlightN1(selnodes[1], n1high)
        elseif(key == 111 or key == 79) then --O
		  boolrotate = not boolrotate
		elseif(key == 112 or key == 80) then --P
		  local crrp = tpd:planeCount()
		  tpd:addPlane(crrp)
		  crrp = crrp+1
		  activePlane = tpd:planeCount()-1
		  
		elseif(key == 114 or key == 82) then --R
		  tpd:removePlane()
		  activePlane = tpd:planeCount() -1 
		  if(tpd:planeCount() == 1) then activePlane = -1 end
		     
		elseif(key == 106 or key == 74) then --J
		   activePlane = activePlane + 1
		   activePlane = activePlane % tpd:planeCount() 
		   if(tpd:planeCount() == 1) then activePlane = -1 end
		   if(activePlane == 0) then activePlane = 1 end
		   
		elseif(key == 99 or key == 67) then --C
			addMode = true
			print(cam.eye[1], cam.eye[2], cam.eye[3])
		elseif(key == 49) then --1
			question2(84, 20 , 2, "2D")
			--oscout:send("/quest", 2,  "2D", 84, 22)
		elseif(key == 50) then --2
			question2(84, 20, 2, "3D")
			--oscout:send("/quest", 2,  "3D", 84, 22)
		elseif(key == 51) then --3
			question2(84, 20, 2, "2.5D")
			--oscout:send("/quest", 2,  "2.5D", 84, 22)
		elseif(key == 52) then --4
			question2(84, 20, 2, "2.5DH")
			--oscout:send("/quest", 1, "2D", 84, 22)
		elseif(key == 53) then --5
			question1(20, 1, "2D")
			--oscout:send("/quest", 1,  "3D", 84, 22)
		elseif(key == 54) then --6
			question1(20, 1, "3D")
			--oscout:send("/quest", 1,  "2.5D", 84, 22)
		elseif(key == 55) then --7
			question1(20, 1, "2.5D")
			--oscout:send("/quest", 1,  "2.5D", 84, 22)
		elseif(key == 56) then --7
			question1(20, 1, "2.5DH")
			--oscout:send("/quest", 1,  "2.5D", 84, 22)
		end
	
	elseif(event == "up") then
		if(key == 99 or key == 67) then --C
			addMode = false
		end
	end
	
	cam:key(self, event, key)
	gui:key(event, key)
	
end

-------------------------------------------------

function win:mouse(event, btn, x, y, nclk)
	gui:mouse(event, btn, x, y, nclk)
	
	if(event == "down") then
		boolmousepress = true
	elseif(event == "up") then
	    boolmousepress = false
	    if(nodedragged) then
	    	nodedragged = false
	    	addNodeToPlane(selnodes[1])
	    end
	    
	elseif(event == "drag") then
	    local xdiff = (lastx - x) * 0.01
	    local ydiff = (lasty - y) * 0.01
	    if(mouseinteractmode == 2) then
	      	tpd:movePlane(activePlane, xdiff)
	    elseif(mouseinteractmode == 1) then
			if(selnodes[1] > -1.0 ) then 
				
				local currentpos = tpd:graphnodepos(selnodes[1])
				currentpos[3] = currentpos[3] + xdiff
				tpd:graphnodepos(selnodes[1], currentpos)	
				nodedragged = true
			end
		elseif(mouseinteractmode == 0) then
			if(selnodes[1] > -1.0 ) then 
				local amnt = {-xdiff, ydiff, 0.0}
		        tpd:moveGraph(amnt)
			end
		end
	end
	
	lastx, lasty = x, y
end

-------------------------------------------------

function win:resize()
    cam:resize(self.dim)
	gui:resize(self.dim)
end

-------------------------------------------------

function win:modifiers()
	gui:modifiers(self)
end
