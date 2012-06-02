local width, height = ...

if width == nil or height == nil then
    error("No width and height given")
end

local length = 0

local function status(stat)
    io.write(stat)
    length = string.len(stat)
end

local function statusEnd(stat)
    io.write(string.rep(".", width-length-string.len(stat)), stat)
end

return status, statusEnd
    