local assert, pairs, tostring, type = assert, pairs, tostring, type
local ipairs = ipairs
local setmetatable = setmetatable
local getfenv = getfenv

local print = print

local math = require 'math'
local table = require 'table'
local string = require 'string'

require 'opengl'
require 'glv'

local gl = gl
local GL = gl
local glv = glv

local Rect = glv.Rect
local View = glv.View
local Button = glv.Button
local Buttons = glv.Buttons
local Slider = glv.Slider

local min = math.min
local max = math.max

local C = {}
local M

local
function setconstructor(m)
	M = m
	setmetatable(M, C)
end

module('tnet_gui', setconstructor)
----------------------------------------------------------
function C:__call(init)
	init.disable = (init.disable or 0) + glv.Controllable
	
	
	local m = View(init)
	for k, v in pairs(M) do
		if(type(v) == "function") then
			m[k] = v
		end
	end
	
	

	-- add slider bank1
	m.slides1 = {}	
	for i=1, 2 do
		local s = Slider{
			rect = Rect((230 +15*i), 10, 15, 95),
			
			action = {},
			
			-- propagate UI events to dst
			Notified = function(self, event)
				if(self.action[event]) then
					self.action[event](self)
				end
			end,
		}
		m.slides1[i] = s
		m:add(s)
	end
	
	m.slides1[1].value = 0.0
	m.slides1[2].value = 1.0
	
	m.slides2 = {}	
	local s = Slider{
			rect = Rect(115, 10, 15, 95),
			action = {},
			
			-- propagate UI events to dst
			Notified = function(self, event)
				if(self.action[event]) then
					self.action[event](self)
				end
			end,
		}
		
	m.slides2[1] = s
	m:add(s)
	m.slides2[1].value = 0.5
	
	
	
	----[[
	m.btnsV = {}
	for i=1, 5 do
		local be = Button{
			rect = Rect(10, (20*(i-1) + 10), 15, 15),
			--value = true,
			
			action = {},
			
			-- propagate UI events to dst
			Notified = function(self, event)
				if(self.action[event]) then
					self.action[event](self)
				end
			end,
		}
		m.btnsV[i] = be
		m:add(be)
	end
	
	m.btnsV[3].value = true
    --]]
 
	return m
end

function M:resize(wn)
    print("gui resize")
	print(wn.ww)
--	local hh = self.hh

end

