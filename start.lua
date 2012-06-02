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

local targs = {...}

--Constants
local currentfile = "iotest.lua"

--Argument variables
local prettyprint = false
local defaultsize = false
local dir = ""
local autoclose = true
local pcid = nil
local headless = false

--Variables we want visible all over the script
local osname = ""

--Check arguments
while next(targs) do
    local v = table.remove(targs, 1)
    if v == "-p" then
        prettyprint = true
    elseif v == "-pd" then
        prettyprint = true
        defaultsize = true
    elseif v == "-dir" then
        dir = table.remove(targs, 1)
        if dir == nil then error("-dir needs an argument") end
    elseif v == "-initmsg" then
        io.stderr:write("Running...")
    elseif v == "-k" then
        autoclose = false
    elseif v == "-id" then
        pcid = table.remove(targs, 1)
    elseif v == "-h" then
        headless = true
    elseif v == "-dev" then --broken
        print("--------------------------------")
        print("Starting in dev environment mode")
        print("--------------------------------")
        os.execute("start cmd /k lua5.1.exe "..dir.."/"..currentfile.." -dir "..dir.." "..table.concat(targs, " ").." -initmsg ".. "2> errlog.log")
        
        print("This is the error terminal, error messages will be displayed here")
        
        local pos = 0
        local str = ""
        repeat
            local fh = io.open("errlog.log", "r")
            if fh ~= nil then
                fh.seek("set", pos)
                str = fh.read("l")
                if str ~= nil and str ~= "" then
                    pos = pos + string.len(str)
                    io.write(str)
                end
            end
        until str == "EXIT"
    end
end

if pcid == nil then error("You must specify a pcid with '-id <id>'") end

--Print the arguments so we knew what the settings are
print("Pretty print: ", prettyprint)
print("Default size: ", defaultsize)
print("dir:         ", dir)
print("autoclose:    ", autoclose)
print("pcid          ", pcid)
print("headless      ", headless)

--Load status display if nessesary
local status = function(arg) io.write(arg, ": ") end
local statusDone = print
if prettyprint == true then
    local width, height
    if defaultsize == false then
        io.write("Please enter width of terminal: ")
        width = tonumber(io.read())
        io.write("Please enter height of terminal: ")
        height = tonumber(io.read())
    else
        width, height = 80, 25
    end
    
    status, statusDone = assert(loadfile(dir.."lib/statusdisplay.lua"))(width, height)
end

--[[-----------------------------------------
Actually start doing stuff
--]]-----------------------------------------
--Check what OS were on, this will matter for tempfiles etc
status("Determining operating system")
    local fh = io.popen("uname -s 2>/dev/null","r")
    
    if fh ~= nil then
        osname = fh:read()
    else
        error("Error detecting operating system")
    end
    
    if osname == nil then
        osname = "windows"
    end
statusDone(osname)

--load tempfile.lua
status("Loading tempfile.lua")
    local getTempFile = assert(loadfile(dir.."lib/tempfile.lua"))(osname)
statusDone(tostring(getTempFile))

--load fslib
status("Loading fslib")
    local fslib = assert(loadfile(dir.."lib/fslib.lua"))(dir.."/pc/hdd", getTempFile)
statusDone(tostring(fslib))

--Load vmlib
status("Loading vmlib")
    local vmlib = assert(loadfile(dir.."lib/vm.lua"))(fslib, getTempFile)
statusDone(tostring(vmlib))

--Spawn the first pc
status("Spawning first pc instance")
    assert(vmlib.createPC(pcid), "Error spawning PC")
statusDone("done")

if headless == false then--Spawn I/O terminal
    --Spawn IO terminals
    status("Loading spawnterm.lua")
        local spawnTerm = assert(loadfile(dir.."lib/spawnterm.lua"))()
    statusDone(tostring(spawnTerm))
    
    local input, output = vmlib.getIOFiles(pcid)
    status("Spawning output terminal")
        assert(spawnTerm(osname, autoclose, dir.."output.lua", output), "Error spawning terminal")
    statusDone("done")

    status("Spawning input terminal")
        assert(spawnTerm(osname, autoclose, dir.."inputterm.lua", input), "Error spawning terminal")
    statusDone("done")
end

status("Booting PC")
    local status, err = vmlib.bootPC(pcid, dir.."pc/bios.lua")
    if status ~= 0 then error("Error booting pc: "..(err or tostring(status))) end
statusDone("done")

print("Tick")
vmlib.tick()

print("-----------DONE----------")
