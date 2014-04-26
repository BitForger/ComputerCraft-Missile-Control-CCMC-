--[[ ICBM Door controller LuaCrawler

If you want this to startup without having to put in the name the file name must be 
changed to startup.

]]

-- Variables
local modem = peripheral.wrap("top")
-- Startup
local function startup()
  term.clear()
  term.setCursorPos(1,1)
  textutils.slowPrint("ICBM door handler starting up...")
  print("Progress:")
  textutils.slowPrint("[===============================================>]")
  sleep(5)
  term.clear()
  term.setCursorPos(1,1)
  print("Console:")
  rs.setOutput("back", true )
end
startup()
while true do
  modem.open(3)
  local evt, p1, p2, p3, p4, p5 = os.pullEvent("modem_message")
  if p4 == "open" or p4 == "open door" then
    print("Door opened")
    rs.setOutput("back", false )
    modem.transmit(1,3,"Door open")
  elseif p4 == "close" or p4 == "close door" then
    print("Door closed")
    rs.setOutput("back",true )
    modem.transmit(1,3,"Door closed")
  end
end
