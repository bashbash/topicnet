--LuaAV.addmodulepath(script.path.."/modules")
-------------------------------------------
local gl = require("opengl")
local GL = gl
-------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")
local sketch = require("opengl.sketch")

local Camera = require("glutils.navcam")

-------------------------------------------

require("topicnet")
local TopNet = topicnet.Topicnet

-------------------------------------------

local context = "3d net test"
win = Window(context, 0, 0, 512, 512)
win.sync = true

----------------------------------------------
----------------Parse Data--------------------
local tpd = TopNet()
--local file = "/data/smallworld_10_20.xml"
local file = "/data/4test.xml"
local sourcepath = script.path .. file
--print("path ", sourcepath)
tpd:loadData(sourcepath)

local sz = tpd:graphsize()
print("graphsize ", sz)

----------------------------------------------

local Gui = require("gui.context")
local Rect = require("gui.rect")
local Slider = require("gui.slider")

local gui = Gui{
	ctx = context,
	dim = win.dim,
}

local rslider = Slider{
	rect = Rect(10, 25, 100, 10),
	value = 0.5,
	range = {0, 1},
}

gui:add_view(rslider)
----------------------------------------------

local cam = Camera()

cam:movex(-2.0);
cam:movey(2.0);
cam:movez(-2.0)

-----------------global variables-------------

local boolstereo = false
local layout3d = false
local draw3d = true
local planeCount = 0.0

local lastx
local lasty

local cvec1 = {0.0, 0.0, 0.0}
local cvec2 ={0.0, 0.0, 0.0}

local ray = {0.0, 0.0, 0.0}
local selectednodeindex = -1

local boolmousepress = false

local n1high = false
local n2high = false

local MAXSTP = 550
local COOLING = 2.0

local st = 0
local coolexp = COOLING
local maxstep = MAXSTP




local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	coolexp = COOLING
	maxstep = MAXSTP
	
end
----------------------------------------------

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

----------------------------------------------

-- adjust camera to window dimensions

function win:resize()
	--cam:resize(self)
	gui:resize(self)
end
----------------------------------------------

function win:mouse(event, btn, x, y, nclk)
	--cam:mouse(self, event, btn, x, y)
	gui:mouse(event, btn, x, y, nclk)
	
	if(event == "down") then
		boolmousepress = true
	elseif(event == "up") then
	    boolmousepress = false
	end
	
	lastx, lasty = x, y
end

-----------------------------------------------

function win:modifiers()
	gui:modifiers(self)
end

-----------------------------------------------
local interactMode = 1 

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
		elseif(key == 115 or key == 83) then --s
			boolstereo = not boolstereo
			win.sync = boolstereo
			win.stereo = boolstereo
			cam.stereo = boolstereo
			print('stereo:', win.stereo)
		elseif(key == 121) then --3
			layout3d = not layout3d
			redrawgraph()
		elseif(key == 116) then --T
			draw3d = not draw3d
			--redrawgraph()
		elseif(key == 110) then --N
			n1high = not n1high
			if(n1high) then
				tpd:n1setZ(0.5)
			else
				tpd:n1setZ(0.0)
			end
		
	    elseif(key == 109) then --M
			n2high = not n2high
			if(n2high) then
				tpd:n2setZ(0.2)
			else
				tpd:n2setZ(0.0)
			end
			
		elseif(key == 99) then --C
			interactMode = 1
		elseif(key == 103) then --G
			interactMode = 2
		elseif(key == 102) then --F
			interactMode = 3

		elseif(key == 112) then --P
		      planeCount = planeCount + 1
		elseif(key == 114) then --R
		      planeCount = planeCount - 1
		      if( planeCount < 0 ) then planeCount = 0 end
		end
	end
	
	if(interactMode == 1) then 
		cam:key(self, event, key)
	elseif(interactMode == 2) then
		moveNode(key)
	end
	
	gui:key(event, key)
end
----------------------------------------------


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

--------------------------------------------

local 
function addPlane()
    gl.Color(1.0, 1.0, 1.0, 0.3)
    
    for p=0, planeCount do
    
		gl.Enable(GL.BLEND)
		gl.Disable(GL.DEPTH_TEST)
		gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
			
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, 4.0, 0.5*p)
			gl.Vertex(0.0, 0.0, 0.5*p)
			gl.Vertex(4.0, 0.0, 0.5*p)
			gl.Vertex(4.0, 4.0, 0.5*p)	
	   gl.End()
	   
	   gl.Enable(GL.DEPTH_TEST)
	   gl.Disable(GL.BLEND)
	   
	   gl.LineWidth(0.7)
	   gl.Begin(GL.LINE_STRIP)
			gl.Vertex(0.0, 4.0, 0.5*p)
			gl.Vertex(0.0, 0.0, 0.5*p)
			gl.Vertex(4.0, 0.0, 0.5*p)
			gl.Vertex(4.0, 4.0, 0.5*p)	
			gl.Vertex(0.0, 4.0, 0.5*p)
	   gl.End()
    end
   --planeCount = planeCount + 1
end
--------------------------------------------

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

----------------------------------------------

tpd:initGraphLayout()
tpd:randomizeGraph(layout3d)

local coolingschedule = {}

----------------------------------------------

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

----------------------------------------------
------calculate ray intersection--------------

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

		if(not draw3d) then
		
			tpd:n1setZ(0.0)
			tpd:n2setZ(0.0)
			n1high = false
			n2high = false
	    
	    end 
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

----------------------------------------------



function win:draw()

    --gui:draw()   
    ----[[
    cam:step()
	cam:enter()
	
	
	gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)
	
	gl.LineWidth(2.0)
	drawAxes()
	
	if(boolmousepress) then
		selectNode()
	end
	
	local center = {2.0, 2.0, 0.0}
	local camdist = vec3.mag(vec3.sub(cam.eye, center))
	camdist = math.max(1.0, camdist)
    local pointscale =  (4.0 / camdist) * 4.0 + 4.0
	local linescale = 4.0 / camdist
	
	addPlane()
			
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
    --]]
     
end
