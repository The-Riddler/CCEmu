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
local fslib = {}
local manifestloaded = false
local manifest = {}

local function writeManifest()
    if not next(manifest) then return end
    
    local localroot = fsroot.."/"..cdrive
    local manifestDir = localroot.."/manifest.list"
        
    local fh = io.open(manifestDir, "w")
    if fh ~= nil then
        fh:write(table.concat(manifest, "\n"))
        fh:close()
    end
end

local function loadManifest()
    if manifestloaded == false then
        --Check for manifest
        local localroot = fsroot.."/"..cdrive
        local manifestDir = localroot.."/manifest.list"
        local fh = io.open(manifestDir, "r")
        if fh == nil then
            --Create manifest
            local tmpfname = getTmpFile()
            if osname == "windows" then
                os.execute("dir "..string.gsub(localroot, "/", "\\").." /B /S ".." > \""..tmpfname.."\"")
            end
            
            --Read list of files
            local fh = io.open(tmpfname, "r")
            if fh ~= nil then
                for line in fh:lines() do
                    line = string.gsub(line, "\\", "/")
                    --strip out C:/etc/etc/etc
                    table.insert(manifest, string.sub(line, string.find(line, localroot)+string.len(localroot), string.len(line)))
                end
            end
            
            writeManifest()
        else
            for line in fh:lines() do
                table.insert(manifest, line)
            end
        end
    end
end

function fslib.setDrive(id)
    manifestloaded = false
    --todo check if its valid
    cdrive = tostring(id)
end

function fslib.exists(dir)
    loadManifest()
    for k, v in pairs(manifest) do
        if v == dir then
            return true
        end
    end
    return false
end

function fslib.list(dir)
    loadManifest()
    
    local result = {}
    for k, v in pairs(manifest) do
        if string.find(v, dir) == 1 then
            table.insert(result, v)
        end
    end
    
    if next(result) then
        return result
    else
        return nil
    end
end

return fslib