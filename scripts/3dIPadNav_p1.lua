--receive identify node and manage that
--manage multiple ipad inputs from multiple devices

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

Label = require("Label")
------------------Parse Data---------------------

local datfile = script.path .. "/3dIPadNav_data.lua"
dofile( datfile )

-------------------------------------------------
local context = "3d net test"
win = Window{
	title = context, 
	origin = {0, 0}, 
	dim = {500, 500},
	mousemove = true,
}

win.sync = true
win.stereo = false
--win.cursor = false

--------------------GUI------------------------------

local guifile = script.path .. "/3dIPadNav_gui.lua"
dofile( guifile )

startGui(context, win.dim)


---------------ip handling---------------------------

cur_col = {{0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}, {1.0, 0.0, 0.0}, {1.0, 1.0, 0.0}}

local device = 1  --for mouse interaction do device=0
local NUM_DEVICES = 0

local device_ips = {}

ipadlastx = {0.0, 0.0, 0.0, 0.0}
ipadlasty = {0.0, 0.0, 0.0, 0.0}

	
local send_port = 8080
local receive_port = 8080
local oscin  = osc.Recv(receive_port) 
local oscouts = {} 


------------------global variables---------------
local boolstereo = false
local layout3d = true
local draw3d = true

local activePlane = -1

local boolmousepress = false
local nodedragged = false

local blockview = false

local boollabelall = true

local n1high = false
local n1labels = false

local addMode = false
local mouseDown = false

AREA = 5.0
local MAXSTEP = 550
local TEMP = 0.5

local st = 0


local boolrotate = false

local lastx = 0.0
local lasty = 0.0

local cvec1 = {0.0, 0.0, 0.0}
local cvec2 ={0.0, 0.0, 0.0}

local ray = {0.0, 0.0, 0.0}

local selectnodes = {}
local hovernodes = {}
local displaynodes = {}

local lastselectnode = 0
local lasthovernode = 0

local
function exists(list, value)
	local boolfound = false
	local index = -1
	for k,v in pairs(list) do
		if(value == v) then 
			boolfound = true
			index = k
			break
		end
	end
	
	return boolfound, index
end

local
function existshover(list, value)
	local boolfound = false
	for k,v in pairs(list) do
		if(value == v[1]) then 
			boolfound = true
			break
		end
	end
	return boolfound
end



---------------------colors----------------------
local winbgcolor = {0.9, 0.9, 0.9}


local highcol = {}
highcol[1] = {96/255, 176/255, 71/255}
highcol[2] = {255/255, 171/255, 52/255}

-------------------------------------------------



local pubsText = Label{
	ctx = context,
	fontfile = LuaAV.findfile("VeraMono.ttf"),
	alignment = "LEFT",
	color = {0.2, 0.2, 0.2},
	bg = true,
	bgcolor = {0.8, 0.8, 0.8},
	size = 12,
	maxwidth = 300
}


-------------------------------------------------

local cam = Camera()

--cam:movex(-2.5);
cam:movey(2.5);
cam:movez(-1.0)

cam.stereo = false
cam.eye_sep = -0.07




local function redrawgraph()
	tpd:initGraphLayout()
	tpd:randomizeGraph(layout3d)
	print("islayout3d ", layout3d)
	st = 0
	TEMP = 0.5
	maxstep = MAXSTP
	
end


-------------------------------------------------

local drawfile = script.path .. "/3dIPadNav_drawings.lua"
dofile( drawfile )

initShaders(context)



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
---------------clear all selection-----------------


local 
function clearAll()
	tpd:selectedNode(-1, false)
	n1high = false
	while (tpd:planeCount() > 1) do 
		tpd:removePlane()
	end
	activePlane = -1 	  
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
function hoverNode(d)
    
    local p1, p2
    if (device == 0) then
    	p1, p2 = cam:picktheray(lastx, lasty)
    else
    	p1, p2 = cam:picktheray(ipadlastx[d], ipadlasty[d])
    end
    
	cvec1 = p1[1]
	cvec2 = p2[1]
	
	ray = vec3.sub(cvec2, cvec1)
	local rayscale = vec3.scale (ray, 0.01)
	local selectednodeindex
	
	local inselectlist, indx
	
	for l=1, tpd:graphsize() do
		local ind = l-1
		local p = tpd:graphnodepos(ind)
		
		local intersects = rayintersect(cvec1, ray, p, 0.02)
		--print(ind, " intersects=", intersects)
		if(intersects) then
		    
			selectednodeindex = ind
			
			inselectlist, indx = exists (selectnodes, ind)
			if( not inselectlist and lasthovernode ~= ind) then 
				
				local winw, winh = unpack(win.dim)
				local screenpos = glu.Project(p[1], p[2], p[3])
				
				screenpos[1] = screenpos[1] / winw
				screenpos[2] = (winh - screenpos[2]) / winh
				print("send device id: ", d, device_ips[d], send_port)
				
				oscouts[d]:send("/rollover", screenpos[1], screenpos[2], ind, tpd:getnodelabel(ind))  --omit  tpd:getnodeid(ind)
				print("sent /rollover:  ", screenpos[1], screenpos[2], ind)
			end
			
			break
		else
			selectednodeindex = -1
		end
	end
	
	
	if(selectednodeindex ~= -1 and lasthovernode ~= selectednodeindex and not inselectlist) then 
	   --add to hover list 
	     local inlist = existshover (hovernodes, selectednodeindex)
	     
	     if(not inlist) then 
	        local hoveritem = {selectednodeindex, now()}
	     	table.insert(hovernodes, hoveritem)
	     	--print("inserted node to hover: ", selectednodeindex)
	     else
	     	--print("item already in hover list: ", selectednodeindex)
	     end
	end
	
	lasthovernode = selectednodeindex
	
end

local 
function displayNode( indeks )
	local selectednodeindex = indeks

	if(selectednodeindex > -1 and selectednodeindex < (tpd:graphsize() + 1) ) then 
		local inlist, ind = exists (displaynodes, selectednodeindex)
	    if(not inlist) then 
			table.insert (displaynodes, selectednodeindex)
			print("inserted node to displaynodes: ", selectednodeindex)
		else
			table.remove(displaynodes, ind)
			selectednodeindex = -1
		end
	end
end


local 
function ipadSelectNode( indeks )
	local selectednodeindex = indeks
	if(selectednodeindex > -1 and selectednodeindex < (tpd:graphsize() + 1) ) then 
		local inlist, ind = exists (selectnodes, selectednodeindex)
	    if(not inlist) then 
			--add to selected list
			table.insert (selectnodes, selectednodeindex)
			lastselectnode = selectednodeindex
			--print("inserted node to selectnodes: ", selectednodeindex)
		else
			--print("item already in select list: ", selectednodeindex)
			table.remove(selectnodes, ind)
			selectednodeindex = -1
			lastselectnode = -1
		end
	end	
end


local 
function mouseSelectNode()
    print("ipad interaction should not visit here")
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
			
			--for testing text only
			displaynodes = {}
			table.insert (displaynodes, selectednodeindex)
			print("test: ", selectednodeindex)
			--for testing text only
			
			
			local winw, winh = unpack(win.dim)
			local screenpos = glu.Project(p[1], p[2], p[3])
			
			screenpos[1] = screenpos[1] / winw
			screenpos[2] = (winh - screenpos[2]) / winh
			
			break
		else
			selectednodeindex = -1
			
		end
	end
	
	lastselectnode = -1
	
	if(selectednodeindex ~= -1 ) then 
		
		local inlist, ind = exists (selectnodes, selectednodeindex)
	    if(not inlist) then 
			--add to selected list
			table.remove (hovernodes, selectednodeindex)
			table.insert (selectnodes, selectednodeindex)
		    --print("inserted node to selectnodes: ", selectednodeindex)
		    lastselectnode = selectednodeindex
		else
			--print("item already in select list: ", selectednodeindex)
			table.remove(selectnodes, ind)
		end
	end
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

--start graph layout algorithm
--tpd:initGraphLayout()
--tpd:randomizeGraph(layout3d)

--start with a pre-calculated graph 
loadGraph()
st = MAXSTEP




local 
function getOSC() 
	for msg in oscin:recv() do
		
	    if(msg.addr == "/handshake") then 
	    	local ipadaddr = " "
	    	ipadaddr = ipadaddr .. unpack(msg)
	    	ipadaddr = string.sub(ipadaddr, 2)
	    	--print(string.len(ipadaddr))
	    	print("hello ipad: ", ipadaddr)
	    	
	    	local found = exists(device_ips, ipadaddr)
	    	if(found[1]) then 
	    		--do nothing for now, then id is found[2]
	    	else
	    	    NUM_DEVICES = NUM_DEVICES + 1
	    	    local newid = NUM_DEVICES
	    		device_ips[newid] = ipadaddr
	    		oscouts[newid] = osc.Send(ipadaddr, send_port)
	    		--confirm the device id 
	    		oscouts[newid]:send("/id assigned", newid)
	    		
	    	end
	    	
	    elseif(msg.addr == "/screencoord") then 
	    	local device_id, scx, scy = unpack (msg)
	    	local winw, winh = unpack(win.dim)
	    	ipadlastx[device_id] = math.floor(scx*winw)
	    	ipadlasty[device_id] = math.floor(scy*winh)
	    elseif(msg.addr == "/selectNode") then 
	    	local device_id, indid = unpack(msg)
	    	print("selected node message: ", device_num, indid)
	    	ipadSelectNode( indid )
	    	--testoscout:send("/createNode", indid, tpd:getnodelabel(indid), tpd:getnodepubs(indid) )
	    	oscouts[device_id]:sendsend("/createNode", indid, tpd:getnodelabel(indid), tpd:getnodepubs(indid) )
	    	print(" sent /createNode", tpd:getnodelabel(indid) )
	    	
	    elseif(msg.addr == "/deselectNode") then
	    	local device_num, indid = unpack(msg)
	    	print("deselect: ", indid)
	    	ipadSelectNode( indid )
	    	
	    elseif(msg.addr == "/displayNode") then
	    	local device_num, indid = unpack(msg)
	    	print("disp: ", indid)
	    	displayNode( indid )
	    elseif(msg.addr == "/clearAll") then
	        --later I have to handle this per device
	    	selectnodes = {}
			hovernodes = {}
			displaynodes = {}
		end
	end
end


function win:draw(eye)
	
	getOSC() 
     
    local w, h = unpack(self.dim)
    local h2 = h *0.5 -- half height
    
    cam.eye_sep = -eyesep.value
	
	cam:step()
	cam:enter((eye == "left") and 1 or 0)
	
	if(boolrotate) then
	 	gl.PushMatrix()
	 	gl.Rotate(now()*10, 0, 1, 0)
	end
	
	
	gl.Translate(-2.5, 0, 0)
	
	gl.LineWidth(2.0)
	drawAxes(win.dim)
	
	for d=1, NUM_DEVICES do
		drawMyCursor(win.dim, d) -- device number
    end

	
	drawPlane()
	 
	if(boolmousepress) then
	    mouseSelectNode() 
	    boolmousepress = false
	else
	    hoverNode(1) 
		
	end

	
	if(draw3d) then 
		drawGraph3D()
	else
		drawGraph2D()
	end
	
	
	--draw all labels
	if(boollabelall) then
		drawAllLabels()
	end
	
	-----------------end draw graph-------------------------
	-----------------begin draw highlights------------------
		----[[
		--handle this in a way better
		for k,v in pairs(displaynodes) do  
			local np = tpd:graphnodepos(v)
			--pubsText:draw_3d(win.dim, {np[1], np[2], np[3]}, tpd:getnodepubs(v))
			pubsText:draw_3d_multi(win.dim, {np[1], np[2], np[3]}, tpd:getnodepubs(v))
		end
		--]]
		
		for k,v in pairs(selectnodes) do
			--print(k, v)
			local np = tpd:graphnodepos(v)
			gl.PushMatrix()
			gl.Translate(np)
			gl.Color(highcol[1])
			
			drawBillboardCircle(0.2)
			
			gl.PopMatrix()
			
		end
		
		for k,v in pairs(hovernodes) do
			--print(k, v)
			--adjust transparency and removel from list
			local starttime = v[2]
			
			local timeelapsed = now() - starttime
			
			if(timeelapsed > 2) then 
				table.remove( hovernodes, k)
			else
			    
				local np = tpd:graphnodepos(v[1])
				gl.PushMatrix()
				gl.Translate(np)
				local transcol = highcol[2]
				transcol[4] = 2 - timeelapsed
				gl.Color(transcol)
				
				drawBillboardCircle(0.2)
				
				gl.PopMatrix()
			end	
		end

	
	if(st < MAXSTEP and TEMP > 0.0001) then 
		tpd:stepLayout(layout3d, TEMP)
	 	TEMP = TEMP * 0.98
	 	st = st+1 	
	end

    if(boolrotate) then
	 gl.PopMatrix()
	end
	
    cam:leave()
    
    gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    
    sketch.enter_ortho(self.dim)
    guilabels:draw({35, 30, 0}, "a")
	guilabels:draw({35, 50, 0}, "ab")
	guilabels:draw({35, 70, 0}, "abc")
	
	guilabels:draw({10, 100, 0}, "abcd")
	guilabels:draw({10, 150, 0}, "abcdi")
	
	
	sketch.leave_ortho()
	
	gui:draw()
	
	
	
end

-------------------------------------------------

-------------------------------------------------

function win:resize()
    cam:resize(win.dim)
	gui:resize(win.dim)
end
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
		    saveGraph()
		elseif(key == 108 or key == 76) then --L
		    loadGraph()
		    st = MAXSTEP -- TO STOP GRAPH LAYOUT CALC
		elseif(key == 121 or key == 89) then --Y
			layout3d = not layout3d
			redrawgraph()
		elseif(key == 116 or key == 84) then --T
			draw3d = not draw3d
		elseif(key == 103 or key == 71) then --G
			mouseinteractmode = 1
		elseif(key == 102 or key == 70) then --F
			mouseinteractmode = 2
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
	    	addNodeToPlane(lastselectnode)
	    end
	    
	elseif(event == "drag") then
	    local xdiff = (lastx - x) * 0.01
	    local ydiff = (lasty - y) * 0.01
	    if(mouseinteractmode == 2) then
	      	tpd:movePlane(activePlane, xdiff)
	    elseif(mouseinteractmode == 1) then
			if(lastselectnode > -1.0 ) then 
				
				local currentpos = tpd:graphnodepos(lastselectnode)
				currentpos[3] = currentpos[3] + xdiff
				tpd:graphnodepos(lastselectnode, currentpos)	
				nodedragged = true
			end
		elseif(mouseinteractmode == 0) then
			if(lastselectnode > -1.0 ) then 
				local amnt = {-xdiff, ydiff, 0.0}
		        tpd:moveGraph(lastselectnode, amnt)
			end
		end
	end
	
	lastx, lasty = x, y
end



-------------------------------------------------

function win:modifiers()
	gui:modifiers(self)
end



