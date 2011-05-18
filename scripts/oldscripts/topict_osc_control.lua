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

local task_1 = {}
task_1[1] = {21, 42, 9, 34}
task_1[2] = {58, 59, 68, 49}
task_1[3] = {70, 103, 56, 81}

--two is same as one, but for simplicity we repeat it
local task_2 = {}
task_2[1] = {21, 42, 9, 34}
task_2[2] = {58, 59, 68, 49}
task_2[3] = {70, 103, 56, 81}


local task_3 = {}
task_3[1] = { {9, 14}, {47,34}, {39, 93}, {82,54}}
task_3[2] = { {49,67}, {67,43}, {3, 84}, {58,6}}
task_3[3] = { {16,124}, {54,56}, {81, 13}, {61,70}}

local task_4 = {}
task_4[1] = { {6,18}, {39,93}, {46, 39}, {6,23}}
task_4[2] = { {59, 82}, {49, 105}, {84, 91}, {98, 11}}
task_4[3] = { {62, 41}, {39, 3}, {36, 100}, {56, 79}}


local task_5 = {}
task_5[1] = { {8,80}, {61,83}, {38, 13}, {47,16}}
task_5[2] = { {59, 10}, {9, 68}, {49, 35}, {58, 44}}
task_5[3] = { {3, 72}, {55, 70}, {18, 42}, {130, 47}}

local tasks = {task_1, task_2, task_3, task_4, task_5}


local crr_task = 1

local crr_data
local crr_condition
local crr_ind

local MAXQ = 60
local question = 56
local participant = 1

local boolviewing = false
local boolunsaved = true

local boolwarning = false
local warningtext = ""


local starttime = os.time()
local elapsed = os.time()

local results = {} -- 3 datasets x 5 tasks x 4 conditions = 60 questions
--init the results
for r=1, MAXQ do 
    results[r] = {}
    results[r]["ans"] = -1
	results[r]["time"] = 0
	
end
	
local cameyes = {}

local conditions = {}
conditions[1] = {"2D", "3D", "2.5D", "2.5DH"}
conditions[2] = {"2D", "3D", "2.5DH", "2.5D"}
conditions[3] = {"3D", "2D", "2.5DH", "2.5D"}
conditions[4] = {"3D", "2D", "2.5D", "2.5DH"}

conditions[5] = {"2.5D", "2.5DH", "2D", "3D"}
conditions[6] = {"2.5D", "2.5DH", "3D", "2D"}
conditions[7] = {"2.5DH", "2.5D", "3D", "2D"}
conditions[8] = {"2.5DH", "2.5D", "2D", "3D"}

conditions[9] = {"2D", "2.5DH", "2.5D", "3D"}
conditions[10] = {"2D", "2.5D", "2.5DH", "3D"}
conditions[11] = {"3D", "2.5D", "2.5DH", "2D"}
conditions[12] = {"3D", "2.5DH", "2.5D", "2D"}



local questions = {}
local answers = {}
local labels = {}

local 
function generatequest()
	crr_task = math.floor((question-1) / 12 ) + 1
	crr_ind = ((question-1) % 4) +1
    crr_condition = conditions[participant][crr_ind]
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
------------------------------------------------
generatequest()

function win:draw()
    --print(boolviewing)
	gl.LineWidth(1.0)
    gl.Color(1.0, 0.0, 0.0)
    
    if(question < MAXQ+1 ) then
		sketch.enter_ortho(self.dim)
		
		if(boolwarning) then 
		    questionlabels.color = {0.8, 0.2, 0.2}
			questionlabels:draw({self.dim[1]*0.5, 300, 0}, warningtext)
		end
		
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
		
		--guilabels:draw({950, 460, 0}, "Rotate")
		
		local condstr = "Current Condition: " .. crr_condition
		
		
		guilabels:draw({850, 160, 0}, condstr)
		
		sketch.leave_ortho()
		
		gui:draw()
	
	else
	    if(boolunsaved) then 
	    	saveresultsfile()
	    	boolunsaved = false
	    end
	    
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
		elseif (key == 115) then --save emergency
			saveresultsfile()
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
cameyes[2] = {0.0, 2.0, 5.0}
cameyes[8] = {0.0, 2.7, 5.0}
cameyes[14] = {0.0, 2.0, 5.0}
cameyes[20] = {0.0, 2.7, 5.0}
cameyes[28] = {0.0, 2.2, 5.0}
cameyes[32] = {0.0, 2.7, 5.0}
cameyes[35] = {0.0, 2.7, 5.0}
cameyes[37] = {0.0, 3.0, 5.0}
cameyes[39] = {0.0, 3.0, 5.0}
cameyes[40] = {0.0, 3.1, 5.0}
cameyes[43] = {0.0, 2.7, 5.0}
cameyes[44] = {1.0, 3.0, 5.0}
cameyes[44] = {0.0, 1.8, 5.0}
cameyes[48] = {0.0, 2.65, 5.0}
cameyes[49] = {0.0, 3.0, 5.0}
cameyes[50] = {0.0, 2.0, 5.0}
cameyes[51] = {0.0, 3.5, 5.5}
cameyes[52] = {0.0, 2.0, 5.0}
cameyes[56] = {-1.5, 2.0, 5.0}
cameyes[56] = {0.0, 2.0, 5.0}
cameyes[59] = {0.0, 3.0, 5.0}
cameyes[60] = {0.0, 2.2, 5.0}

questions[1] = [[Is 'SC' friends with highligted node (yellow) 'MH'?]]
questions[2] = [[Is 'JA' friends with highligted (yellow) node 'SC'?]]
questions[3] = [[Is 'MH' friends with highligted (yellow) node 'JS'?]]
questions[4] = [[Is 'SL' friends with highligted (yellow) node 'RT'?]]
questions[5] = [[Is 'MC' friends with highligted (yellow) node 'SG'?]]
questions[6] = [[Is 'RR' friends with highligted (yellow) node 'SF'?]]
questions[7] = [[Is 'JD' friends with highligted (yellow) node 'BB'?]]
questions[8] = [[Is 'JL' friends with highligted (yellow) node 'RR'?]]
questions[9] = [[Is 'JA' friends with highligted (yellow) node 'SG'?]]
questions[10] = [[Is 'NL' friends with highligted (yellow) node 'CO'?]]
questions[11] = [[Is 'MH' friends with highligted (yellow) node 'PP'?]]
questions[12] = [[Is 'EH' friends with highligted (yellow) node 'BB'?]]

questions[13] = [[How many friends does 'MH' has?]]
questions[14] = [[How many friends does 'SC' has?]]
questions[15] = [[How many friends does 'JS' has?]]
questions[16] = [[How many friends does 'RT' has?]]
questions[17] = [[How many friends does 'SG' has?]]
questions[18] = [[How many friends does 'SF' has?]]
questions[19] = [[How many friends does 'BB' has?]]
questions[20] = [[How many friends does 'RR' has?]]
questions[21] = [[How many friends does 'SG' has?]]
questions[22] = [[How many friends does 'CO' has?]]
questions[23] = [[How many friends does 'PP' has?]]
questions[24] = [[How many friends does 'BB' has?]]

questions[25] = [[Is 'MH' friends with both 'MS' and 'JS'?]]
questions[26] = [[Is 'BD' friends with both 'RT' and 'UD'?]]
questions[27] = [[Is 'NS' friends with both 'FH' and 'SM'?]]
questions[28] = [[Is 'RT' friends with both 'JB' and 'RT'?]]
questions[29] = [[Is 'SC' friends with both 'RR' and 'BS'?]]
questions[30] = [[Is 'RA' friends with both 'PH' and 'BS'?]]
questions[31] = [[Is 'JG' friends with both 'CP' and 'JD'?]]
questions[32] = [[Is 'SC' friends with both 'SG' and 'JO'?]]
questions[33] = [[Is 'PL' friends with both 'JK' and 'MB'?]]
questions[34] = [[Is 'JM' friends with both 'PP' and 'PH'?]]
questions[35] = [[Is 'SC' friends with both 'JM' and 'BB'?]]
questions[36] = [[Is 'PP' friends with both 'RR' and 'SG'?]]

questions[37] = [[Is 'JF' friends with 'MP' but not  with 'JD'? ]]
questions[38] = [[Is 'NS' friends with 'FH' but not  with 'SM'? ]] 
questions[39] = [[Is 'SH' friends with 'TR' but not  with 'SM'? ]]
questions[40] = [[Is 'AV' friends with 'MX' but not  with 'JD'? ]] 
questions[41] = [[Is 'PL' friends with 'MH' but not  with 'SF'? ]]
questions[42] = [[Is 'RG' friends with 'EH' but not  with 'RR'? ]]
questions[43] = [[Is 'CW' friends with 'CA' but not  with 'CP'? ]]
questions[44] = [[Is 'EH' friends with 'DM' but not  with 'JM'? ]]
questions[45] = [[Is 'EH' friends with 'MJ' but not  with 'RG'? ]]
questions[46] = [[Is 'AM' friends with 'MD' but not  with 'JG'? ]]
questions[47] = [[Is 'DH' friends with 'MW' but not  with 'CP'? ]]
questions[48] = [[Is 'PT' friends with 'BC' but not  with 'PP'? ]]

questions[49] = [[Friends of 'JF' and 'CP' are highlighted.]]
questions[50] = [[Friends of 'JL' and 'GD' are highlighted.]]
questions[51] = [[Friends of 'SS' and 'AV' are highlighted.]]
questions[52] = [[Friends of 'MH' and 'UD' are highlighted.]]
questions[53] = [[Friends of 'SF' and 'JD' are highlighted.]]
questions[54] = [[Friends of 'AA' and 'BB' are highlighted.]]
questions[55] = [[Friends of 'RR' and 'MC' are highlighted.]]
questions[56] = [[Friends of 'PL' and 'SG' are highlighted.]]
questions[57] = [[Friends of 'JG' and 'SC' are highlighted.]]
questions[58] = [[Friends of 'SG' and 'PL' are highlighted.]]
questions[59] = [[Friends of 'JR' and 'MH' are highlighted.]]
questions[60] = [[Friends of 'AR' and 'DW' are highlighted.]]


for a=1, 60 do 
	answers[a] = {"Yes", "No", "Not Sure"}
end

answers[13] = {"5", "6", "7"}
answers[14] = {"5", "6", "7"}
answers[15]= {"11", "12", "14"}
answers[16] = {"14", "15", "16"}
answers[17] = {"9", "10", "11"}
answers[18] = {"8", "9", "10"}
answers[19] = {"11", "12", "14"}
answers[20] = {"10", "11", "12"}
answers[21] = {"9", "10", "11"}
answers[22] = {"8", "9", "10"}
answers[23] = {"10", "11", "12"}
answers[24] = {"13", "14", "15"}

answers[49] = {"KS", "SM", "None"}
answers[50] = {"JB", "BD", "None"}
answers[51] = {"TS", "MP", "None"}
answers[52] = {"SW", "CP", "None"}
answers[53] = {"SG", "JD", "None"}
answers[54] = {"JD", "CD", "None"}
answers[55] = {"AR", "NG", "None"}
answers[56] = {"JG", "SK", "None"}
answers[57] = {"MC", "SK", "None"}
answers[58] = {"BS", "SK", "None"}
answers[59] = {"SG", "RG", "None"}
answers[60] = {"BB", "JG", "None"}

