--[[
Copyright (C) 2012  Jordan (Riddler)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Contact: PM Riddler80 on http://www.minecraftforum.net
]]--

local vmlib = {}
local pclist = {}
local fslib, getTmpFile = ...

vmlib["status"] = {
    ["LOAD_ERROR"] = 1,
    ["PC_ID_INVALID"] = 2
}

--Create environment
local pcenv = {
    ["table"] = {
        ["insert"] = table.insert,
        ["remove"] = table.remove
    },
    ["coroutine"] = {
        ["yeild"] = coroutine.yield
    },
    ["string"] = {
        ["len"] = string.len,
        ["match"] = string.match,
        ["sub"] = string.sub,
        ["rep"] = string.rep
    },
    ["os"] = {},
    ["peripheral"] = {},
    ["type"] = type,
    ["loadstring"] = loadstring,
    ["getmetatable"] = getmetatable,
    ["setmetatable"] = setmetatable,
    ["tostring"] = tostring,
    ["ipairs"] = ipairs,
    ["pairs"] = pairs,
    ["write"] = function(...) coroutine.yield("write", unpack({...})) end,
    ["error"] = error
}
pcenv["_G"] = pcenv

local function getPCData(id)
    for k, v in pairs(pclist) do
        if v["id"] == id then
            return v
        end
    end
    return nil
end

function vmlib.createPC(id)
    local pc = {
        ["id"] = id,
        ["started"] = os.time(),
        ["input"] = getTmpFile(),
        ["output"] = getTmpFile()
    }
    table.insert(pclist, pc)
    return true
end

function vmlib.getIOFiles(id)
    local pcdata = getPCData(id)
    if pcdata ~= nil then
        return pcdata["input"], pcdata["output"]
    else
        return nil
    end
end

function vmlib.bootPC(id, file)
    local func, err = loadfile(file)
    if func == nil then
        return vmlib["status"]["LOAD_ERROR"], err
    end
    
    local pcdata = getPCData(id)
    if pcdata == nil then
        return vmlib["status"]["PC_ID_INVALID"]
    end
    setfenv(func, pcenv)
    pcdata["program"] = coroutine.create(func)
    return 0
end

function vmlib.tick()
    for k, v in pairs(pclist) do
        local co = v["program"]
        
        local file = {}
        local filename = ""
        
        debug.sethook(co, function(hook, linenum)
            local info = debug.getinfo(2, "nS")
            if filename ~= info.source then
            local srcfile = string.sub(info.source, 2, string.len(info.source))
                local fh = io.open(srcfile, "r")
                if fh ~= nil then
                    for line in fh:lines() do
                        table.insert(file, line)
                    end
                end
                fh:close()
            end
            filename = info.source
            
            print(info.short_src, linenum, file[linenum] )
        end, "l")
        
        print("PC TICK: ",coroutine.resume(co))
    end
end

return vmlib