-- mine

action = {
    checkFuel = function()
        write("checking fuel... "..turtle.getFuelLevel().." blocks... ")
        if turtle.getFuelLevel() < 70 then
            write("too low, refueling... ")
            turtle.select(16)
            turtle.refuel(1)
            write(turtle.getFuelLevel().." blocks... ")
        end
        print("i'm good.") 
    end
}

state = {
    idle = function()
        print("hey buddy... let's mine some shit!")
        action.checkFuel()
        print("press enter to mine... ")
        read()
        state.mineDown()
        state.mineDown()
        turtle.select(15)
        turtle.placeUp()
        return false, state.mineDown
    end,
    mineDown = function()
        if turtle.detectDown() == false then
            if turtle.down() == false then
                -- can't go down anymore 
                return false, state.goUP
            end
        else
            if turtle.digDown() == false then
                -- can't go down anymore
                return false, state.goUp
            else
                if turtle.down() == false then
                    -- just in case...
                    return false, state.goUp
                end
            end
        end
        return false
    end,
    goUp = function()
        if turtle.up() == false then
            -- at the top?
            turtle.select(15)
            turtle.digUp()
            turtle.up()
            turtle.up()
            turtle.placeDown()
            return true
        end
        return false
    end
}

function loop()
    while true do
        local done, stateChange = currentState()
        if done then
            return -- stop
        end
        if type(stateChange) == "function" then
            currentState = stateChange
        end
        fuelCheck = fuelCheck - 1
        if fuelCheck <= 0 then
            action.checkFuel()
            fuelCheck = FUEL_CHECK_COUNT
        end
    end
end

FUEL_CHECK_COUNT = 20 -- check after this many loops
fuelCheck = FUEL_CHECK_COUNT
currentState = state.idle
loop()


