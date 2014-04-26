--[[
This is the main server that takes missile launcher channel numbers and links them to labels assaigned by the user
This program is made by LuaCrawler
If this breaks something I take no responisbillity
]]

-- Variables
local modem = peripheral.wrap( "top" )
local modemSide = "top"
local lModem = peripheral.wrap("back")
local lModemSide = "back"
local dir = fs.exists("var/launchers")
local fId = fs.exists("var/launchers/Ids.txt")
local fRead = fs.open("var/launchers/Ids.txt", "r")
local function startup()
    term.clear()
    term.setCursorPos(1,1)
    print("Server console log:")
    if dir == false then
        fs.makeDir("var/launchers")
        print("Main database directory created")
    end
    
    -- Check to see if correct modems are attached
    if peripheral.isPresent("top") == false and peripheral.isPresent("back") == false then
        print("You need a modem attached to the top and back of this computer")
        return false
    elseif peripheral.isPresent("top") == true and peripheral.isPresent("back") == false then
        print("Please add a modem to the back")
        return false
    else
        if peripheral.isPresent("top") == false and peripheral.isPresent("back") == true then
            print("Please add a modem to the top")
            return false
        end
    end
    if peripheral.getType("top") == "modem" and peripheral.getType("back") == "modem" then
        modem.open(10)
        lModem.open(11)
        print("Modems opened; Server ready!")
    end
end


startup()

local tIds = {}
  
while true do
  local launched = false
  local _e, _side, recChan, resChan, msg = os.pullEvent("modem_message") -- get modem messages
  msg = msg:lower() -- convert to lower case
    if _side == modemSide then
        for k,v in pairs(tIds) do -- check ids table for received label
            if msg == "launch "..k then --if the label is already stored with a id then
                print("Launch command recieved from:"..resChan)
                print(k..":   "..v)
                modem.transmit(v,v,"launch") -- launch message
                launched = true
            end
        end
    end
    if not launched and _side == lModemSide then
        local file = fs.open("var/launchers/Ids.txt","w")
        msg = tostring(msg)
        tIds[msg] = resChan --adds label with id to table
        print(textutils.serialize(tIds)) 
        function save(table,msg)
            file.write(textutils.serialize(tIds))
            file.close()
        end
        save(tIds, msg)
  end
end      
        
    