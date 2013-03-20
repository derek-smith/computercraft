local VERSION = "0.0.5" -- must be the first line!

-- app manager

print()
print("app v"..VERSION)
print()

-- define functions
local Util = {
    table = {
        explode = function() end,
        count = function() end,
        print = function() end
    }
}

Util = {
    table = {
        explode = function(t)
            local count = Util.table.count(t)
            if count == 0 then return end
            if count == 1 then return t[1] end
            if count == 2 then return t[1], t[2] end
            if count == 3 then return t[1], t[2], t[3] end
            if count == 4 then return t[1], t[2], t[3], t[4] end
            if count == 5 then return t[1], t[2], t[3], t[4], t[5] end
        end,
        count = function(t)
            local count = 0
            for _ in pairs(t) do count = count+1 end
            return count
        end,
        print = function(t)
            print("count: "..Util.table.count(t))
            for key,value in pairs(t) do
                key = "("..type(value)..")"..key
                if type(value) == "function" then
                    value = value()
                end
                if value == nil then
                    print(key..": nil")
                else
                    value = "("..type(value)..")"..value
                    print(key..": "..value)
                end
                
            end            
        end
    }
}

-- define fun
local Path = {
    get = function() end,
    contains = function() end,
    add = function() end,
    remove = function() end,
    print = function() end
}

Path = {
    get = function()
        local path = shell.path()
        local paths = {}
        local currentPath = ""
        for i = 1, # path do
            local char = string.sub(path, i, i)
            if char == ":" then
                table.insert(paths, currentPath)
                currentPath = ""
            else
                currentPath = currentPath..char
            end            
        end
        table.insert(paths, currentPath)
        return paths
    end,
    contains = function(path)
        local paths = Path.get()
        for i,p in ipairs(paths) do
            if path == p then
                return true, paths, i
            end
        end
        return false, paths
    end,    
    add = function(path, i)
        local pathFound, paths = Path.contains(path)
        if pathFound == false then
            if i == nil then
                table.insert(paths, path)
            else
                table.insert(paths, i, path)        
            end
            local newPath = table.concat(paths, ":")
            shell.setPath(newPath)
        end
    end,
    remove = function(path)
        local pathFound, paths, i = Path.contains(path)
        if pathFound then
            table.remove(paths, i)
            local newPath = table.concat(paths, ":")
            shell.setPath(newPath)
        end
    end,
    print = function()
        local paths = Path.get()
        print("paths:")
        for i,path in ipairs(paths) do
            print(path)
        end
    end
}

if fs.exists("/apps") == false then
    fs.makeDir("/apps")
end
if fs.exists("/apps/bin") == false then
    fs.makeDir("/apps/bin")
end
if fs.exists("/apps/manager") == false then
    fs.makeDir("/apps/manager")
end

Path.add("/apps/bin")

local commands = {
    test = {
        name = "test",
        enabled = true,
        run = function(args)
            local a1, a2, a3 = Util.table.explode(args)
            print(a1)
            print(a2)
            print(a3)
        end
    },
    install = {
        name = "install",
        enabled = true,
        run = function(args)
            local name = Util.table.explode(args)
            local url = "https://raw.github.com/derek-smith/computercraft/master/"..name..".lua"
            print("downloading app from:")
            print(url)
            print()
            local request = http.get(url)
            
            if request == nil then
                write(name.." not found... install failed.") 
                return false
            end
            
            write("reading code... ")
            local script = request.readAll()
            print("done.")
            write("saving app... ")
            local file = fs.open("/apps/bin/"..name, "w")
            file.write(script)
            file.close()
            print("done.")
            print()
            print(name.." installed successfully.")            
        end
    },
    addRepo = {
        name = "add-repo",
        enabled = false,
        run = function()
            print("addrepo func")
            return true
        end
    },
    updateSelf = {
        name = "update-self",
        enabled = true,
        run = function()
            local url = "https://raw.github.com/derek-smith/computercraft/master/app.lua"
            print("updating myself from:")
            print(url)
            local request = http.get(url)
            
            if request == nil then
                write(name.." not found... ") 
                return false
            end
            
            print("response: "..request.getResponseCode())
            print()
            
            local script = request.readAll()
            --Util.table.print(request)
            
            --local i,j = string.find(script, "%d.%d.%d+")
            --print(i.." "..j)
            
            local v = string.match(script, "(%d.%d.%d+)")
            print(v)
        end
    }
}

local function printUsage()
    print("usage: app <command> <name> [name, ...]")
    print()
    print("commands:")
    for i,command in pairs(commands) do
        if command.enabled == true then
            print("          "..command.name) 
        end
    end
    print()
end

local args = {...}
if # args == 0 then
    printUsage()
    return
end

local tryCommand = table.remove(args, 1) 

for i,command in pairs(commands) do
    if tryCommand == command.name then
        if command.enabled then
            command.run(args)
        end
        print()
        return
    end
end
print("unknown command: "..tryCommand)
printUsage()


