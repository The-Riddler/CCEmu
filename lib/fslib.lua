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

local fsroot, getTmpFile, osname = ...
local cdrive = nil
local localroot = nil
local fslib = {}
local manifestloaded = false
local manifestFiles = {}
local manifestDirectories = {}

local function writeManifest()
    if not next(manifestFiles) and not next(manifestDirectories) then return end
    
    local manifestDir = localroot.."/manifest.list"
        
    local fh = io.open(manifestDir, "w")
    if fh ~= nil then
        fh:write(table.concat(manifestDirectories, "\n"))
        fh:write("\n----------\n")
        fh:write(table.concat(manifestFiles, "\n"))
        fh:close()
    end
end

local function readFilesToTable(tbl, file)    
    --Read list of files
    local fh = io.open(file, "r")
    if fh ~= nil then
        for line in fh:lines() do   
            line = string.gsub(line, "\\", "/")
            --strip out C:/etc/etc/etc
            print(string.find(line, localroot))
            table.insert(tbl, string.sub(line, string.find(line, localroot)+string.len(localroot), string.len(line)))
        end
    end
end

local function createManifest()
    local tmpfname = getTmpFile()
    if osname == "windows" then
        os.execute("dir "..string.gsub(localroot, "/", "\\").." /B /S > \""..tmpfname.."\"")
        readFilesToTable(manifestFiles, tmpfname, localroot)
        os.execute("dir "..string.gsub(localroot, "/", "\\").." /B /S /AD > \""..tmpfname.."\"")
        readFilesToTable(manifestDirectories, tmpfname)
    else
        os.execute("find "..localroot.." > "..tmpfname)
    end
    writeManifest(localroot)
end

local function loadManifest()
    if manifestloaded == false then
        --Check for manifest
        local manifestDir = localroot.."/manifest.list"
        local fh = io.open(manifestDir, "r")
        if fh == nil then
            createManifest()
        else
            local tbl = 1
            for line in fh:lines() do
                if line == "----------" then 
                    tbl = tbl + 1
                elseif tbl == 1 then
                    table.insert(manifestDirectories, line)
                elseif tbl == 2 then
                    table.insert(manifestFiles, line)
                end
            end
        end
        manifestloaded = true
    end
end

local function formatDir(dir)
    if string.sub(dir, 1, 1) ~= "/" then
        dir = "/" .. dir
    end
    
    if fslib.isDir(dir) and string.sub(dir, -1, -1) ~= "/" then
        dir = dir .. "/"
    end
    
    return dir
end

function fslib.setDrive(id)
    manifestloaded = false
    --todo check if its valid
    cdrive = tostring(id)
    localroot = fsroot.."/hdd/"..cdrive
end

function fslib.exists(dir)
    loadManifest()
    
    for k, v in pairs(manifestFiles) do
        if v == dir then
            return true
        end
    end
    return false
end

function fslib.combine(str1, str2)
    loadManifest()
    
    if string.sub(str1, -1, -1) ~= "/" then
        str1 = str1.."/"
    end
    
    if string.sub(str2, 1, 1) == "/" then
        str2 = string.sub(str2, 2, -1)
    end
    
    return str1..str2
end

function fslib.isDir(dir)
    loadManifest()
    
    for k, v in pairs(manifestDirectories) do
        if string.find(v, dir) then return true end
    end
    return false
end

function fslib.getName(dir)
    loadManifest()
    
    return string.match(dir, "[^/][.%w]*$")
end

function fslib.list(dir)
    loadManifest()
    
    local result = {}
    local matchstring = formatDir(dir)
    local dirlen = string.len(matchstring)
    
    for k, v in pairs(manifestFiles) do
        local resultStr = string.match(v, matchstring)
        if resultStr ~= nil then
            table.insert(result, string.sub(v, dirlen+1, -1))
        end
    end
    
    if next(result) then
        return result
    else
        return nil
    end
end

function fslib.open(file, mode)
    loadManifest()
    local fh, err = io.open(localroot..formatDir(file), mode)
    if fh == nil then return nil, err end
    
    return {
        ["readAll"] = function() return fh:read("*a") end,
        ["close"] = function() return fh:close() end
    }
end

return fslib