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
        debug.sethook(co, print, "l")
        print("PC TICK: ",coroutine.resume(co))
    end
end

return vmlib