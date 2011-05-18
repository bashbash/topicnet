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

local shader = Shader{
	ctx = ctx,
	file = LuaAV.findfile("stylized_line.shl"),
	param = {
		haloColor = {0.8, 0.2, 0.2, 1.0},
	}
}

local SPshade = Shader{
	ctx = ctx,
	file = LuaAV.findfile("stylized_primitive.shl")
}

----------------------------------------------

local cam = Camera()


local RADIUS = 0.05
local HALOSIZE = 1.1


----------------------------------------------
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

SPshade:param("radyus", 0.1) 

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


----------------------------------------------

function win:draw()
	cam:step()
	cam:enter()

  	
	
	local p1 = {0.0, 0.0, 0.0}
	local p2 = {2.0, 2.0, -1.0}
	local tang = vec3.sub(p1, p2)
	tang = vec3.normalize(tang)
	
	--SPshade:bind()
	shader:param("viewvec", cam.eye)
	shapeTexture:bind(0)
	shader:bind()
	
	
	gl.Color(0.0, 1.0, 1.0)
	
	gl.Begin(GL.QUADS)
		gl.Normal(tang);
		gl.TexCoord(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0)
		gl.Vertex(p1);
		gl.TexCoord(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0)
		gl.Vertex(p1);
		
		gl.Normal(tang);
		gl.TexCoord(RADIUS * HALOSIZE, RADIUS, 0.0, 0.0)
		gl.Vertex(p2);
		gl.TexCoord(-1.0*RADIUS * HALOSIZE, RADIUS, 0.0, 0.0)
		gl.Vertex(p2);
	gl.End()
	
	shader:unbind()
	shapeTexture:unbind(0)

	cam:leave()

end
