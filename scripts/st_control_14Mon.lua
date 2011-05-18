local gl = require("opengl")
local GL = gl
local glu = require("opengl.glu")
-------------------------------------------------


local sketch = require("opengl.sketch")
local osc = require("osc")
-------------------------------------------------

local context = "controls"
win = Window{
	title = context, 
	origin = {0, 0}, 
	dim = {600, 480},
	mousemove = true,
}

win.sync = true

win.clearcolor = {0.2, 0.2, 0.2}

--local send_address = '192.168.0.15'	-- this is photon linux box in the allosphere
local send_address = '127.0.0.1'
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
	ctx = context,
	alignment = "LEFT",
	size = 18,
	color = {1.0, 0.7, 0.2}
}

local questionlabels = Label{
	ctx = context,
	--fontfile = LuaAV.findfile("Universe55.ttf"),
	--alignment = "LEFT",
	size = 22,
	--bg = true
}
---------------------------------------------------
------------------------tasks----------------------

--task1: is "aa" friends with highligted (yellow) node "bb"? 
--task2: how many friends do "bb" has?
--task3: is "cc" friends with both "aa" and "bb"?
--task4: is "cc" friends with with "aa" but not  with "bb"? 
--task5: friends of "aa" and "bb" are highlighted. identify a person outside of these groups but 
--       who has friends in both communities? 

local task_1 = {}
task_1[1] = {69, 55, 9, 34}
task_1[2] = {58, 87, 68, 49}
task_1[3] = {80, 103, 56, 81}

--two is same as one, but for simplicity we repeat it
local task_2 = {}
task_2[1] = {69, 55, 9, 34}
task_2[2] = {45, 21, 68, 49}
task_2[3] = {80, 103, 56, 81}


local task_3 = {}
task_3[1] = { {9, 14}, {47,34}, {39, 93}, {82,54}}
task_3[2] = { {49,67}, {67,43}, {3, 84}, {58,6}}
task_3[3] = { {16,124}, {54,56}, {81, 13}, {61,70}}

local task_4 = {}
task_4[1] = { {6,18}, {39,93}, {4, 58}, {69,82}}
task_4[2] = { {45, 10}, {49, 105}, {84, 91}, {111, 112}}
task_4[3] = { {1, 113}, {39, 3}, {36, 100}, {56, 145}}


local task_5 = {}
task_5[1] = { {8,80}, {61,80}, {38, 13}, {47,16}}
task_5[2] = { {59, 10}, {9, 68}, {68, 87}, {58, 44}}
task_5[3] = { {3, 72}, {81, 18}, {18, 42}, {130, 47}}

local tasks = {task_1, task_2, task_3, task_4, task_5}


local crr_task = 1

local crr_data
local crr_condition
local crr_ind

local MAXQ = 60
local question = 33
local participant = 16

local boolviewing = false
local boolunsaved = true

local boolwarning = false
local warningtext = ""

local boolbreak = false

local starttime = os.time()
local elapsed = os.time()

local results = {} -- 3 datasets x 5 tasks x 4 conditions = 60 questions
--init the results
for r=1, MAXQ do 
    results[r] = {}
    results[r]["ans"] = -1
	results[r]["time"] = 0
	
end

-------------------------------------------------
local
function saveresultsfile()
    local path = script.path .. "/study"
    --print("path", path)
    local fileN = "participant".. participant .."_res.txt"
    --print(fileN)
    local fname = LuaAV.findfileinpath(path, fileN, true)
	--print("filename", fname)

	local f = io.open(fname, "w")
	f:write("participant: ", participant, " results file \n")
	f:write(os.date("saved at: %c"), "\n")
	f:write("question \t answer \t time \n")
	for qs=1, MAXQ do
		f:write(qs, "\t", results[qs]["ans"], "\t" , results[qs]["time"], "\n")
		--print(qs, results[qs]["ans"])
	end
	f:close()
end
-------------------------------------------------


local cameyes = {}

local conditions = {}
conditions[1] = {"2D", "3D", "2.5D", "2.5DH"}
conditions[2] = {"3D", "2D", "2.5DH", "2.5D"}
conditions[3] = {"2D", "3D", "2.5DH", "2.5D"}
conditions[4] = {"3D", "2D", "2.5D", "2.5DH"}

conditions[5] = {"2.5D", "2.5DH", "2D", "3D"}
conditions[6] = {"2.5D", "2.5DH", "3D", "2D"}
conditions[7] = {"2.5DH", "2.5D", "3D", "2D"}
conditions[8] = {"2.5DH", "2.5D", "2D", "3D"}

conditions[9] =  {"2D", "2.5DH", "2.5D", "3D"}
conditions[10] = {"2D", "2.5D", "2.5DH", "3D"}
conditions[11] = {"3D", "2.5D", "2.5DH", "2D"}
conditions[12] = {"3D", "2.5DH", "2.5D", "2D"}

conditions[13] = {"2.5DH", "2D", "3D", "2.5D"}
conditions[14] = {"2.5DH", "3D", "2D", "2.5D"}
conditions[15] = {"2.5D", "2D", "3D", "2.5DH"}
conditions[16] = {"2.5D", "3D", "2D", "2.5DH"}


local questions = {}
local answers = {}
local anskeys = {}
local labels = {}

local 
function generatequest()
	crr_task = math.floor((question-1) / 12 ) + 1
	crr_ind = ((question-1) % 4) +1
    --crr_condition = conditions[participant][crr_ind]
    crr_condition = "3D"
    crr_data = math.floor((question-1) /4) + 1
    crr_data = crr_data - (3*(crr_task-1)) 
    
    print("q: ", question, " ct", crr_task, "data", crr_data, "condition", crr_condition, "ind", crr_ind)
    
end

		
local
function generateOSC() 
    if(crr_task == 1 or crr_task == 2) then 
        local node = tasks[crr_task][crr_data][crr_ind]
        print(node)
		oscout:send("/quest1", crr_data, crr_task, crr_condition, node)
	else
	    local nodes =  tasks[crr_task][crr_data][crr_ind]
	    print(nodes[1], nodes[2])
	    oscout:send("/quest2", crr_data, crr_task, crr_condition, nodes[1], nodes[2])
	end
	
	local cay = cameyes[question]
	oscout:send("/cameye", cay[1], cay[2], cay[3])
	
	if(crr_condition == "2D") then 
		oscout:send("/setstereo", false)
	else
		oscout:send("/setstereo", true)
	end
	
end


-- create the gui
local gui = Gui{
	ctx = context,
	dim = win.dim,
}

-- create some widgets
local btn_1 = Button{
	rect = Rect(350, 500, 25, 25),
	value = false,
}

local btn_2 = Button{
	rect = Rect(350, 540, 25, 25),
	value = false,
}

local btn_3 = Button{
	rect = Rect(350, 580, 25, 25),
	value = false,
}

local next_btn = Button{
	rect = Rect(500, 410, 70, 25),
	--rect = Rect(800, 680, 70, 15),
	toggles = false,
	value = false,
}

local view_btn = Button{
	rect = Rect(350, 410, 70, 25),
	toggles = false,
	value = false,
}

local rot_btn = Button{
	rect = Rect(950, 420, 70, 15),
	toggles = true,
	value = false,
}

-- add them to the gui
gui:add_view(btn_2)
gui:add_view(btn_1)
gui:add_view(btn_3)
gui:add_view(next_btn)
gui:add_view(view_btn)
--gui:add_view(rot_btn)


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
			
			results[question]["time"] = elapsed
			results[question]["ans"] = ans
			
			saveresultsfile()
			
		    boolwarning = false
			boolviewing = false
			question = question + 1
		
			generatequest()
			oscout:send("/blockview", 1)
			
			if(question == 13 or question == 25 or question == 37 or question == 49) then
				boolbreak = true
			end
			
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
			
			starttime = os.time()
			
		else
			print("first answer the question and then press next")
			boolwarning = true
			warningtext = "first answer the question and then press next"
		end
	end
end)


rot_btn:register("value", function(w)
	local val = w.value 
	
	if(crr_condition ~= "2D") then
		if val then oscout:send("/rotate", true)
		else oscout:send("/rotate", false) end
	end
end)



------------------------------------------------
generatequest()

function win:draw()
    --print(boolviewing)
	gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    
    if(question < MAXQ+1 ) then
		sketch.enter_ortho(self.dim)
		
		if(not boolbreak) then 
			
			if(boolwarning) then 
				questionlabels.color = {0.8, 0.2, 0.2}
				questionlabels:draw({self.dim[1]*0.5, 300, 0}, warningtext)
			end
			
			questionlabels.color = {1.0, 1.0, 1.0}
			questionlabels:draw({self.dim[1]*0.5, 350, 0}, questions[question])
			
			if(crr_task == 5) then 
				questionlabels:draw({self.dim[1]*0.5, 380, 0}, "Identify a person outside of these groups but who has friends in both communities.")
			end
			
			guilabels:draw({380, 530, 0}, answers[question][1])
			guilabels:draw({380, 570, 0}, answers[question][2])
			guilabels:draw({380, 610, 0}, answers[question][3])
			
			
			guilabels:draw({500, 465, 0}, "Next")
			guilabels:draw({350, 465, 0}, "View")
			
			--guilabels:draw({950, 460, 0}, "Rotate")
			
			local condstr = "Current Condition: " .. crr_condition
			
			
			guilabels:draw({850, 160, 0}, condstr)
		
		else
			questionlabels.color = {0.8, 0.2, 0.2}
			questionlabels:draw({self.dim[1]*0.5, 380, 0}, "Do Training for the Next Task !")
		end
		
		sketch.leave_ortho()
		
		if(not boolbreak) then
			gui:draw()
		end
	
	else
	    if(boolunsaved) then 
	    	saveresultsfile()
	    	boolunsaved = false
	    end
	    
		sketch.enter_ortho(self.dim)
			guilabels:draw({self.dim[1]*0.5, 380, 0}, "Thank you, you completed the study !!! :)")
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
		elseif (key == 115) then --S save emergency
			saveresultsfile()
		elseif (key == 98) then --B
			boolbreak = false
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

for c=1, 60 do 
	cameyes[c] = {0.0, 2.5, 5.0}
end



--special cases
cameyes[1] = {0.28, 2.78, 5.0}
cameyes[4] = {-0.21, 2.0, 5.0}
cameyes[8] = {-1.0, 2.78, 5.0}
cameyes[9] = {-1.6, 2.15, 5.0}
cameyes[12] = {-0.21, 1.73, 5.0}

cameyes[13] = {0.0, 2.64, 5.0}
cameyes[16] = {-0.21, 2.0, 5.0}
cameyes[17] = {-0.7, 2.85, 5.0}
cameyes[20] = {-1.47, 2.8, 5.0}
cameyes[21] = {-1.54, 2.15, 5.0}
cameyes[24] = {0.14, 1.8, 5.0}

cameyes[28] = {-0.35, 2.2, 5.0}
cameyes[32] = {-1.6, 2.5, 5.0}
cameyes[36] = {0.0, 2.8, 5.0}

cameyes[37] = {0.7, 2.85, 5.0}
cameyes[41] = {-1.4, 2.85, 5.0}
cameyes[44] = {-1.4, 2.9, 5.0}
cameyes[48] = {-0.56, 2.85, 5.0}

cameyes[49] = {-0.77, 2.78, 5.0}
cameyes[52] = {-1.0, 2.2, 5.0}
cameyes[53] = {-1.4, 2.64, 5.0}
cameyes[56] = {0.0, 2.15, 5.0}
cameyes[57] = {-1.5, 2.65, 5.0}
cameyes[60] = {-0.84, 2.0, 5.0}



questions[1] = [[Is 'CP' friends with highligted node (yellow) 'DK'?]]
questions[2] = [[Is 'GD' friends with highligted (yellow) node 'RC'?]]
questions[3] = [[Is 'RA' friends with highligted (yellow) node 'JS'?]]
questions[4] = [[Is 'GS' friends with highligted (yellow) node 'RT'?]]
questions[5] = [[Is 'GJ' friends with highligted (yellow) node 'SG'?]]
questions[6] = [[Is 'AA' friends with highligted (yellow) node 'CO'?]]
questions[7] = [[Is 'DW' friends with highligted (yellow) node 'BB'?]]
questions[8] = [[Is 'JO' friends with highligted (yellow) node 'RR'?]]
questions[9] = [[Is 'AD' friends with highligted (yellow) node 'BS'?]]
questions[10] = [[Is 'CP' friends with highligted (yellow) node 'CO'?]]
questions[11] = [[Is 'JM' friends with highligted (yellow) node 'PP'?]]
questions[12] = [[Is 'TM' friends with highligted (yellow) node 'BB'?]]

questions[13] = [[How many friends does 'DK' has?]]
questions[14] = [[How many friends does 'RC' has?]]
questions[15] = [[How many friends does 'JS' has?]]
questions[16] = [[How many friends does 'RT' has?]]
questions[17] = [[How many friends does 'PP' has?]]
questions[18] = [[How many friends does 'AW' has?]]
questions[19] = [[How many friends does 'BB' has?]]
questions[20] = [[How many friends does 'RR' has?]]
questions[21] = [[How many friends does 'BS' has?]]
questions[22] = [[How many friends does 'CO' has?]]
questions[23] = [[How many friends does 'PP' has?]]
questions[24] = [[How many friends does 'BB' has?]]

questions[25] = [[Is 'MH' friends with both 'MS' and 'JS'?]]
questions[26] = [[Is 'JB' friends with both 'RT' and 'UD'?]]
questions[27] = [[Is 'SH' friends with both 'FH' and 'SM'?]]
questions[28] = [[Is 'RS' friends with both 'JB' and 'MH'?]]
questions[29] = [[Is 'SC' friends with both 'RR' and 'BS'?]]
questions[30] = [[Is 'JO' friends with both 'PH' and 'BS'?]]
questions[31] = [[Is 'JG' friends with both 'CP' and 'JD'?]]
questions[32] = [[Is 'SC' friends with both 'SG' and 'JO'?]]
questions[33] = [[Is 'PL' friends with both 'JK' and 'MB'?]]
questions[34] = [[Is 'JO' friends with both 'PP' and 'PH'?]]
questions[35] = [[Is 'CO' friends with both 'JM' and 'BB'?]]
questions[36] = [[Is 'SC' friends with both 'RR' and 'SG'?]]

questions[37] = [[Is 'JF' friends with 'MP' but not  with 'JD'? ]]
questions[38] = [[Is 'NS' friends with 'FH' but not  with 'SM'? ]] 
questions[39] = [[Is 'CL' friends with 'AB' but not  with 'JA'? ]]
questions[40] = [[Is 'JL' friends with 'JB' but not  with 'DK'? ]] 
questions[41] = [[Is 'MA' friends with 'PP' but not  with 'JD'? ]]
questions[42] = [[Is 'JP' friends with 'EH' but not  with 'RR'? ]]
questions[43] = [[Is 'CW' friends with 'CA' but not  with 'CP'? ]]
questions[44] = [[Is 'JD' friends with 'GG' but not  with 'GC'? ]]
questions[45] = [[Is 'AW' friends with 'AS' but not  with 'JM'? ]]
questions[46] = [[Is 'AM' friends with 'MD' but not  with 'JG'? ]]
questions[47] = [[Is 'DC' friends with 'MW' but not  with 'CP'? ]]
questions[48] = [[Is 'MH' friends with 'GG' but not  with 'PP'? ]]

questions[49] = [[Friends of 'JF' and 'CP' are highlighted.]]
questions[50] = [[Friends of 'CP' and 'GD' are highlighted.]]
questions[51] = [[Friends of 'SS' and 'AV' are highlighted.]]
questions[52] = [[Friends of 'MH' and 'UD' are highlighted.]]
questions[53] = [[Friends of 'SF' and 'JD' are highlighted.]]
questions[54] = [[Friends of 'AA' and 'BB' are highlighted.]]
questions[55] = [[Friends of 'BB' and 'CO' are highlighted.]]
questions[56] = [[Friends of 'PL' and 'SG' are highlighted.]]
questions[57] = [[Friends of 'JG' and 'SC' are highlighted.]]
questions[58] = [[Friends of 'BB' and 'JR' are highlighted.]]
questions[59] = [[Friends of 'JR' and 'MH' are highlighted.]]
questions[60] = [[Friends of 'AR' and 'DW' are highlighted.]]


for a=1, 60 do 
	answers[a] = {"Yes", "No", "Not Sure"}
end

answers[13] = {"11", "12", "13"}
answers[14] = {"8", "9", "10"}
answers[15]= {"10", "11", "12"}
answers[16] = {"15", "14", "16"}
answers[17] = {"11", "12", "13"}
answers[18] = {"14", "16", "15"}
answers[19] = {"13", "12", "11"}
answers[20] = {"10", "11", "9"}
answers[21] = {"23", "24", "22"}
answers[22] = {"8", "9", "10"}
answers[23] = {"13", "11", "12"}
answers[24] = {"13", "14", "15"}

answers[49] = {"KS", "SM", "None"}
answers[50] = {"JB", "BD", "None"}
answers[51] = {"TS", "MP", "None"}
answers[52] = {"CP", "SW", "None"}
answers[53] = {"SG", "JD", "None"}
answers[54] = {"JD", "CD", "None"}
answers[55] = {"AR", "NG", "None"}
answers[56] = {"JG", "SK", "None"}
answers[57] = {"MC", "SK", "None"}
answers[58] = {"BS", "SC", "None"}
answers[59] = {"SG", "RG", "None"}
answers[60] = {"BB", "JG", "None"}


anskeys = { 1, 2, 2, 1, 1, 1, 2, 1, 2, 2, 1, 2,
			3, 2, 3, 1, 2, 3, 2, 1, 1, 2, 3, 3,
			1, 1, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1,
			2, 1, 1, 2, 2, 2, 1, 2, 1, 1, 2, 2,
			2, 3, 2, 1, 1, 1, 3, 2, 1, 2, 2, 1
		}

