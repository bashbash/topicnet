--LuaAV.addmodulepath(script.path.."/modules")
-------------------------------------------
local gl = require("opengl")
local GL = gl
-------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")

local Texture = require("opengl.Texture")
local sketch = require("opengl.sketch")

local Array = require("Array")
-------------------------------------------
require("topicnet")
local TopNet = topicnet.Topicnet

-------------------------------------------

local Camera = require("glutils.navcam")

-------------------------------------------

local ctx = "3d net test"
win = Window(ctx, 0, 0, 512, 512)

----------------------------------------------

local SPshade = Shader{
	ctx = ctx,
	file = LuaAV.findfile("stylized_line.shl")
}

local myshade = Shader{
	ctx = ctx,
	file = LuaAV.findfile("stylized_primitive.shl")
}

----------------------------------------------

local RADIUS = 0.05
local WRADIUS = 0.01
local HALOSIZE = 0.05

local SIZE = 32.0

local TSIZE = 512.0

local HSIZE = (SIZE/2.0)
local DSIZE = (SIZE*(SIZE+1))


local vertices = {} --holds vertex table

local pos = {}
local col = {}
local norm = {}
local zdiff = {}
local radius = {}
local rot = {}
----------------------------------------------

local cam = Camera()



local lastx
local lasty

function win:mouse(event, btn, x, y)
     	--cam:mouse(self, event, btn, x, y)
		lastx, lasty = x, y
end
-----------------------------------------------
-- adjust camera to window dimensions

function win:resize()
	cam:resize(self)
end
----------------------------------------------


function win:key(event, key)
    --print(key)
    if(event == "down") then
		if(key == 27) then
			--self.fullscreen = not self.fullscreen
			self.border = not self.border
			if(self.border) then
				self.dim = {512, 512}
			else
				self.dim = {1400, 900}
			end
		end
	end
	cam:key(self, event, key)
end
----------------------------------------------

local shapeTexture = Texture(ctx)
local 
function initTextures()

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


----------------------------------------------

local 
function initStructure()
     
    for i=1, SIZE do
	for j=1, SIZE+1 do 
    	
    	local position = {}
    	local color = {}
    	
    	local a = i*(SIZE+1)+j
		
		local ai = i / HSIZE * math.pi
		local aj = j / HSIZE * math.pi

		local d = {math.sin(ai), math.cos(ai), 0.0}
		
		position[1] = (d[1] * 2.0 + d[1] * math.cos(aj)) * 0.6
		position[2] = (d[2] * 2.0 + d[2] * math.cos(aj)) * 0.6;
		position[3] = (d[3] * 2.0 + d[3] * math.cos(aj)) * 0.6 + math.sin(aj) * (0.75 + math.sin(ai) * 0.25)

		color[1] = (math.sin(aj*8 + ai))
		color[2] = (1.0 - math.sin(aj*8 + ai)) * 0.5
		color[3] = 0.3	
		
		pos[a] = position
		col[a] = color
        --radius[a] = RADIUS + WRADIUS * math.sin(aj*8 + ai)
        radius[a] = RADIUS
		rot[a] =  (j / HSIZE) * 4 + (i / HSIZE)
		
		--print(i, j)
		--print("vertex: ", a, " radyus: ", radius[a])

	end
	end
	
	
    --create vertex normals

	for i=1, SIZE do
	for j=1, SIZE+1 do
	
		local a = i*(SIZE+1)+j
		local n = {}
		local r
		
		if (j == SIZE+1) then 
		    n = {0.0, 0.0, 1.0}
			r = 0.5
		else 
		    local pos1 = pos[a]
		    local pos2 = pos[a+1]
		    n = vec3.sub(pos1, pos2)
		    r = radius[a] - radius[a+1]
		end
        
        --print("at: ", a, " norm ", n[1])
        local mgntd = vec3.mag(n)
		n = vec3.normalize(n)
		
		norm[a] = n
		zdiff[a] = r / mgntd
	end
	end
end

----------------------------------------------

initStructure()
initTextures()

print("size of radius: ", #radius)
print("size of norm: ", #norm)


----------------------------------------------

local 
function renderStreamlineStrip(a)
	--render a single part of a streamline strip
	local halofactor = 1.0 + 2.0 * HALOSIZE
	
	--simple rendering	
	gl.Color(col[a])
	--gl.Color(1.0, 0.8, 0.2)
	gl.Normal(norm[a])

	gl.TexCoord(-1.0*radius[a] * halofactor, radius[a], rot[a], zdiff[a])
	gl.Vertex(pos[a])
   
    gl.TexCoord(radius[a] * halofactor, radius[a], rot[a], zdiff[a])
	gl.Vertex(pos[a])
end


local 
function renderLine()
	for i=1, SIZE do
		gl.Begin(GL.LINE_STRIP)
	for j=1, SIZE+1 do
		local aj = j / HSIZE * math.pi * 32
		local a = i*(SIZE+1)+j
	    gl.Vertex(pos[a])
	end
		gl.End()
	end
end


local 
function renderobject()

    for i=1, SIZE do
		gl.Begin(GL.QUAD_STRIP)
	for j=1, SIZE+1 do 
		local aj = j / HSIZE * math.pi * 32
		local a = i*(SIZE+1)+j
		renderStreamlineStrip(a)
	end
		gl.End()
	end

end

local 
function render()
	--rendering with shader
	
	shapeTexture:bind(0)

	SPshade:param("viewvec", cam.eye)
	SPshade:bind()

	renderobject()

	SPshade:unbind()
	
	shapeTexture:unbind(0)
	
end


local 
function myrender()
	myshade:param("radyus", 0.03) 
	myshade:param("viewpoint", cam.eye)
	
	myshade:bind()
	
	renderobject()
	
	myshade:unbind()
end



----------------------------------------------

local ambientLight = { 0.3, 0.3, 0.3, 1.0 }
local diffuseLight = { 0.9, 0.9, 0.9, 1.0 }
local specularLight = { 0.5, 0.8, 0.9, 1.0 }
local position = { 0.0, 2.0, 2.0, 1.0 }


function win:init()
       --Assign created components to GL_LIGHT0
    gl.Enable(GL.DEPTH_TEST)
	gl.Enable(GL.LIGHTING)
	gl.Enable(GL.LIGHT0)
	
    gl.Light(GL.LIGHT0, GL.AMBIENT, ambientLight)
    gl.Light(GL.LIGHT0, GL.DIFFUSE, diffuseLight)
    gl.Light(GL.LIGHT0, GL.SPECULAR, specularLight)
    gl.Light(GL.LIGHT0, GL.POSITION, position)
    
    gl.Material(GL.FRONT, GL.SHININESS, 10.0)
end

function win:draw()
	cam:step()
	cam:enter()
	
	gl.Enable(GL.DEPTH_TEST)
	gl.Enable(GL.LIGHTING)
	gl.Enable(GL.LIGHT0)
	
	--[[
	position[1] =  cam.eye[1]
	position[2] =  cam.eye[2] + 2
	position[3] =  cam.eye[3]
	gl.Light(GL.LIGHT0, GL.POSITION, position)
	--]]
	
	gl.Color(1.0, 1.0, 1.0)
	gl.PointSize(20.0)
	gl.Begin(GL.POINTS)
		gl.Vertex(position[1], position[2], position[3])
	gl.End()
	
	
	render()
	
	
	gl.Disable(GL.DEPTH_TEST)
	gl.Disable(GL.LIGHTING)
	
	cam:leave()

end
