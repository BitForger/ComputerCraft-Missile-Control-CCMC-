
--[[ ICBM missile control panel by LuaCrawler
This goes with the door and launch controller for it to work.

for automatic load change the name of the file to startup and remove the extension.

]]

-- Variables
local delay = 5
local modem = peripheral.wrap("top")

local server = 10
local rChan = tonumber(os.getComputerID())

-- Users table
local users = {
    ["Admin"] = {["password"] = "password", ["permissions"] = "admin"},
}

local logo = {

}

local commands = {
    ["Add User"] = "Adds a user with permission. You must be a moderator or admin to add the user",
    ["Remove User"] = "Removes user. Must have moderator or admin privilages.",
    ["Launch missile"] = "Activates launch handle system,",
    ["open door"] = "Opens launch bay doors.",
    ["close door"] = "Closes launch bay doors.",
}

----------------------------------------------------------

-- Startup Function
local function startup()
    term.clear()
    term.setCursorPos(1,1)
    term.setCursorPos(18,8)
    term.setTextColor(colors.lime)
    print("MissileCraft 1.04")
    term.setCursorPos(18,9)
    print("'Speedy Skeleton'")
    sleep(5)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    modem.open(tonumber(os.getComputerID()))
    file = fs.open("/.users", "r")
    dataT = file.readAll()
    data = textutils.unserialize(dataT)
    file.close()
    users = data      
end
----------------------------------------------------------
local function checkUNamePasswd()
    local uName
    while (not users[uName]) or users[uName].password ~= passwd do
        term.clear()
        term.setCursorPos(1, 1)
        textutils.slowPrint("Enter username:", 25)
        local uName = read()
-- Now check store password as variable
        term.clear()
        term.setCursorPos(1, 1)
        textutils.slowPrint("Enter your password:", 25)
        local passwd = read()
        if (not users[uName]) or users[uName].password ~= passwd then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            textutils.slowPrint("Incorrect password! Please try again.", 50)
            term.setTextColor(colors.white)
            print("")
        else
            break
        end
    end
end
----------------------------------------------------------
local function checkUsrNamePerm()
    local uName
    while (not users[uName]) or (users[uName].permissions ~= "admin" and users[uName].permissions ~= "moderator") do
        term.clear()
        term.setCursorPos(1, 1)
        textutils.slowPrint("Enter username for verification", 25)
        uName = read()
        if (not users[uName]) or (users[uName].permissions ~= "admin" and users[uName].permissions ~= "moderator") then
            print("You don't have enough permissions! Please try again.")
        else
            break
        end
    end
end
----------------------------------------------------------
local function save(table,users)
    local file = fs.open(".users", "w")
    file.write(textutils.serialize(users))
    file.close()
end
----------------------------------------------------------
local function addUsr(Name, password, permissions)
    users[Name] = {}
    users[Name].password = password
    users[Name].permissions = permissions
    save(users, users)
end
----------------------------------------------------------
local bar = LoadBar.init(LoadBar.ASCII_BAR_ONLY, nil, 10, 30, 14, nil, nil, nil, nil )
local function doStuff()
    bar:setMessage( "Loading..." )
    for i = 1, 9 do
        sleep(0.5)
        bar:triggerUpdate("Initializing component("..(bar:getCurrentProgress()+1).."/9)")
    end
    bar:triggerUpdate("Done!")
end
----------------------------------------------------------
local function doBar()
    bar:run( true )
end
----------------------------------------------------------
local function missile_launch()
    -- Code here...
     os.loadAPI("/LoadBar")
    
    -- Run the loading bar
    parallel.waitForAll( doBar, doStuff )
    term.clear()
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(1, 1)
    for i = 1, 19 do
        print("                                                      ")
    end
    term.setTextColor(colors.yellow)
    term.setCursorPos(1, 1)
    textutils.slowPrint("Remote missile launch system" )
    textutils.slowPrint("Usage: launch <label>", 50)
    term.setTextColor(colors.white)
    lSilo = read()
    print("Confirm launch![Y/N]")
    _, char = os.pullEvent("char")
    if char == "y" then
        modem.transmit(server, rChan, lSilo)
    elseif char == "n" then
        do main_CLI()
    end
end
end
----------------------------------------------------------
local function addUser_CLI()
    -- Code here...
    term.clear()
    term.setCursorPos(1, 1)
    print("User addition system")
    print("Press enter to continue")
    os.pullEvent("key")
    textutils.slowPrint("What should the user's username be?", 50)
    local name = read()
    print("What would you like "..name.."'s password to be?")
    local passwd = read()
    print("What permissions should user "..name.." have?")
    local perms = read()
    for i = 1,10 do
        term.setCursorPos(18, 30)
        sleep(.3)
    end
    addUsr(name, passwd, perms)
    save(users,users)
    print("User created!")
end
----------------------------------------------------------
local function removeUser(usr)
    -- Code here...
    users[usr].password = nil
    users[usr].permissions = nil
    users[usr] = nil
end
----------------------------------------------------------
local function removeUser_CLI()
    -- Code here...
    term.clear()
    term.setCursorPos(1, 1)
    print("User removal system")
    print("Please type the name of the user you want to remove")
    local uName = read()
    removeUser(uName)
    print("User removed!")
end
----------------------------------------------------------
local function restart()
os.startTimer(delay)
    while true do
        local evt, p1, p2, p3, p4, p5 = os.pullEvent()
        if evt == "timer" then
            break
        elseif evt == "modem_message" then
            print(p2..":"..p4)
        end
    end
end
----------------------------------------------------------
local function main_CLI()
    -- Code here...
    term.clear()
    term.setCursorPos(1, 1)
    print("CCMC CLI")
    print("Type help for more info.")
    local cmd = read()
    if cmd == "help" then
        print("All commands are lowercase.")
        for _, v in pairs(commands) do
            print(_..":"..v)
        end
    elseif cmd == "exit" or cmd == "quit" then
        return
    end
    if cmd == "launch missile" then
        missile_launch()
    end
    if cmd == "add user" then
        checkUsrNamePerm()
        addUser_CLI()
    elseif cmd == "remove user" then
        checkUsrNamePerm()
        removeUser_CLI()
    end
    restart()
end
----------------------------------------------------------

startup()
checkUNamePasswd()
main_CLI()
