--LuaAV.addmodulepath(script.path.."/modules")
-------------------------------------------
local gl = require("opengl")
local GL = gl
-------------------------------------------

local vec3 = require("space.vec3")
local Shader = require("opengl.Shader")

-------------------------------------------
require("topicnet")
local TopNet = topicnet.Topicnet

-------------------------------------------

local Camera = require("glutils.navcam")

-------------------------------------------

local ctx = "3d net test"
win = Window(ctx, 0, 0, 512, 512)

----------------------------------------------


local lightshade = Shader{
	ctx = ctx,
	file = LuaAV.findfile("lightTest.shl")
}

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


----------------------------------------------

local ambientLight = { 0.2, 0.2, 0.2, 1.0 }
local diffuseLight = { 0.6, 0.9, 0.9, 1.0 }
local specularLight = { 0.2, 0.2, 0.6, 1.0 }
local position = { 0.0, 0.0, 10.0, 1.0 }

--Assign created components to GL_LIGHT0
gl.Light(GL.LIGHT0, GL.AMBIENT, ambientLight)
gl.Light(GL.LIGHT0, GL.DIFFUSE, diffuseLight)
gl.Light(GL.LIGHT0, GL.SPECULAR, specularLight)
gl.Light(GL.LIGHT0, GL.POSITION, position)

function win:init()
       --Assign created components to GL_LIGHT0
    gl.Enable(GL.DEPTH_TEST)
	gl.Enable(GL.LIGHTING)
	gl.Enable(GL.LIGHT0)
	
    gl.Light(GL.LIGHT0, GL.AMBIENT, ambientLight)
    gl.Light(GL.LIGHT0, GL.DIFFUSE, diffuseLight)
    gl.Light(GL.LIGHT0, GL.SPECULAR, specularLight)
    gl.Light(GL.LIGHT0, GL.POSITION, position)
end


function win:draw()
	cam:step()
	cam:enter()
	
	gl.Enable(GL.DEPTH_TEST)
	gl.Enable(GL.LIGHTING)
	gl.Enable(GL.LIGHT0)
	
	position[2] = -3 + math.random(5)
	gl.Light(GL.LIGHT0, GL.POSITION, position)
	
	lightshade:param("viewvec", cam.eye)
	lightshade:bind()

	drawSphere(2.0, 20, 20)

	lightshade:unbind()
	
	gl.Disable(GL.DEPTH_TEST)
	gl.Disable(GL.LIGHTING)
	
	cam:leave()

end
