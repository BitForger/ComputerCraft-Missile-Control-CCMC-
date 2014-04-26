--[[
This is the program that hooks into the methods of the Radar Station and relays
that coordinate information for use on cruise launchers
]]
os.loadAPI("/lib/log")
os.loadAPI("/lib/time")
-- Variables
local modem = peripheral.wrap("top")
local Radar = peripheral.wrap("right")
local server = 10

-- Startup function
function startup()
	-- Code here...
	term.clear()
	term.setCursorPos(1, 1)
	
end