local Gui = require("gui.Context")
local Rect = require("gui.Rect")
local Slider = require("gui.Slider")
local Button = require("gui.Button")
local GuiLabel = require("gui.Label")


mouseinteractmode = 0

function startGui(cntx, wdim)
	guilabels = Label{
	ctx = cntx,
	alignment = "LEFT",
	size = 12,
	color = {1.0, 0.3, 0.5}
	}


	-- create the gui
	gui = Gui{
		ctx = cntx,
		dim = wdim,
	}
	
	-- create some widgets
	local labels_btn = Button{
		rect = Rect(10, 12, 15, 15),
		value = false,
	}
	
	local planemode_btn = Button{
		rect = Rect(10, 30, 15, 15),
		value = false,
	}
	
	local pl_btn = Button{
		rect = Rect(10, 50, 15, 15),
		value = false,
	}
	
	
	
	eyesep = Slider{
		rect = Rect(10, 100, 100, 10),
		value = 0.1,
		range = {0, 0.2},
	}
	
	pointsz = Slider{
		rect = Rect(10, 150, 100, 10),
		value = 12,
		range = {5, 20},
	}
	
	
	-- add them to the gui
	gui:add_view(labels_btn)
	gui:add_view(planemode_btn)
	--gui:add_view(pl_btn)
	
	--gui:add_view(eyesep)
	--gui:add_view(pointsz)
	
	labels_btn:register("value", function(w)
		local val = w.value 
		--print(val)
		if val then 
			boollabelall = true
		else
			boollabelall = false
		end
	end)
	
	planemode_btn:register("value", function(w)
		local val = w.value 
		--print(val)
		if val then 
			mouseinteractmode = 2 
		else
			mouseinteractmode = 1 
		end
	end)
	
	pl_btn:register("value", function(w)
		local val = w.value 
		print(val)
		if val then 
			mouseinteractmode = 2 
			nd_btn.value = false
			mv_nd_btn.value = false
		end
	end)

end





