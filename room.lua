-- make a room

local args = {...}
if # args != 3 then
    printUsage()
    return
end

local function printUsage()
    print("room <forward> <left> <up>")
    print("<...> = required parameter")
    print("forward, left, up = # blocks")
end

----------------------------------------------------------------------------

local numForward = args[1]
local numLeft = args[2]
local numUp = args[3]

turtle.digUp()
turtle.up()






