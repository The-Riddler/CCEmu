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

local debuglib = {}
local codeData = {}
local frameinfo = {}


function debuglib.hook(hook, line)
    frameinfo = debug.getinfo(3, "S")
    frameinfo["line"] = line
end

function debuglib.getShortSrc()
    return frameinfo["short_src"]
end

function debuglib.getLineNum()
    return frameinfo["line"]
end

function debuglib.getLineCode()
    local file = frameinfo["source"]
    local isfile = string.sub(file, 1, 1) == "@"
    
    if codeData[file] then
        if not isfile then 
            file = string.sub(file, 1, math.min(string.len(file), 20)) 
        end
        
        return codeData[file][frameinfo["line"]]
    else
        if isfile then
            local fh = io.open(string.sub(file, 2, -1), "r")
            if fh == nil then
                return nil, "error loading file"
            else
                codeData[file] = {}
                
                for line in fh:lines() do
                    table.insert(codeData[file], line)
                end
                
                fh:close()
            end
        else
            return nil, "loadstring code not been captured"
        end
    end
end

function debuglib.loadstring(code, name)
    local tbl = {}
    
    for line in string.gmatch(code, "[^\n]*[\n]?") do
        if string.sub(line, -1, -1) == "\n" then
            line = string.sub(line, 1, -2)
        end
        
        table.insert(tbl, line or "")
    end
    
    if name ~= nil then
        codeData[string.sub(name, 1, math.min(string.len(name), 20))] = tbl
    else
        codeData[string.sub(code, 1, math.min(string.len(code), 20))] = tbl
    end
    
    return loadstring(code, name)
end

return debuglib