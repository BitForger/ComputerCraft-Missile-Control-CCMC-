--[[ Wireless ICBM missile launcher by LuaCrawler

YOU MUST CHANGE THE FILE NAME TO STARTUP FOR AUTOMATIC BOOT ON A COMPUTER!!
                                 -------

 -----     ____     |---\   |----
/        /      \   |    |  |
\        \      /   |    |  |==== 
 -----     ----     |___/   |____
 
 ]]

-- Variables
local modem = peripheral.wrap("top")
local cName
local file = fs.exists("etc/ID/cName.txt")
local f = fs.open("etc/ID/cName.txt", "r")
local rChannel = tonumber(os.getComputerID())
local sChan = 11
local icbm = peripheral.wrap("left")
local function startup()
    term.clear()
    term.setCursorPos(1,1)
    print("Launch handler console:")
    if file == false then
        fs.makeDir("etc/ID")
        h = fs.open("etc/ID/cName.txt", "w")
        print("Give a name/ID for the launcher:")
        cName = tostring(read())
        h.write( cName )
        os.setComputerLabel( cName )
        h.close()
        modem.transmit(sChan, rChannel, cName )
        sleep(3)
        term.clearLine() --Unneeded line... I think...
    elseif file == true then
        print(tostring(f.readAll()))
        print("Transmitted ID to server")
        modem.transmit(sChan, rChannel, cName)
    else
        print("could not send ID")
    end
end


startup()

while true do
  modem.open(rChannel)
  local evt, p1, p2, p3, p4, p5 = os.pullEvent("modem_message")
  if p4 == "launch" then
    term.setTextColor(colors.red)
    print("Missile Launched!")
    icbm.launch()
  else
    break
  end
end
