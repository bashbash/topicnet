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



-------------------------------------------------
 
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
 
function drawPlane(ar)
    
	gl.Enable(GL.BLEND)
	gl.Disable(GL.DEPTH_TEST)
	gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
		
    for p=0, tpd:planeCount()-1 do
       local depth = tpd:planeDepth(p)
        
	   if( p == activePlane) then gl.Color(1.0, 0.4, 0.1, 1.0) 
	   else  gl.Color(1.0, 1.0, 1.0, 0.5) end
	   gl.LineWidth(0.5)
	  
	   
	   gl.Begin(GL.LINES)
	   		for div=0, ar, 0.5 do
	   		  gl.Vertex(div, ar, depth)
	   		  gl.Vertex(div, 0.0, depth)
	   		  
	   		  gl.Vertex(ar, div, depth)
	   		  gl.Vertex(0.0, div, depth)
	   		end
	   gl.End()
	   
	   --[[
		gl.Color(1.0, 1.0, 1.0, 0.08)
		gl.Begin(GL.POLYGON)
			gl.Vertex(0.0, ar, depth)
			gl.Vertex(0.0, 0.0, depth)
			gl.Vertex(ar, 0.0, depth)
			gl.Vertex(ar, ar, depth)	
	   gl.End()
	   --]]
	   
	   
    end
    
    gl.Enable(GL.DEPTH_TEST)
	gl.Disable(GL.BLEND)
end

-------------------------------------------------

 
function drawMyCursor(dev, devpos, dim)
	
    local pos = glu.UnProject(devpos[1], devpos[2], 0.01)
	local sc = 0.0015

    gl.Color(devc_col[dev])
    
	gl.LineWidth(4.0)
	gl.Begin(GL.LINES)
	    
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1]+sc*2, pos[2]-sc*2, pos[3]);
	    
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1], pos[2]-sc, pos[3]);
		
		gl.Vertex(pos[1], pos[2], pos[3]);
		gl.Vertex(pos[1]+sc, pos[2], pos[3]);
	
	gl.End()
end


 
function drawAxes(dim)
	
	--local dim = win.dim
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


---------------------------------------------------




---------------------------------------------------


local offset, img, tex
local primshader, shader, billshader
local graphlabels

function initShaders(cntx)
	shader = Shader{
	ctx = cntx,
	file = LuaAV.findfile("mat.phong.shl"),
	param = {
			La = {0.2, 0.2, 0.2},
			Ka = {0.3, 0.3, 0.3},
			Ks = {0.4, 0.4, 0.4},
			Kd = {0.8, 0.5, 0.4},
		}
	}

	primshader = Shader{
		ctx = cntx,
		file = LuaAV.findfile("stylized_line.shl"),
		param = {
			haloColor = {0.4, 0.4, 0.4, 1.0},
		}
	}
	
	
	billshader = Shader{
		ctx = cntx,
		file = LuaAV.findfile("vd.billboard.shl")
	}
	
	offset = billshader:attr("offset")
	
	img = Image(LuaAV.findfile("circle.png"))
	
	tex = Texture(cntx)
	tex:fromarray(img:array())
	
	
	--------------------------------------
	graphlabels = Label{
		ctx = cntx,
		fontfile = LuaAV.findfile("VeraMono.ttf"),
		--alignment = "LEFT",
		color = {0.8, 0.2, 0.5},
		size = 14,
		--bg = true
	}
	----------------------------------------
	
end

function drawBillboardCircle(sc, booltrans)
	
    if(booltrans) then 
    	gl.Enable(GL.BLEND)
		gl.Disable(GL.DEPTH_TEST)
    	gl.BlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
    else
    	gl.Disable(GL.BLEND)
		gl.Enable(GL.DEPTH_TEST)
    	gl.Enable(GL.ALPHA_TEST)
    	gl.AlphaFunc(GL.GREATER, 0.2)
    end
    
    gl.PushMatrix()
    local scale = sc*0.2 + 0.22
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
	
	 if(booltrans) then
    	gl.Disable(GL.BLEND)
    	gl.Enable(GL.DEPTH_TEST)
    else
    	gl.Disable(GL.ALPHA_TEST)
    end
end

--local nodecol = {247/255, 59/255, 81/255}
local nodecol = {100/255, 100/255, 200/255}
local pink = {241/255, 93/255, 111/255}
local edgecol = {98/255, 152/255, 205/255}

local pointscale = pointsz.value
local linescale = 1.5


function drawGraph3D()
    gl.Color(edgecol[1], edgecol[2], edgecol[3])
	primshader:bind()
		tpd:drawGraphEdges(true, 1.0)
	primshader:unbind()
	
	shader:param ("Kd", {nodecol[1], nodecol[2], nodecol[3]})
	shader:bind()
		tpd:drawGraphNodes(true, 0.002*pointscale)
	shader:unbind()
	
	gl.Disable(GL.LIGHTING)
end



function drawGraph2D()
	gl.Color(edgecol[1], edgecol[2], edgecol[3])
	gl.Disable(GL.LIGHTING)
	
	gl.PushMatrix()
	gl.Translate(0, 0, -0.005)
		
		tpd:drawGraphEdges(false, linescale)
		
	gl.PopMatrix()
		
	gl.Color(pink)
	tpd:drawGraphNodes(false, 10)
		
	--[[
	for l=1, tpd:graphsize() do
		local ind = l-1
		
		local p = tpd:graphnodepos(ind)
		gl.PushMatrix()
		gl.Translate(p)
		drawBillboardCircle(0.01)
		gl.PopMatrix()

	end
	--]]

end



function drawAllLabels()
	for l=1, tpd:graphsize() do
		local ind = l-1
		local p = tpd:graphnodepos(ind)
		local labelstr = tpd:getnodelabel(ind)
		p[2] = p[2]+0.01
		--gl.Color(1.0, 1.0, 1.0)
		gl.Color(0.2, 0.2, 0.2)
		graphlabels:draw_3d(win.dim, {p[1], p[2], p[3]}, labelstr)
			
	end
end

---------------------------------------------------