local gl = require("opengl")
local GL = gl
local glu = require("opengl.glu")
-------------------------------------------------


local sketch = require("opengl.sketch")
local osc = require("osc")

local Texture = require("opengl.Texture")
local Image = require("Image")
-------------------------------------------------

local context = "controls"
win = Window{
	title = context, 
	origin = {0, 0}, 
	dim = {600, 480},
	mousemove = true,
}

win.sync = true

local image = Image(LuaAV.findfile("instruct.png"))
local tex = Texture(context)
tex:fromarray(image:array())

local send_address = '192.168.0.15'	-- this is photon linux box in the allosphere
--local send_address = '127.0.0.1'
local send_port = 16448
local receive_port = 16447

local oscout = osc.Send(send_address, send_port) 
local oscin  = osc.Recv(receive_port)   

-------------------------------------------------
local Gui = require("gui.Context")
local Rect = require("gui.Rect")
local Slider = require("gui.Slider")
local Button = require("gui.Button")
local GuiLabel = require("gui.Label")

local Label = require("Label")
-------------------------------------------------

local guilabels = Label{
    fontfile = LuaAV.findfile("VeraMoBd.ttf") ,
	ctx = context,
	alignment = "LEFT",
	size = 14,
	color = {1.0, 0.7, 0.2}
}

local questionlabels = Label{
	ctx = context,
	
	--fontfile = LuaAV.findfile("Universe55.ttf"),
	--alignment = "LEFT",
	size = 22,
	bg = true
}
---------------------------------------------------
------------------------tasks----------------------

--task1: is "aa" friends with highligted (yellow) node "bb"? 
--task2: how many friends do "bb" has?
--task3: is "cc" friends with both "aa" and "bb"?
--task4: is "cc" friends with with "aa" but not  with "bb"? 
--task5: friends of "aa" and "bb" are highlighted. identify a person outside of these groups but 
--       who has friends in both communities? 

local task_1 = {3, 5}
local task_2 = {3, 5}
local task_3 = {{8, 15}}
local task_4 = {{23, 20}}
local task_5 = {{8, 2}}

local tasks = {task_1, task_2, task_3, task_4, task_5}


local boolbegin = false

local crr_task = 1
local crr_condition = "2D"
local crr_ind = 1

local MAXQ = 20
local question = 1


local boolviewing = false
local boolunsaved = true

local boolwarning = false
local warningtext = ""


local conditions = {"2D", "3D", "2.5D", "2.5DH"}
local questions = {}
local answers = {}

local 
function generatequest()
	crr_task = math.floor((question-1) / 4 ) + 1
	crr_ind = ((question-1) % 4) +1
    crr_condition = conditions[crr_ind]
  
    print("q: ", question, " ct", crr_task, "condition", crr_condition, "ind", crr_ind)
    
end

		
local
function generateOSC() 
    if(crr_task == 1 or crr_task == 2) then 
        local node = tasks[crr_task][1]
        print(node)
		oscout:send("/quest1", crr_task, crr_condition, node)
	else
	    local nodes =  tasks[crr_task][1]
	    print(nodes[1], nodes[2])
	    oscout:send("/quest2", crr_task, crr_condition, nodes[1], nodes[2])
	end
	
end


-- create the gui
local gui = Gui{
	ctx = context,
	dim = win.dim,
}

-- create some widgets
local btn_1 = Button{
	rect = Rect(350, 500, 15, 15),
	value = false,
}

local btn_2 = Button{
	rect = Rect(350, 530, 15, 15),
	value = false,
}

local btn_3 = Button{
	rect = Rect(350, 560, 15, 15),
	value = false,
}

local next_btn = Button{
	rect = Rect(500, 420, 70, 15),
	--rect = Rect(800, 680, 70, 15),
	toggles = false,
	value = false,
}

local view_btn = Button{
	rect = Rect(350, 420, 70, 15),
	toggles = false,
	value = false,
}


-- add them to the gui
gui:add_view(btn_2)
gui:add_view(btn_1)
gui:add_view(btn_3)
gui:add_view(next_btn)
gui:add_view(view_btn)



-- register for notifications

btn_2:register("value", function(w)
	local val = w.value 
	if val then 
		btn_3.value = false
		btn_1.value = false
		
	end
end)

btn_1:register("value", function(w)
	local val = w.value 
	if val then 
		btn_3.value = false
		btn_2.value = false
		
	end
end)

btn_3:register("value", function(w)
	local val = w.value 
	if val then 
		btn_1.value = false
		btn_2.value = false
		
	end
end)


next_btn:register("value", function(w)
	local val = w.value 
	if val then 
	    if(boolviewing and 
	    	( btn_1.value == true or  btn_2.value == true or  btn_3.value == true)) then 
			
			local ans = -1
			if(btn_1.value == true) then ans = 1
			elseif (btn_2.value == true) then ans = 2
			elseif (btn_3.value == true) then ans = 3
			end
			
			elapsed = os.difftime(os.time(), starttime)
			--print("elapsed time", elapsed)
			
			
			
		    boolwarning = false
			boolviewing = false
			question = question + 1
		
			generatequest()
			oscout:send("/blockview", 1)
						
			btn_1.value = false
			btn_2.value = false
			btn_3.value = false
			
			
		else

			print("first view and answer the question")
			boolwarning = true
			warningtext = "first view and answer the question"
			
		end
	end
end)

view_btn:register("value", function(w)
	local val = w.value 
	if val then 
	
	    if(not boolviewing) then 
	    
	        boolwarning = false
	        
			btn_1.value = false
			btn_2.value = false
			btn_3.value = false
			
			generateOSC()
			
			boolviewing = true
			oscout:send("/blockview", 0)
			
			
			
		else
			print("first answer the question and then press next")
			boolwarning = true
			warningtext = "first answer the question and then press next"
		end
	end
end)

-------------------------------------------------

generatequest()

function win:draw()
    --print(boolviewing)
	gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    
    if(question < MAXQ+1 ) then
		if(boolbegin) then 
			sketch.enter_ortho(self.dim)
		
			if(boolwarning) then 
				questionlabels.color = {0.8, 0.2, 0.2}
				questionlabels:draw({self.dim[1]*0.5, 200, 0}, warningtext)
			end
			
			local tsktext = "TASK: " .. crr_task
			questionlabels.color = {0.8, 0.2, 0.2}
		    questionlabels:draw({self.dim[1]*0.5, 300, 0}, tsktext)
			
			questionlabels.color = {1.0, 1.0, 1.0}
			questionlabels:draw({self.dim[1]*0.5, 350, 0}, questions[question])
			
			if(crr_task == 5) then 
				questionlabels:draw({self.dim[1]*0.5, 380, 0}, "Identify a person outside of these groups but who has friends in both communities.")
			end
			
			guilabels:draw({370, 520, 0}, answers[question][1])
			guilabels:draw({370, 550, 0}, answers[question][2])
			guilabels:draw({370, 580, 0}, answers[question][3])
			
			
			guilabels:draw({500, 460, 0}, "Next")
			guilabels:draw({350, 460, 0}, "View")
			
			
			
			local condstr = "Current Condition: " .. crr_condition
			guilabels:draw({850, 160, 0}, condstr)
		
			sketch.leave_ortho()
		else
		   
		    gl.Color(1, 1, 1, 1)
			gl.Scale(1.5, 1.0, 1.0)
			tex:bind()
			gl.Begin(GL.QUADS)
				sketch.quad()
			gl.End()
			tex:unbind()
		end
		
		
		
		
		
		
		if(boolbegin) then 
			gui:draw()
		end
	else
	    
		sketch.enter_ortho(self.dim)
			guilabels:draw({400, 380, 0}, "Thank you, you completed the study !!! :)")
		sketch.leave_ortho()
		
	end
	
end


-------------------------------------------------

function win:key(event, key)
     --print(key)
	 if(event == "down") then
		if(key == 27) then
		    self.fullscreen = not self.fullscreen
		    --oscout:send("/fullscr", 1)
		    print("/fullscr")
		elseif (key == 98) then --B
			boolbegin = not boolbegin
		end
	end
	gui:key(event, key)
	
end

-------------------------------------------------

function win:mouse(event, btn, x, y, nclk)
	gui:mouse(event, btn, x, y, nclk)
	lastx, lasty = x, y
end

-------------------------------------------------

function win:resize()
	gui:resize(self.dim)
end

-------------------------------------------------

function win:modifiers()
	gui:modifiers(self)
end

-------------------------------------------------

for a=1, MAXQ do 
	answers[a] = {"Yes", "No", "Not Sure"}
end

answers[5] = {"7", "10", "13"}
answers[6] = {"7", "10", "13"}
answers[7] = {"7", "10", "13"}
answers[8] = {"7", "10", "13"}


answers[17] = {"TT", "KD", "RS"}
answers[18] = {"TT", "KD", "RS"}
answers[19] = {"TT", "KD", "RS"}
answers[20] = {"TT", "KD", "RS"}



questions[1] = [[Is 'RK' friends with highligted node (yellow) 'LS'?]]
questions[2] = [[Is 'SK' friends with highligted (yellow) node 'LS'?]]
questions[3] = [[Is 'WC' friends with highligted (yellow) node 'LS'?]]
questions[4] = [[Is 'MH' friends with highligted (yellow) node 'LS'?]]
questions[5] = [[How many friends does 'LS' has?]]
questions[6] = [[How many friends does 'LS' has?]]
questions[7] = [[How many friends does 'LS' has?]]
questions[8] = [[How many friends does 'LS' has?]]
questions[9] = [[Is 'AB' friends with both 'PW' and 'EJ'?]]
questions[10] = [[Is 'JT' friends with both 'PW' and 'EJ'?]]
questions[11] = [[Is 'BH' friends with both 'PW' and 'EJ'?]]
questions[12] = [[Is 'KP' friends with both 'PW' and 'EJ'?]]
questions[13] = [[Is 'JT' friends with with 'LM' but not  with 'LN'?]]
questions[14] = [[Is 'RZ' friends with with 'LM' but not  with 'LN'?]]
questions[15] = [[Is 'DH' friends with with 'LN' but not  with 'LM'?]]
questions[16] = [[Is 'RD' friends with with 'LN' but not  with 'LM'?]]
questions[17] = [[Friends of 'PW' and 'AD' are highlighted. ]]
questions[18] = [[Friends of 'PW' and 'AD' are highlighted. ]]
questions[19] = [[Friends of 'PW' and 'AD' are highlighted. ]]
questions[20] = [[Friends of 'PW' and 'AD' are highlighted. ]]
