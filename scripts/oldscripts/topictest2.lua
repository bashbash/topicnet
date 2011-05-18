--LuaAV.addmodulepath(script.path.."/modules")
-------------------------------------------
local gl = require("opengl")
local GL = gl
-------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")
local sketch = require("opengl.sketch")

-------------------------------------------
require("topicnet")
local TopNet = topicnet.Topicnet

-------------------------------------------

local Camera = require("glutils.navcam")
local Grid = require("glutils.cubegrid")

-------------------------------------------

local ctx = "3d net test"
win = Window(ctx, 0, 0, 512, 512)
win.sync = true
local boolstereo = false

----------------------------------------------

local shader = Shader{
	ctx = ctx,
	file = LuaAV.findfile("mat.phong.shl"),
	param = {
		La = {0.2, 0.2, 0.2},
	}
}

local SPshade = Shader{
	ctx = ctx,
	file = LuaAV.findfile("stylized_primitive.shl")
}

----------------------------------------------

local cam = Camera()

cam:movex(-2.0);
cam:movey(2.0);
cam:movez(-2.0)

local grid = Grid(ctx)
local boolGrid = true



----------------Parse Data--------------------
local tpd = TopNet()
--local file = "/data/smallworld_10_20.xml"
local file = "/data/4test.xml"
local sourcepath = script.path .. file
--print("path ", sourcepath)
tpd:loadData(sourcepath)

--------------------------------------------
------calculate ray intersection------------

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


----------------------------------------------

local lastx
local lasty

local cvec1 = {0.0, 0.0, 0.0}
local cvec2 ={0.0, 0.0, 0.0}

local ray = {0.0, 0.0, 0.0}
local selectednodeindex = -1

local boolmousepress = false

function win:mouse(event, btn, x, y)
	--cam:mouse(self, event, btn, x, y)
	if(event == "down") then
		boolmousepress = true
	elseif(event == "up") then
	    boolmousepress = false
	end
	lastx, lasty = x, y
end
-----------------------------------------------
-- adjust camera to window dimensions

function win:resize()
	cam:resize(self)
	--gui:resize(self)
end
----------------------------------------------

local st = 0
local coolexp = 2.0
local maxstep = 550

local layout3d = false
local draw3d = false

local n1high = false
local n2high = false

local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	coolexp = 2.0
	maxstep = 550
	
end

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
		elseif(key == 116) then --t
			draw3d = not draw3d
			--redrawgraph()
		elseif(key == 110) then --N
			n1high = not n1high
			if(n1high) then
				tpd:n1setZ(0.4)
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
		end
	end
	cam:key(self, event, key)
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

--[[
local font = require("font")
local Font = require("font.Font")

local font = Font(LuaAV.findfile("VeraMono.ttf"), 10)
--local font = font.Font.new(LuaAV.findfile("ArialUnicode.ttf"), 14)
--]]

local sz = tpd:graphsize()
print("graphsize ", sz)

SPshade:param("radyus", 0.005) 

shader:param ("Ka", {0.3, 0.3, 0.3})
shader:param ("Kd", {0.7, 0.4, 0.4})
shader:param ("Ks", {0.4, 0.4, 0.4})

gl.Enable(GL.LIGHT0)
gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)

tpd:initGraphLayout()
tpd:randomizeGraph(layout3d)

local coolingschedule = {}
--------------------------------------------

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
			
			local intersects = rayintersect(cvec1, ray, p, 0.01)
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
function win:draw()

	cam:update()
	cam:enter()
	
	
	gl.Light(GL.LIGHT0, GL.POSITION, cam.eye)
	
	gl.LineWidth(2.0)
	drawAxes()
	
	
	if(boolmousepress) then
		selectNode()
	end
	
	
	--[[ camera ray test
	    local pntsz = 4.0
		local clr = 0.0
		
		for p=0, 20 do
		    local pointonray = vec3.add(cvec1, vec3.scale(ray, clr))
			gl.PointSize(pntsz)
			gl.Begin(GL.POINTS)
				gl.Color(1.0-clr, clr, 0.3)
				gl.Vertex(pointonray)
			gl.End()
			
			pntsz = pntsz + 1
			clr = clr + 0.05
		end
	--]]
	
	local center = {2.0, 2.0, 0.0}
	local camdist = vec3.mag(vec3.sub(cam.eye, center))
	camdist = math.max(1.0, camdist)
    local pointscale =  (4.0 / camdist) * 4.0 + 4.0
	local linescale = 4.0 / camdist
			
			
	if(draw3d) then
	      
	        shader:param ("Ka", {0.3, 0.3, 0.3})
			shader:param ("Kd", {0.7, 0.4, 0.4})
			shader:bind()
				tpd:drawGraphNodes(true, 5.0)
			shader:unbind()
			----[[
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
		
			
			--]]
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
			
			
			--print(pointscale)
			--tpd:drawGraph()
			
			--[[
			
			
			
			gl.PointSize(pointscale)
			gl.Color(1.0, 0.7, 0.1)
			gl.Begin(GL.POINTS)
			for s=1, sz do
				local ind = s-1
				if(ind ~= selectednodeindex) then
					local p = tpd:graphnodepos(ind)
					gl.Vertex(p[1], p[2], p[3])
				end
			end
			gl.End()
			
			--print("selectednode: ", selectednodeindex)
			gl.PointSize(pointscale+5.0)
			gl.Color(0.4, 0.7, 1.0)
			gl.Begin(GL.POINTS)
			if(selectednodeindex > -1.0 and selectednodeindex < sz) then
			    local p = tpd:graphnodepos(selectednodeindex)
				gl.Vertex(p[1], p[2], p[3])
			end
			gl.End()
			--]]
			tpd:drawGraphEdges(false, linescale)
			tpd:drawGraphNodes(false, pointscale)
			
			if(n1high) then 
				tpd:highlightN1() 
				
			end
			
			if(n2high) then 
				tpd:highlightN2()
				
			end
			
			
	end
	
	
	----[[
	if(st < maxstep and coolexp > 0.0001) then
	    coolingschedule[st] = coolexp
		--print("step", st, " @ coolexp", coolexp) 
		tpd:stepLayout(layout3d, coolexp)
	 	coolexp = coolexp * 0.98
	 	--coolexp = coolexp * math.exp(-0.0001*st)
	 	st = st+1 	
	end
	--]]
	
	
	
	--[[ draw cooling 
	local dim = self.dim
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
	--]]
	
    cam:leave()
end
